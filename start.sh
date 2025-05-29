#!/bin/bash

# Configurar locale
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Configurar variables de conexión con valores por defecto
# Railway usa variables PGHOST, PGUSER, etc. Mapearlas a nuestras variables
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"
ADMIN_USER="${ADMIN_USER:-${PGUSER:-postgres}}"  # Usuario admin para conceder permisos

echo "=== Configuración de conexión ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"
echo "DB_NAME: $DB_NAME"
echo "ADMIN_USER: $ADMIN_USER"
echo "================================="

# Generar configuración dinámica de Odoo
echo "Generando configuración dinámica de Odoo..."
cat > /etc/odoo/odoo.conf << EOF
[options]
addons_path = /mnt/extra-addons
admin_passwd = admin
db_host = $DB_HOST
db_port = $DB_PORT
db_user = $DB_USER
db_password = $DB_PASSWORD
db_name = $DB_NAME
log_level = info
workers = 2
max_cron_threads = 1
list_db = False
db_template = template0
EOF

echo "Configuración de Odoo generada:"
cat /etc/odoo/odoo.conf

# Función para ejecutar comandos psql con el usuario admin
admin_psql() {
    echo "Ejecutando SQL: $1"
    PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "$1"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Error ejecutando comando SQL. Código de salida: $exit_code"
        return $exit_code
    fi
    return 0
}

echo "Esperando a que PostgreSQL esté disponible en $DB_HOST:$DB_PORT..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
  echo "PostgreSQL no está listo. Reintentando en 2 segundos..."
  sleep 2
done
echo "PostgreSQL está disponible!"

# Verificar conexión con credenciales
echo "Verificando credenciales de conexión..."
if ! PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "Error: No se puede conectar a PostgreSQL con las credenciales proporcionadas"
    echo "Verificando variables de entorno disponibles..."
    env | grep -E '^(PG|DB_)'
    exit 1
fi
echo "Conexión a PostgreSQL establecida correctamente!"

echo "Verificando si la base de datos $DB_NAME existe..."
DB_EXISTS=$(PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -lqt 2>/dev/null | cut -d \| -f 1 | grep -w "$DB_NAME" | head -1)

echo "Verificando si la base de datos está inicializada..."
# Verificar si existen tablas de Odoo (ir_module_module es una tabla core de Odoo)
DB_INITIALIZED=""
if [ ! -z "$DB_EXISTS" ]; then
    DB_INITIALIZED=$(PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -d "$DB_NAME" -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name='ir_module_module');" 2>/dev/null || echo "f")
fi

echo "DB_EXISTS: $DB_EXISTS"
echo "DB_INITIALIZED: $DB_INITIALIZED"

if [ -z "$DB_EXISTS" ]; then
  echo "La base de datos $DB_NAME no existe. Creándola..."
  admin_psql "CREATE DATABASE \"$DB_NAME\" OWNER \"$DB_USER\";"
  
  echo "Otorgando permisos al usuario $DB_USER..."
  admin_psql "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO \"$DB_USER\";"
  admin_psql "ALTER DATABASE \"$DB_NAME\" SET search_path TO public;"
  admin_psql "GRANT ALL PRIVILEGES ON SCHEMA public TO \"$DB_USER\";"
  admin_psql "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$DB_USER\";"
  admin_psql "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$DB_USER\";"
  admin_psql "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO \"$DB_USER\";"
  admin_psql "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO \"$DB_USER\";"

  echo "Inicializando la base de datos con módulo base..."
  if ! python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i base --stop-after-init --without-demo=all; then
    echo "Error: Falló la inicialización de la base de datos"
    exit 1
  fi
  echo "Base de datos inicializada correctamente!"
elif [ "$DB_INITIALIZED" = "f" ]; then
  echo "La base de datos $DB_NAME existe pero no está inicializada. Inicializando..."
  if ! python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i base --stop-after-init --without-demo=all; then
    echo "Error: Falló la inicialización de la base de datos existente"
    exit 1
  fi
  echo "Base de datos inicializada correctamente!"
else
  echo "La base de datos $DB_NAME ya existe y está inicializada."
fi

echo "Iniciando Odoo normalmente..."
echo "Comando: python3 /usr/bin/odoo -c /etc/odoo/odoo.conf"
exec python3 /usr/bin/odoo -c /etc/odoo/odoo.conf