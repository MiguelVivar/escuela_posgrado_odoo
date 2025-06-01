#!/bin/bash

echo "🚀 EJECUTANDO COMANDO DE TESTING EN RAILWAY"
echo "============================================="
echo "Fecha: $(date)"
echo

# Configurar variables de conexión
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

echo "📋 Variables de conexión:"
echo "  DB_HOST: $DB_HOST"
echo "  DB_PORT: $DB_PORT"
echo "  DB_USER: $DB_USER"
echo "  DB_NAME: $DB_NAME"
echo

# Ejecutar el debug de módulos
echo "🔍 Ejecutando debug de módulos personalizados..."
echo "================================================"

if [ -f "/usr/local/bin/debug-modules-railway.sh" ]; then
    echo "✅ Script de debug encontrado - ejecutando..."
    /usr/local/bin/debug-modules-railway.sh
else
    echo "❌ Script de debug no encontrado"
    echo "Archivos disponibles en /usr/local/bin/:"
    ls -la /usr/local/bin/ | grep -E "\.(sh|py)$"
fi

echo
echo "🛠️ Ejecutando instalador inteligente de módulos..."
echo "=================================================="

if [ -f "/usr/local/bin/smart-modules-installer.sh" ]; then
    echo "✅ Instalador inteligente encontrado - ejecutando..."
    /usr/local/bin/smart-modules-installer.sh
else
    echo "❌ Instalador inteligente no encontrado"
    
    echo "Intentando instalación manual básica..."
    
    if [ -d "/mnt/custom-addons" ] && [ "$(ls -A /mnt/custom-addons)" ]; then
        echo "📦 Contenido de /mnt/custom-addons:"
        ls -la /mnt/custom-addons/
        echo
        
        echo "🔍 Módulos encontrados:"
        for module_path in /mnt/custom-addons/*/; do
            if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
                module_name=$(basename "$module_path")
                echo "  ✓ $module_name"
                
                # Verificar estado
                MODULE_STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "not_found")
                echo "    Estado: $MODULE_STATE"
                
                if [ "$MODULE_STATE" = "not_found" ] || [ "$MODULE_STATE" = "uninstalled" ]; then
                    echo "    🚀 Intentando instalación manual..."
                    if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "$module_name" --stop-after-init --without-demo=all --log-level=info; then
                        echo "    ✅ Instalado exitosamente"
                    else
                        echo "    ❌ Error en instalación"
                    fi
                fi
            fi
        done
    else
        echo "❌ No se encontraron módulos en /mnt/custom-addons"
    fi
fi

echo
echo "📊 RESUMEN FINAL"
echo "================"

echo "🔍 Estado final de módulos:"
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT name, state FROM ir_module_module WHERE name IN ('education_core', 'education_theme', 'education_attendances', 'muk_web_theme', 'om_hr_payroll', 'query_deluxe') ORDER BY name;" 2>/dev/null; then
    echo "✅ Consulta de estado exitosa"
else
    echo "❌ Error consultando estado de módulos"
fi

echo
echo "🎯 COMANDO COMPLETADO"
echo "Para ver logs completos ejecuta: railway logs --follow"
