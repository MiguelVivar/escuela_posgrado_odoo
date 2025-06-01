#!/bin/bash

# Script para instalar addons personalizados en Railway
set -e

echo "🚀 Iniciando instalación de addons personalizados en Railway..."

# Verificar que los directorios existen
if [ ! -d "/mnt/extra-addons" ]; then
    echo "❌ Error: Directorio /mnt/extra-addons no encontrado"
    exit 1
fi

# Listar addons disponibles
echo "📦 Addons personalizados disponibles:"
ls -la /mnt/extra-addons/

# Verificar permisos
echo "🔐 Verificando permisos..."
chown -R odoo:odoo /mnt/extra-addons
chmod -R 755 /mnt/extra-addons

# Instalar addons encontrados
ADDONS_LIST=""
for addon_dir in /mnt/extra-addons/*/; do
    if [ -d "$addon_dir" ] && [ -f "$addon_dir/__manifest__.py" ]; then
        addon_name=$(basename "$addon_dir")
        echo "✅ Addon encontrado: $addon_name"
        if [ -z "$ADDONS_LIST" ]; then
            ADDONS_LIST="$addon_name"
        else
            ADDONS_LIST="$ADDONS_LIST,$addon_name"
        fi
    fi
done

if [ -n "$ADDONS_LIST" ]; then
    echo "🔧 Instalando addons: $ADDONS_LIST"
    # Actualizar la base de datos con los nuevos addons
    exec odoo -c /etc/odoo/odoo.conf -d $DATABASE_URL -u "$ADDONS_LIST" --stop-after-init
else
    echo "⚠️  No se encontraron addons para instalar"
fi

echo "✅ Instalación de addons completada"
