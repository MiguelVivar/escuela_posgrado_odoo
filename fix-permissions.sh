#!/bin/bash

# Script para otorgar permisos de SUPERUSER al usuario odoo en Railway

echo "=== OTORGANDO PERMISOS DE SUPERUSER AL USUARIO ODOO ==="

# Configurar variables
DB_HOST="${DB_HOST:-${PGHOST:-postgres.railway.internal}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-odoo}}"
ADMIN_USER="${ADMIN_USER:-${PGUSER:-postgres}}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-${PGPASSWORD}}"

echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT" 
echo "DB_USER: $DB_USER"
echo "ADMIN_USER: $ADMIN_USER"
echo

# Verificar conexión con admin
echo "1. Verificando conexión con usuario admin..."
if ! PGPASSWORD="$ADMIN_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "SELECT version();" >/dev/null 2>&1; then
    echo "ERROR: No se puede conectar con usuario admin"
    exit 1
fi
echo "✓ Conexión admin exitosa"

# Otorgar permisos de SUPERUSER
echo "2. Otorgando permisos de SUPERUSER al usuario $DB_USER..."
if PGPASSWORD="$ADMIN_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "ALTER ROLE \"$DB_USER\" SUPERUSER;"; then
    echo "✓ Permisos de SUPERUSER otorgados exitosamente"
else
    echo "ERROR: No se pudieron otorgar permisos de SUPERUSER"
    exit 1
fi

# Verificar permisos
echo "3. Verificando permisos del usuario $DB_USER..."
PGPASSWORD="$ADMIN_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "
SELECT 
    rolname, 
    rolsuper, 
    rolcreaterole, 
    rolcreatedb, 
    rolcanlogin 
FROM pg_roles 
WHERE rolname = '$DB_USER';"

echo
echo "=== ÉXITO: Usuario $DB_USER ahora tiene permisos de SUPERUSER ==="
echo "Ahora puedes proceder con el deployment de Odoo"
