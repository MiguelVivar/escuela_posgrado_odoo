#!/bin/bash

echo "🔍 DIAGNÓSTICO COMPLETO DE MÓDULOS EN RAILWAY"
echo "============================================="
echo "Fecha: $(date)"
echo

# Configurar variables
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

echo "📋 Variables de entorno:"
echo "  DB_HOST: $DB_HOST"
echo "  DB_PORT: $DB_PORT"
echo "  DB_USER: $DB_USER"
echo "  DB_NAME: $DB_NAME"
echo

echo "🔧 1. Verificando configuración actual de Odoo..."
echo "=================================================="
if [ -f "/etc/odoo/odoo.conf" ]; then
    echo "✅ Archivo de configuración encontrado:"
    cat /etc/odoo/odoo.conf
    echo
    
    echo "📁 Paths de addons configurados:"
    grep "addons_path" /etc/odoo/odoo.conf | cut -d'=' -f2 | tr ',' '\n' | while read path; do
        path=$(echo "$path" | xargs)  # Remover espacios
        if [ -d "$path" ]; then
            echo "  ✅ $path (existe)"
            echo "     Contenido:"
            ls -la "$path" | head -5
            echo "     ..."
        else
            echo "  ❌ $path (no existe)"
        fi
    done
else
    echo "❌ Archivo de configuración no encontrado"
fi
echo

echo "📦 2. Verificando módulos personalizados en /mnt/custom-addons..."
echo "================================================================="
if [ -d "/mnt/custom-addons" ]; then
    echo "✅ Directorio /mnt/custom-addons existe"
    echo "Contenido:"
    ls -la /mnt/custom-addons/
    echo
    
    echo "🔍 Detalles de cada módulo:"
    for module_dir in /mnt/custom-addons/*/; do
        if [ -d "$module_dir" ]; then
            module_name=$(basename "$module_dir")
            echo "  📁 $module_name:"
            echo "     Permisos: $(ls -ld "$module_dir" | awk '{print $1, $3, $4}')"
            
            if [ -f "$module_dir/__manifest__.py" ]; then
                echo "     ✅ __manifest__.py existe"
                echo "     Primeras líneas del manifest:"
                head -10 "$module_dir/__manifest__.py" | sed 's/^/       /'
            else
                echo "     ❌ __manifest__.py NO existe"
            fi
            
            if [ -f "$module_dir/__init__.py" ]; then
                echo "     ✅ __init__.py existe"
            else
                echo "     ❌ __init__.py NO existe"
            fi
            echo
        fi
    done
else
    echo "❌ Directorio /mnt/custom-addons NO existe"
fi
echo

echo "🗄️ 3. Verificando estado de módulos en la base de datos..."
echo "=========================================================="
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ Conexión a base de datos exitosa"
    
    echo "📊 Módulos personalizados en la base de datos:"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT 
        name,
        state,
        installable,
        auto_install,
        author,
        website
    FROM ir_module_module 
    WHERE name IN (
        'education_core', 'education_theme', 'education_attendances',
        'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
        'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
    )
    ORDER BY name;
    " || echo "❌ Error consultando módulos"
    
    echo
    echo "📈 Resumen de estados de módulos:"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT 
        state,
        COUNT(*) as cantidad
    FROM ir_module_module 
    WHERE name IN (
        'education_core', 'education_theme', 'education_attendances',
        'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
        'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
    )
    GROUP BY state
    ORDER BY state;
    " || echo "❌ Error consultando resumen de estados"
    
else
    echo "❌ No se puede conectar a la base de datos"
fi
echo

echo "🔄 4. Verificando si Odoo puede detectar los módulos..."
echo "======================================================"
echo "Intentando actualizar lista de módulos..."
if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" --update-modules-list --stop-after-init --log-level=info; then
    echo "✅ Lista de módulos actualizada exitosamente"
    
    echo "🔍 Verificando nuevamente el estado después de actualizar:"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT 
        name,
        state,
        installable
    FROM ir_module_module 
    WHERE name IN (
        'education_core', 'education_theme', 'education_attendances',
        'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
        'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
    )
    ORDER BY name;
    " || echo "❌ Error consultando módulos después de actualizar"
else
    echo "❌ Error actualizando lista de módulos"
fi
echo

echo "🔧 5. Verificando permisos y propietarios..."
echo "============================================"
echo "Permisos de directorios de addons:"
ls -ld /usr/lib/python3/dist-packages/odoo/addons/ 2>/dev/null || echo "  Standard addons: No accesible"
ls -ld /mnt/extra-addons/ 2>/dev/null || echo "  Extra addons: No existe"
ls -ld /mnt/custom-addons/ 2>/dev/null || echo "  Custom addons: No existe"

echo
echo "Usuario actual: $(whoami)"
echo "Grupos del usuario: $(groups)"
echo

echo "🚀 6. Recomendaciones basadas en el diagnóstico:"
echo "==============================================="

# Verificar si hay módulos no instalables
NOT_INSTALLABLE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
SELECT COUNT(*) 
FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
) AND installable = false;
" 2>/dev/null || echo "0")

UNINSTALLED=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
SELECT COUNT(*) 
FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
) AND state = 'uninstalled';
" 2>/dev/null || echo "0")

echo "📊 Módulos no instalables: $NOT_INSTALLABLE"
echo "📊 Módulos no instalados: $UNINSTALLED"

if [ "$NOT_INSTALLABLE" -gt 0 ]; then
    echo
    echo "⚠️  PROBLEMA DETECTADO: Algunos módulos no son instalables"
    echo "💡 SOLUCIÓN: Ejecutar script de corrección de módulos"
    echo "   Comando: railway run /usr/local/bin/fix-modules-railway.sh"
fi

if [ "$UNINSTALLED" -gt 0 ]; then
    echo
    echo "ℹ️  INFORMACIÓN: Hay módulos disponibles para instalar"
    echo "💡 SOLUCIÓN: Ejecutar instalador inteligente de módulos"
    echo "   Comando: railway run /usr/local/bin/smart-modules-installer.sh"
fi

echo
echo "✅ DIAGNÓSTICO COMPLETO FINALIZADO"
echo "=================================="
