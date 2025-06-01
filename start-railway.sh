#!/bin/bash

# Script optimizado para iniciar Odoo en Railway con soporte para addons personalizados
set -e

echo "🚀 Iniciando Odoo en Railway..."

# Instalar dependencias opcionales si están definidas en variables de entorno
if [ "$INSTALL_OPTIONAL_DEPS" = "true" ]; then
    echo "🔧 Instalando dependencias opcionales..."
    pip3 install --no-cache-dir num2words qrcode || echo "⚠️ Algunas dependencias opcionales fallaron"
fi

# Variables de entorno
DB_HOST=${DATABASE_HOST:-$DB_HOST}
DB_PORT=${DATABASE_PORT:-5432}
DB_USER=${DATABASE_USER:-$DB_USER}
DB_PASSWORD=${DATABASE_PASSWORD:-$DB_PASSWORD}
DB_NAME=${DATABASE_NAME:-$DB_NAME}

# Si no tenemos las variables de Railway, usar las del .conf
if [ -z "$DB_HOST" ]; then
    echo "📝 Usando configuración del archivo odoo.conf"
    exec odoo -c /etc/odoo/odoo.conf
else
    echo "🌐 Usando variables de entorno de Railway"
    echo "Database Host: $DB_HOST"
    echo "Database Port: $DB_PORT"
    echo "Database User: $DB_USER"
    echo "Database Name: $DB_NAME"
    
    # Verificar conexión a la base de datos
    echo "🔍 Verificando conexión a la base de datos..."
    until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
        echo "⏳ Esperando a que la base de datos esté disponible..."
        sleep 2
    done
    
    echo "✅ Base de datos disponible"
    
    # Verificar si la base de datos existe, si no, crearla
    if ! psql "postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/postgres" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        echo "🏗️  Creando base de datos $DB_NAME..."
        createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME"
    fi
    
    # Ejecutar Odoo con configuración dinámica
    exec odoo \
        --addons-path="/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons" \
        --data-dir="/var/lib/odoo" \
        --db_host="$DB_HOST" \
        --db_port="$DB_PORT" \
        --db_user="$DB_USER" \
        --db_password="$DB_PASSWORD" \
        --database="$DB_NAME" \
        --proxy-mode \
        --workers=2 \
        --max-cron-threads=1 \
        --log-level=info \
        --without-demo=all \
        --list-db=False
fi
