#!/bin/bash

# Versión alternativa del script de inicio con manejo mejorado de errores

# Configurar locale
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Configurar variables de conexión con valores por defecto
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"
ADMIN_USER="${ADMIN_USER:-${PGUSER:-postgres}}"

echo "=== INICIO DEL PROCESO DE DEPLOYMENT ==="
echo "Fecha: $(date)"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"
echo "DB_NAME: $DB_NAME"
echo "ADMIN_USER: $ADMIN_USER"
echo "============================================"

# Crear configuración mínima para Odoo
echo "Generando configuración de Odoo..."
cat > /etc/odoo/odoo.conf << EOF
[options]
addons_path = /mnt/extra-addons
admin_passwd = admin
db_host = $DB_HOST
db_port = $DB_PORT
db_user = $DB_USER
db_password = $DB_PASSWORD
log_level = info
workers = 0
max_cron_threads = 1
list_db = False
db_template = template0
db_maxconn = 64
db_timeout = 120
logfile = False
EOF

echo "Configuración generada:"
cat /etc/odoo/odoo.conf
echo

# Esperar a PostgreSQL
echo "Esperando a PostgreSQL..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" >/dev/null 2>&1; then
        echo "PostgreSQL está disponible!"
        break
    fi
    attempt=$((attempt + 1))
    echo "Intento $attempt/$max_attempts - PostgreSQL no está listo, esperando..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "ERROR: PostgreSQL no está disponible después de $max_attempts intentos"
    exit 1
fi

# Verificar conexión
echo "Verificando conexión..."
if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "ERROR: No se puede conectar con el usuario $DB_USER"
    
    # Intentar con usuario admin si es diferente
    if [ "$DB_USER" != "$ADMIN_USER" ]; then
        echo "Intentando con usuario admin..."
        if PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "SELECT 1;" >/dev/null 2>&1; then
            echo "Conexión con admin exitosa, verificando/creando usuario..."
            
            # Verificar si el usuario existe
            USER_EXISTS=$(PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';" 2>/dev/null || echo "")
            
            if [ -z "$USER_EXISTS" ]; then
                echo "Creando usuario $DB_USER..."
                if ! PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "CREATE ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD' CREATEDB;"; then
                    echo "ERROR: No se pudo crear el usuario $DB_USER"
                    exit 1
                fi
                echo "Usuario $DB_USER creado exitosamente!"
            else
                echo "Usuario $DB_USER existe, actualizando permisos..."
                PGPASSWORD="${ADMIN_PASSWORD:-$DB_PASSWORD}" psql -h "$DB_HOST" -p "$DB_PORT" -U "$ADMIN_USER" -c "ALTER ROLE \"$DB_USER\" WITH LOGIN PASSWORD '$DB_PASSWORD' CREATEDB;" || echo "Warning: No se pudieron actualizar permisos"
            fi
            
            # Verificar conexión del usuario de Odoo
            if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "SELECT 1;" >/dev/null 2>&1; then
                echo "ERROR: El usuario $DB_USER aún no puede conectarse"
                exit 1
            fi
            echo "Usuario $DB_USER puede conectarse correctamente!"
        else
            echo "ERROR: Tampoco se puede conectar con el usuario admin"
            exit 1
        fi
    else
        echo "ERROR: Fallo de autenticación"
        exit 1
    fi
else
    echo "Conexión exitosa con usuario $DB_USER!"
fi

# Verificar/crear base de datos
echo "Verificando base de datos $DB_NAME..."
DB_EXISTS=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt 2>/dev/null | cut -d \| -f 1 | grep -w "$DB_NAME")

if [ -z "$DB_EXISTS" ]; then
    echo "Creando base de datos $DB_NAME..."
    if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -c "CREATE DATABASE \"$DB_NAME\";"; then
        echo "ERROR: No se pudo crear la base de datos"
        exit 1
    fi
    echo "Base de datos creada exitosamente!"
fi

# Verificar si está inicializada
echo "Verificando inicialización..."
DB_INITIALIZED=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name='ir_module_module');" 2>/dev/null || echo "f")

if [ "$DB_INITIALIZED" = "f" ]; then
    echo "Inicializando Odoo..."
    
    # Intentar inicialización con parámetros básicos
    echo "Comando de inicialización:"
    echo "python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d \"$DB_NAME\" -i base --stop-after-init --without-demo=all"
    
    if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i base --stop-after-init --without-demo=all; then
        echo "¡Inicialización exitosa!"
    else
        echo "ERROR: Falló la inicialización de Odoo"
        echo "Intentando diagnóstico..."
        
        # Diagnóstico básico
        echo "Test de conexión directo:"
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT current_user, current_database();"
        
        exit 1
    fi
else
    echo "La base de datos ya está inicializada"
fi

echo "Iniciando Odoo en modo normal..."
exec python3 /usr/bin/odoo -c /etc/odoo/odoo.conf
