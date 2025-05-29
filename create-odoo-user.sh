#!/bin/bash

# Script rápido para crear el usuario odoo en Railway

echo "=== SCRIPT DE CREACIÓN DE USUARIO ODOO ==="

# Configurar variables
DB_HOST="${DB_HOST:-${PGHOST:-postgres.railway.internal}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-odoo}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD}}"
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

# Verificar si usuario odoo existe
echo "2. Verificando si usuario $DB_USER existe..."
USER_EXISTS=$(PGPASSWORD="$ADMIN_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';" 2>/dev/null)

if [ -z "$USER_EXISTS" ]; then
    echo "Usuario $DB_USER no existe. Creándolo..."
    
    if PGPASSWORD="$ADMIN_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "CREATE ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD' CREATEDB SUPERUSER;"; then
        echo "✓ Usuario $DB_USER creado exitosamente con permisos de SUPERUSER"
    else
        echo "ERROR: No se pudo crear el usuario"
        exit 1
    fi
else
    echo "Usuario $DB_USER ya existe. Actualizando permisos..."
    PGPASSWORD="$ADMIN_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "ALTER ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD' CREATEDB SUPERUSER;" || echo "Warning: Error actualizando permisos"
fi

# Verificar conexión del usuario odoo
echo "3. Verificando conexión del usuario $DB_USER..."
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "SELECT current_user, current_database();" >/dev/null 2>&1; then
    echo "✓ Usuario $DB_USER puede conectarse correctamente"
else
    echo "ERROR: Usuario $DB_USER no puede conectarse"
    exit 1
fi

echo
echo "=== ÉXITO: Usuario $DB_USER configurado correctamente ==="
echo "Ahora puedes proceder con el deployment normal de Odoo"
