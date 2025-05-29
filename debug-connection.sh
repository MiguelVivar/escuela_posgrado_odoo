#!/bin/bash

# Script de debugging para problemas de conexión en Railway

echo "=== DEBUG DE CONEXIÓN RAILWAY ==="
echo "Fecha: $(date)"
echo

# Mostrar variables de entorno relevantes
echo "=== Variables de entorno ==="
env | grep -E '^(PG|DB_|RAILWAY_)' | sort
echo

# Configurar variables
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"
ADMIN_USER="${ADMIN_USER:-${PGUSER:-postgres}}"

echo "=== Variables configuradas ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"
echo "DB_NAME: $DB_NAME"
echo "ADMIN_USER: $ADMIN_USER"
echo "DB_PASSWORD: [${#DB_PASSWORD} caracteres]"
echo

# Test de conectividad básica
echo "=== Test de conectividad ==="
echo "Verificando si el puerto está abierto..."
if command -v nc >/dev/null 2>&1; then
    if nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; then
        echo "✓ Puerto $DB_HOST:$DB_PORT está abierto"
    else
        echo "✗ No se puede conectar al puerto $DB_HOST:$DB_PORT"
    fi
else
    echo "nc no disponible, usando pg_isready..."
fi

echo "Verificando con pg_isready..."
if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; then
    echo "✓ PostgreSQL está listo para conexiones"
else
    echo "✗ PostgreSQL no está listo"
fi
echo

# Test de autenticación
echo "=== Test de autenticación ==="
echo "Probando conexión con usuario admin ($ADMIN_USER)..."
if PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "SELECT version();" 2>/dev/null; then
    echo "✓ Autenticación exitosa con usuario admin"
else
    echo "✗ Falló la autenticación con usuario admin"
    echo "Error detail:"
    PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "SELECT 1;" 2>&1 | head -5
fi
echo

if [ "$DB_USER" != "$ADMIN_USER" ]; then
    echo "Probando conexión con usuario Odoo ($DB_USER)..."
    if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "SELECT version();" 2>/dev/null; then
        echo "✓ Autenticación exitosa con usuario Odoo"
    else
        echo "✗ Falló la autenticación con usuario Odoo"
        echo "Error detail:"
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "SELECT 1;" 2>&1 | head -5
    fi
    echo
fi

# Verificar bases de datos existentes
echo "=== Bases de datos existentes ==="
echo "Listando bases de datos..."
PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -l 2>/dev/null || echo "No se pudo listar las bases de datos"
echo

# Verificar permisos del usuario
echo "=== Permisos del usuario ==="
if [ "$DB_USER" != "$ADMIN_USER" ]; then
    echo "Verificando permisos del usuario $DB_USER..."
    PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "
    SELECT 
        rolname, 
        rolsuper, 
        rolcreaterole, 
        rolcreatedb, 
        rolcanlogin,
        rolreplication
    FROM pg_roles 
    WHERE rolname = '$DB_USER';" 2>/dev/null || echo "No se pudieron verificar los permisos"
fi
echo

# Test de creación de base de datos (si no existe)
echo "=== Test de operaciones ==="
DB_EXISTS=$(PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -lqt 2>/dev/null | cut -d \| -f 1 | grep -w "$DB_NAME" | head -1)

if [ -z "$DB_EXISTS" ]; then
    echo "La base de datos $DB_NAME no existe."
    echo "¿Probar crear una base de datos de prueba? (y/n)"
    read -r response
    if [ "$response" = "y" ]; then
        echo "Creando base de datos de prueba..."
        if PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "CREATE DATABASE test_odoo_connection;"; then
            echo "✓ Base de datos de prueba creada exitosamente"
            echo "Eliminando base de datos de prueba..."
            PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "DROP DATABASE test_odoo_connection;"
        else
            echo "✗ No se pudo crear la base de datos de prueba"
        fi
    fi
else
    echo "La base de datos $DB_NAME existe."
    
    # Verificar si está inicializada
    DB_INITIALIZED=$(PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -d "$DB_NAME" -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name='ir_module_module');" 2>/dev/null || echo "f")
    echo "¿Está inicializada con Odoo? $DB_INITIALIZED"
    
    # Mostrar algunas tablas si existen
    echo "Tablas en la base de datos:"
    PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -d "$DB_NAME" -c "\dt" 2>/dev/null | head -10
fi

echo
echo "=== FIN DEL DEBUG ==="
