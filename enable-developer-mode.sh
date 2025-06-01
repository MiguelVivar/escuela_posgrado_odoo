#!/bin/bash

echo "🎯 HABILITANDO MODO DESARROLLADOR Y MÓDULOS PERSONALIZADOS"
echo "=========================================================="
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

echo "🔧 1. Habilitando modo desarrollador en Odoo..."
echo "==============================================="
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ Conexión a base de datos exitosa"
    
    # Habilitar modo desarrollador para el usuario admin
    echo "🔓 Habilitando modo desarrollador..."
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    UPDATE res_users 
    SET groups_id = groups_id || (
        SELECT ARRAY[id] FROM res_groups WHERE name = 'Technical Features'
    )
    WHERE login = 'admin';
    " >/dev/null 2>&1
    
    # Alternativa: insertar directamente en la tabla de configuración
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    INSERT INTO ir_config_parameter (key, value, create_uid, create_date, write_uid, write_date)
    VALUES ('base.group_no_one', 'True', 1, NOW(), 1, NOW())
    ON CONFLICT (key) DO UPDATE SET value = 'True', write_date = NOW();
    " >/dev/null 2>&1
    
    echo "✅ Modo desarrollador habilitado"
else
    echo "❌ No se puede conectar a la base de datos"
    exit 1
fi
echo

echo "📦 2. Forzando actualización de lista de aplicaciones..."
echo "======================================================"
# Eliminar caché de módulos para forzar redetección
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
DELETE FROM ir_module_module_dependency 
WHERE module_id IN (
    SELECT id FROM ir_module_module 
    WHERE name IN (
        'education_core', 'education_theme', 'education_attendances',
        'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
        'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
    )
);
" >/dev/null 2>&1

# Eliminar registros de módulos para que sean redetectados
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
DELETE FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
) AND state = 'uninstalled';
" >/dev/null 2>&1

echo "🔄 Ejecutando actualización completa de lista de módulos..."
if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" --update-modules-list --stop-after-init --log-level=info; then
    echo "✅ Lista de módulos actualizada exitosamente"
else
    echo "❌ Error actualizando lista de módulos, intentando con más verbose..."
    python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" --update-modules-list --stop-after-init --log-level=debug --dev=all
fi
echo

echo "🔍 3. Verificando módulos detectados..."
echo "======================================"
DETECTED_MODULES=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
SELECT COUNT(*) FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
);
" 2>/dev/null || echo "0")

echo "📊 Módulos personalizados detectados: $DETECTED_MODULES de 10"

if [ "$DETECTED_MODULES" -lt 10 ]; then
    echo "⚠️ No todos los módulos fueron detectados. Verificando estructura..."
    
    for module_name in education_core education_theme education_attendances muk_web_theme muk_web_appsbar muk_web_chatter muk_web_colors muk_web_dialog om_hr_payroll query_deluxe; do
        if [ -d "/mnt/custom-addons/$module_name" ] && [ -f "/mnt/custom-addons/$module_name/__manifest__.py" ]; then
            MODULE_IN_DB=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
            SELECT COUNT(*) FROM ir_module_module WHERE name='$module_name';
            " 2>/dev/null || echo "0")
            
            if [ "$MODULE_IN_DB" = "0" ]; then
                echo "❌ $module_name: Existe en disco pero NO en base de datos"
            else
                echo "✅ $module_name: Detectado correctamente"
            fi
        else
            echo "❌ $module_name: NO existe en disco"
        fi
    done
fi
echo

echo "🛠️ 4. Configurando módulos para ser visibles en la interfaz..."
echo "============================================================="
# Asegurar que todos los módulos detectados sean instalables y visibles
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
UPDATE ir_module_module 
SET 
    installable = true,
    application = true,
    auto_install = false
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
);
" >/dev/null 2>&1

echo "✅ Módulos configurados como aplicaciones instalables"
echo

echo "🎯 5. Habilitando filtros técnicos en Apps..."
echo "============================================="
# Asegurar que se muestren todos los módulos, no solo aplicaciones
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
INSERT INTO ir_config_parameter (key, value, create_uid, create_date, write_uid, write_date)
VALUES ('base.module_uninstall', 'True', 1, NOW(), 1, NOW())
ON CONFLICT (key) DO UPDATE SET value = 'True', write_date = NOW();
" >/dev/null 2>&1

echo "✅ Filtros técnicos habilitados"
echo

echo "📋 6. Estado final de módulos personalizados:"
echo "============================================="
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
SELECT 
    name,
    state,
    CASE WHEN installable THEN 'Sí' ELSE 'No' END as instalable,
    CASE WHEN application THEN 'Sí' ELSE 'No' END as aplicacion,
    summary
FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
)
ORDER BY name;
"

echo
echo "✅ CONFIGURACIÓN COMPLETADA"
echo "=========================="
echo "📝 INSTRUCCIONES PARA ACCEDER A LOS MÓDULOS:"
echo
echo "1. 🌐 Accede a tu instancia de Odoo en Railway"
echo "2. 🔑 Inicia sesión como administrador (admin/admin)"
echo "3. 🛠️ Activa el modo desarrollador:"
echo "   - Ve a Configuración > Usuarios y Compañías > Usuarios"
echo "   - Edita el usuario admin"
echo "   - En la pestaña 'Derechos de acceso', marca 'Características Técnicas'"
echo "   - Guarda los cambios"
echo
echo "4. 📱 Ve a la sección 'Apps' (Aplicaciones)"
echo "5. 🔍 Quita todos los filtros (especialmente 'Apps')"
echo "6. 🔎 Busca por el nombre de tus módulos:"
echo "   - education_core"
echo "   - education_theme" 
echo "   - education_attendances"
echo "   - muk_web_* (módulos de tema)"
echo "   - om_hr_payroll"
echo "   - query_deluxe"
echo
echo "7. ⚡ Si no aparecen, haz clic en 'Update Apps List'"
echo
echo "💡 NOTA: Después de ejecutar este script, reinicia el servicio de Odoo en Railway"
echo "🚀 Comando Railway: railway ps restart"
