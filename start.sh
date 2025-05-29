#!/bin/bash

# Configurar locale
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Configurar variables de conexión con valores por defecto
DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-odoo_db}"
ADMIN_USER="${ADMIN_USER:-postgres}"  # Usuario admin para conceder permisos

# Función para ejecutar comandos psql con el usuario admin
admin_psql() {
    PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "$1"
}

echo "Esperando a que PostgreSQL esté disponible en $DB_HOST:$DB_PORT..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
  sleep 2
done

echo "Verificando si la base de datos $DB_NAME existe..."
DB_EXISTS=$(PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -lqt | cut -d \| -f 1 | grep -w "$DB_NAME")

if [ -z "$DB_EXISTS" ]; then
  echo "Creando base de datos $DB_NAME..."
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
  python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i base --stop-after-init --without-demo=all
fi

echo "Iniciando Odoo normalmente..."
exec python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME"