#!/bin/bash

echo "🧪 TESTING INSTALACIÓN DE MÓDULOS EN RAILWAY"
echo "============================================="
echo "Fecha: $(date)"
echo

# Este script puedes ejecutarlo en Railway con:
# railway run /usr/local/bin/test-modules-fix.sh

# Configurar variables de conexión
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

echo "1️⃣ VERIFICANDO CONEXIÓN A BASE DE DATOS"
echo "========================================="
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ Conexión exitosa"
else
    echo "❌ Error de conexión"
    exit 1
fi

echo
echo "2️⃣ VERIFICANDO DIRECTORIO DE MÓDULOS"
echo "===================================="
if [ -d "/mnt/custom-addons" ]; then
    echo "✅ Directorio /mnt/custom-addons existe"
    echo "📋 Contenido:"
    ls -la /mnt/custom-addons/
    
    echo
    echo "🔍 Módulos con manifest:"
    for module_path in /mnt/custom-addons/*/; do
        if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
            module_name=$(basename "$module_path")
            echo "  ✓ $module_name"
        fi
    done
else
    echo "❌ Directorio no existe"
    exit 1
fi

echo
echo "3️⃣ VERIFICANDO ESTADO ACTUAL DE MÓDULOS"
echo "========================================"
MODULES=("education_theme" "education_core" "education_attendances" "muk_web_theme" "om_hr_payroll" "query_deluxe")

for module in "${MODULES[@]}"; do
    if [ -d "/mnt/custom-addons/$module" ]; then
        STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module';" 2>/dev/null || echo "not_found")
        echo "$module: $STATE"
    else
        echo "$module: not_available"
    fi
done

echo
echo "4️⃣ EJECUTANDO INSTALADOR MEJORADO"
echo "=================================="
if [ -f "/usr/local/bin/modules-installer-function.sh" ]; then
    echo "✅ Script de función encontrado"
    source /usr/local/bin/modules-installer-function.sh
    install_custom_modules_improved
else
    echo "⚠️ Script de función no encontrado, ejecutando instalador inteligente"
    if [ -f "/usr/local/bin/smart-modules-installer.sh" ]; then
        /usr/local/bin/smart-modules-installer.sh
    else
        echo "❌ Ningún instalador disponible"
    fi
fi

echo
echo "5️⃣ VERIFICANDO RESULTADO FINAL"
echo "==============================="
for module in "${MODULES[@]}"; do
    if [ -d "/mnt/custom-addons/$module" ]; then
        FINAL_STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module';" 2>/dev/null || echo "not_found")
        if [ "$FINAL_STATE" = "installed" ]; then
            echo "✅ $module: INSTALADO"
        else
            echo "⚠️ $module: $FINAL_STATE"
        fi
    fi
done

echo
echo "🎯 TESTING COMPLETADO"
echo "Para ver logs completos: railway logs --follow"
