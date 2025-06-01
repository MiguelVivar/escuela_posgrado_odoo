#!/bin/bash

# Script para instalar módulos personalizados en Odoo
# Este script puede ser ejecutado independientemente para instalar módulos después del despliegue

echo "=== Instalador de Módulos Personalizados para Odoo ==="

# Configurar variables de entorno
DB_HOST="${DB_HOST:-${PGHOST:-localhost}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

echo "Configuración de base de datos:"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"
echo "DB_NAME: $DB_NAME"

# Verificar conexión a la base de datos
echo "Verificando conexión a la base de datos..."
if ! PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "Error: No se puede conectar a la base de datos"
    exit 1
fi
echo "Conexión a la base de datos verificada!"

# Verificar que el directorio de módulos personalizados existe
if [ ! -d "/mnt/custom-addons" ]; then
    echo "Error: El directorio /mnt/custom-addons no existe"
    exit 1
fi

# Buscar módulos personalizados
echo "Buscando módulos personalizados en /mnt/custom-addons..."
CUSTOM_MODULES=""
MODULE_COUNT=0

for module_path in /mnt/custom-addons/*/; do
  if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
    module_name=$(basename "$module_path")
    echo "Módulo encontrado: $module_name"
    
    # Verificar si el módulo ya está instalado
    INSTALLED=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "")
    
    if [ "$INSTALLED" = "installed" ]; then
      echo "  -> Ya instalado, actualizando..."
      if [ -z "$CUSTOM_MODULES" ]; then
        CUSTOM_MODULES="$module_name"
      else
        CUSTOM_MODULES="$CUSTOM_MODULES,$module_name"
      fi
    elif [ "$INSTALLED" = "to upgrade" ] || [ "$INSTALLED" = "to install" ]; then
      echo "  -> Pendiente de instalación/actualización"
      if [ -z "$CUSTOM_MODULES" ]; then
        CUSTOM_MODULES="$module_name"
      else
        CUSTOM_MODULES="$CUSTOM_MODULES,$module_name"
      fi
    else
      echo "  -> No instalado, agregando a la lista"
      if [ -z "$CUSTOM_MODULES" ]; then
        CUSTOM_MODULES="$module_name"
      else
        CUSTOM_MODULES="$CUSTOM_MODULES,$module_name"
      fi
    fi
    MODULE_COUNT=$((MODULE_COUNT + 1))
  fi
done

if [ $MODULE_COUNT -eq 0 ]; then
    echo "No se encontraron módulos personalizados válidos"
    exit 0
fi

if [ -z "$CUSTOM_MODULES" ]; then
    echo "No hay módulos para instalar o actualizar"
    exit 0
fi

echo "Módulos a procesar: $CUSTOM_MODULES"

# Generar configuración temporal de Odoo
echo "Generando configuración temporal..."
cat > /tmp/odoo_install.conf << EOF
[options]
addons_path = /usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons,/mnt/custom-addons
admin_passwd = admin
db_host = $DB_HOST
db_port = $DB_PORT
db_user = $DB_USER
db_password = $DB_PASSWORD
db_name = $DB_NAME
log_level = info
workers = 0
max_cron_threads = 0
limit_request = 8192
proxy_mode = True
EOF

# Instalar/actualizar módulos
echo "Instalando/actualizando módulos personalizados..."
if python3 /usr/bin/odoo -c /tmp/odoo_install.conf -d "$DB_NAME" -i "$CUSTOM_MODULES" --stop-after-init --without-demo=all --log-level=info; then
    echo "¡Módulos procesados exitosamente!"
    
    # Actualizar módulos que puedan necesitar actualización
    echo "Verificando actualizaciones pendientes..."
    if python3 /usr/bin/odoo -c /tmp/odoo_install.conf -d "$DB_NAME" -u "$CUSTOM_MODULES" --stop-after-init --without-demo=all --log-level=info; then
        echo "¡Actualizaciones aplicadas exitosamente!"
    else
        echo "Advertencia: Algunas actualizaciones podrían no haberse aplicado correctamente"
    fi
else
    echo "Error: Falló la instalación de algunos módulos"
    exit 1
fi

# Limpiar archivo temporal
rm -f /tmp/odoo_install.conf

echo "=== Proceso completado ==="
