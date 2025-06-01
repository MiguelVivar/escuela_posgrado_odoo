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
addons_path = /usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons,/mnt/custom-addons
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
db_maxconn = 64
db_timeout = 120
logfile = False
log_handler = :INFO
log_db = False
limit_request = 8192
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
proxy_mode = True
server_wide_modules = base,web
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

# Función para ejecutar comandos psql con el usuario de Odoo
user_psql() {
    echo "Ejecutando SQL como usuario Odoo: $1"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "$1"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Error ejecutando comando SQL como usuario Odoo. Código de salida: $exit_code"
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

# Verificar y crear el usuario de Odoo si es diferente al admin
if [ "$DB_USER" != "$ADMIN_USER" ]; then
    echo "Verificando si el usuario de Odoo ($DB_USER) existe..."
    
    # Verificar si el usuario existe
    USER_EXISTS=$(PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';" 2>/dev/null || echo "")
    
    if [ -z "$USER_EXISTS" ]; then
        echo "El usuario $DB_USER no existe. Creándolo..."
        if ! PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "CREATE ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD' CREATEDB SUPERUSER;"; then
            echo "Error: No se pudo crear el usuario $DB_USER"
            exit 1
        fi
        echo "Usuario $DB_USER creado exitosamente con permisos de SUPERUSER!"
    else
        echo "El usuario $DB_USER ya existe. Otorgando permisos de SUPERUSER..."
        # Asegurar que tenga permisos de SUPERUSER para evitar problemas de esquema
        if ! PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "ALTER ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD' CREATEDB SUPERUSER;"; then
            echo "Error: No se pudieron otorgar permisos de SUPERUSER"
            exit 1
        fi
        echo "Permisos de SUPERUSER otorgados al usuario $DB_USER!"
    fi
    
    # Verificar conexión del usuario de Odoo
    echo "Verificando conexión con usuario de Odoo ($DB_USER)..."
    if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "SELECT 1;" >/dev/null 2>&1; then
        echo "Error: El usuario de Odoo no puede conectarse después de la creación/actualización"
        exit 1
    else
        echo "Usuario de Odoo puede conectarse correctamente!"
    fi
fi

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
  if ! PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "CREATE DATABASE \"$DB_NAME\" OWNER \"$DB_USER\";"; then
    echo "Error: No se pudo crear la base de datos"
    exit 1
  fi
  echo "Base de datos $DB_NAME creada exitosamente!"
  
  # Verificar que el usuario puede conectarse a la nueva base de datos
  echo "Verificando conexión del usuario Odoo a la nueva base de datos..."
  if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
      echo "Error: El usuario Odoo no puede conectarse a la base de datos recién creada"
      exit 1
  fi
  echo "Conexión del usuario Odoo verificada exitosamente!"
  echo "Inicializando la base de datos con módulo base..."
  echo "DEBUG: Intentando inicializar con comando completo..."
  echo "Comando: python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d \"$DB_NAME\" -i base --stop-after-init --without-demo=all --log-level=debug"
  if ! python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i base --stop-after-init --without-demo=all --log-level=debug; then
    echo "Error: Falló la inicialización de la base de datos"
    exit 1
  fi
  echo "Base de datos inicializada correctamente!"
  
  # Instalar módulos personalizados si están disponibles
  echo "Verificando módulos personalizados disponibles..."
  if [ -d "/mnt/custom-addons" ] && [ "$(ls -A /mnt/custom-addons)" ]; then
    echo "Módulos personalizados encontrados en /mnt/custom-addons:"
    ls -la /mnt/custom-addons/
    
    # Obtener lista de módulos personalizados disponibles
    CUSTOM_MODULES=""
    for module_path in /mnt/custom-addons/*/; do
      if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
        module_name=$(basename "$module_path")
        echo "Módulo personalizado encontrado: $module_name"
        if [ -z "$CUSTOM_MODULES" ]; then
          CUSTOM_MODULES="$module_name"
        else
          CUSTOM_MODULES="$CUSTOM_MODULES,$module_name"
        fi
      fi
    done
    
    if [ ! -z "$CUSTOM_MODULES" ]; then
      echo "Instalando módulos personalizados: $CUSTOM_MODULES"
      if ! python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "$CUSTOM_MODULES" --stop-after-init --without-demo=all --log-level=info; then
        echo "Advertencia: Algunos módulos personalizados podrían no haberse instalado correctamente"
      else
        echo "Módulos personalizados instalados exitosamente!"
      fi
    fi
  else
    echo "No se encontraron módulos personalizados para instalar"
  fi
elif [ "$DB_INITIALIZED" = "f" ]; then
  echo "La base de datos $DB_NAME existe pero no está inicializada. Inicializando..."
  
  # Verificar permisos del usuario antes de inicializar
  echo "Verificando permisos del usuario Odoo en la base de datos existente..."
  if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
      echo "El usuario Odoo no puede conectarse a la base de datos existente"
      exit 1
  fi
  echo "Usuario Odoo puede conectarse a la base de datos existente!"
    echo "DEBUG: Intentando inicializar base de datos existente..."
  echo "Comando: python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d \"$DB_NAME\" -i base --stop-after-init --without-demo=all --log-level=debug"
  if ! python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i base --stop-after-init --without-demo=all --log-level=debug; then
    echo "Error: Falló la inicialización de la base de datos existente"
    exit 1
  fi
  echo "Base de datos inicializada correctamente!"
  
  # Instalar módulos personalizados si están disponibles
  echo "Verificando módulos personalizados disponibles..."
  if [ -d "/mnt/custom-addons" ] && [ "$(ls -A /mnt/custom-addons)" ]; then
    echo "Módulos personalizados encontrados en /mnt/custom-addons:"
    ls -la /mnt/custom-addons/
    
    # Obtener lista de módulos personalizados disponibles
    CUSTOM_MODULES=""
    for module_path in /mnt/custom-addons/*/; do
      if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
        module_name=$(basename "$module_path")
        echo "Módulo personalizado encontrado: $module_name"
        if [ -z "$CUSTOM_MODULES" ]; then
          CUSTOM_MODULES="$module_name"
        else
          CUSTOM_MODULES="$CUSTOM_MODULES,$module_name"
        fi
      fi
    done
    
    if [ ! -z "$CUSTOM_MODULES" ]; then
      echo "Instalando módulos personalizados: $CUSTOM_MODULES"
      if ! python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "$CUSTOM_MODULES" --stop-after-init --without-demo=all --log-level=info; then
        echo "Advertencia: Algunos módulos personalizados podrían no haberse instalado correctamente"
      else
        echo "Módulos personalizados instalados exitosamente!"
      fi
    fi
  else
    echo "No se encontraron módulos personalizados para instalar"
  fi
else
  echo "La base de datos $DB_NAME ya existe y está inicializada."
fi

echo "Iniciando Odoo normalmente..."
echo "Comando: python3 /usr/bin/odoo -c /etc/odoo/odoo.conf"
exec python3 /usr/bin/odoo -c /etc/odoo/odoo.conf