#!/bin/bash

echo "🔧 FORZAR DISPONIBILIDAD DE MÓDULOS EN INTERFAZ ODOO"
echo "==================================================="
echo "Fecha: $(date)"
echo

# Configurar variables
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

echo "🛠️ 1. Verificando y corrigiendo permisos de archivos..."
echo "======================================================="
if [ -d "/mnt/custom-addons" ]; then
    echo "✅ Corrigiendo permisos de /mnt/custom-addons..."
    chown -R odoo:odoo /mnt/custom-addons/ 2>/dev/null || echo "⚠️ No se pudieron cambiar los propietarios (puede ser normal en Railway)"
    chmod -R 755 /mnt/custom-addons/ 2>/dev/null || echo "⚠️ No se pudieron cambiar los permisos (puede ser normal en Railway)"
    
    # Asegurar que los archivos Python y XML tienen permisos correctos
    find /mnt/custom-addons/ -name "*.py" -exec chmod 644 {} \; 2>/dev/null || true
    find /mnt/custom-addons/ -name "*.xml" -exec chmod 644 {} \; 2>/dev/null || true
    find /mnt/custom-addons/ -name "*.csv" -exec chmod 644 {} \; 2>/dev/null || true
    
    echo "✅ Permisos corregidos"
else
    echo "❌ Directorio /mnt/custom-addons no existe"
    exit 1
fi
echo

echo "🔍 2. Verificando estructura de módulos..."
echo "=========================================="
for module_dir in /mnt/custom-addons/*/; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "📁 Verificando módulo: $module_name"
        
        if [ ! -f "$module_dir/__manifest__.py" ]; then
            echo "   ❌ Falta __manifest__.py"
        else
            echo "   ✅ __manifest__.py presente"
        fi
        
        if [ ! -f "$module_dir/__init__.py" ]; then
            echo "   ❌ Falta __init__.py"
        else
            echo "   ✅ __init__.py presente"
        fi
    fi
done
echo

echo "🔄 3. Forzando actualización de lista de módulos en Odoo..."
echo "=========================================================="
echo "Ejecutando actualización de módulos..."
if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" --update-modules-list --stop-after-init --log-level=info; then
    echo "✅ Lista de módulos actualizada exitosamente"
else
    echo "❌ Error actualizando lista de módulos"
    echo "Intentando con modo de desarrollo..."
    if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" --update-modules-list --stop-after-init --log-level=debug --dev=all; then
        echo "✅ Lista de módulos actualizada en modo desarrollo"
    else
        echo "❌ Error incluso en modo desarrollo"
    fi
fi
echo

echo "🗄️ 4. Verificando módulos en la base de datos..."
echo "==============================================="
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ Conexión a base de datos exitosa"
    
    echo "📊 Estado actual de módulos personalizados:"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT 
        name,
        state,
        CASE 
            WHEN installable THEN 'Sí' 
            ELSE 'No' 
        END as instalable,
        CASE 
            WHEN auto_install THEN 'Sí' 
            ELSE 'No' 
        END as auto_instalar
    FROM ir_module_module 
    WHERE name IN (
        'education_core', 'education_theme', 'education_attendances',
        'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
        'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
    )
    ORDER BY name;
    "
else
    echo "❌ No se puede conectar a la base de datos"
    exit 1
fi
echo

echo "🔧 5. Marcando módulos como instalables si no lo están..."
echo "========================================================"
MODULES_TO_FIX=("education_core" "education_theme" "education_attendances" "muk_web_theme" "muk_web_appsbar" "muk_web_chatter" "muk_web_colors" "muk_web_dialog" "om_hr_payroll" "query_deluxe")

for module_name in "${MODULES_TO_FIX[@]}"; do
    echo "🔍 Verificando módulo: $module_name"
    
    # Verificar si el módulo existe en la tabla
    MODULE_EXISTS=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
    SELECT COUNT(*) FROM ir_module_module WHERE name='$module_name';
    " 2>/dev/null || echo "0")
    
    if [ "$MODULE_EXISTS" = "0" ]; then
        echo "   ⚠️ Módulo no encontrado en la base de datos"
        continue
    fi
    
    # Verificar si es instalable
    IS_INSTALLABLE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
    SELECT installable FROM ir_module_module WHERE name='$module_name';
    " 2>/dev/null || echo "f")
    
    if [ "$IS_INSTALLABLE" = "f" ]; then
        echo "   🔧 Marcando como instalable..."
        PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        UPDATE ir_module_module 
        SET installable = true 
        WHERE name='$module_name';
        " >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "   ✅ Módulo marcado como instalable"
        else
            echo "   ❌ Error marcando módulo como instalable"
        fi
    else
        echo "   ✅ Módulo ya es instalable"
    fi
done
echo

echo "🚀 6. Reiniciando servicio de Odoo para aplicar cambios..."
echo "========================================================"
echo "⚠️ IMPORTANTE: Después de ejecutar este script, será necesario reiniciar el servicio de Odoo"
echo "En Railway, esto se hace automáticamente con un nuevo deploy o reinicio del servicio"
echo

echo "📋 7. Estado final de módulos:"
echo "=============================="
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
SELECT 
    name,
    state,
    CASE 
        WHEN installable THEN 'Sí' 
        ELSE 'No' 
    END as instalable
FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
)
ORDER BY name;
"

echo
echo "✅ PROCESO COMPLETADO"
echo "===================="
echo "📝 PRÓXIMOS PASOS:"
echo "1. Si estás en Railway, haz un redeploy del servicio"
echo "2. Accede a la interfaz web de Odoo"
echo "3. Ve a Apps/Aplicaciones"
echo "4. Quita el filtro 'Apps' y busca tus módulos personalizados"
echo "5. Los módulos deberían aparecer disponibles para instalar"
echo
echo "💡 Si los módulos siguen sin aparecer:"
echo "1. En la interfaz web, ve a Apps"
echo "2. Haz clic en 'Update Apps List' (Actualizar lista de aplicaciones)"
echo "3. Busca tus módulos por nombre"
echo
echo "🎯 COMANDOS ÚTILES PARA RAILWAY:"
echo "- railway logs --follow (para ver logs en tiempo real)"
echo "- railway ps restart (para reiniciar el servicio)"
