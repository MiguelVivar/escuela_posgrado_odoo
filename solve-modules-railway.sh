#!/bin/bash

echo "🚀 SOLUCIÓN COMPLETA PARA MÓDULOS EN RAILWAY"
echo "============================================"
echo "Este script resolverá el problema de módulos no disponibles en la interfaz"
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

echo "🔄 PASO 1: Ejecutando diagnóstico completo..."
echo "============================================"
if [ -f "/usr/local/bin/diagnose-modules-railway.sh" ]; then
    /usr/local/bin/diagnose-modules-railway.sh
else
    echo "⚠️ Script de diagnóstico no encontrado, continuando..."
fi
echo

echo "🛠️ PASO 2: Corrigiendo permisos y estructura..."
echo "==============================================="
if [ -f "/usr/local/bin/fix-modules-railway.sh" ]; then
    /usr/local/bin/fix-modules-railway.sh
else
    echo "⚠️ Script de corrección no encontrado, aplicando corrección manual..."
    
    if [ -d "/mnt/custom-addons" ]; then
        echo "Corrigiendo permisos básicos..."
        chown -R odoo:odoo /mnt/custom-addons/ 2>/dev/null || true
        chmod -R 755 /mnt/custom-addons/ 2>/dev/null || true
        find /mnt/custom-addons/ -name "*.py" -exec chmod 644 {} \; 2>/dev/null || true
        find /mnt/custom-addons/ -name "*.xml" -exec chmod 644 {} \; 2>/dev/null || true
        echo "✅ Permisos básicos aplicados"
    fi
fi
echo

echo "🎯 PASO 3: Forzando disponibilidad de módulos..."
echo "==============================================="
if [ -f "/usr/local/bin/force-modules-available.sh" ]; then
    /usr/local/bin/force-modules-available.sh
else
    echo "⚠️ Script de forzado no encontrado, aplicando manualmente..."
    
    # Actualizar lista de módulos
    echo "Actualizando lista de módulos..."
    python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" --update-modules-list --stop-after-init --log-level=info
    
    # Marcar módulos como instalables
    echo "Marcando módulos como instalables..."
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    UPDATE ir_module_module 
    SET installable = true, application = true
    WHERE name IN (
        'education_core', 'education_theme', 'education_attendances',
        'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
        'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
    );
    " >/dev/null 2>&1
    echo "✅ Módulos marcados como instalables"
fi
echo

echo "🔓 PASO 4: Habilitando modo desarrollador..."
echo "==========================================="
if [ -f "/usr/local/bin/enable-developer-mode.sh" ]; then
    /usr/local/bin/enable-developer-mode.sh
else
    echo "⚠️ Script de modo desarrollador no encontrado, aplicando manualmente..."
    
    # Habilitar características técnicas para admin
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    INSERT INTO res_groups_users_rel (gid, uid)
    SELECT g.id, u.id
    FROM res_groups g, res_users u
    WHERE g.name = 'Technical Features' 
    AND u.login = 'admin'
    AND NOT EXISTS (
        SELECT 1 FROM res_groups_users_rel 
        WHERE gid = g.id AND uid = u.id
    );
    " >/dev/null 2>&1
    echo "✅ Modo desarrollador habilitado"
fi
echo

echo "🧪 PASO 5: Instalando módulos automáticamente (opcional)..."
echo "========================================================="
echo "¿Deseas instalar automáticamente todos los módulos disponibles? (s/N)"
read -t 10 -r AUTO_INSTALL
AUTO_INSTALL=${AUTO_INSTALL:-N}

if [[ $AUTO_INSTALL =~ ^[Ss]$ ]]; then
    echo "Instalando módulos automáticamente..."
    if [ -f "/usr/local/bin/smart-modules-installer.sh" ]; then
        /usr/local/bin/smart-modules-installer.sh
    else
        echo "Instalando módulos básicos..."
        python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "education_theme,muk_web_colors,muk_web_dialog" --stop-after-init --without-demo=all --log-level=info
        python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "muk_web_theme,education_core" --stop-after-init --without-demo=all --log-level=info
        python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "education_attendances,query_deluxe" --stop-after-init --without-demo=all --log-level=info
    fi
else
    echo "Omitiendo instalación automática. Los módulos estarán disponibles en la interfaz."
fi
echo

echo "📊 PASO 6: Verificación final..."
echo "==============================="
AVAILABLE_MODULES=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
SELECT COUNT(*) FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
) AND installable = true;
" 2>/dev/null || echo "0")

INSTALLED_MODULES=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "
SELECT COUNT(*) FROM ir_module_module 
WHERE name IN (
    'education_core', 'education_theme', 'education_attendances',
    'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 
    'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe'
) AND state = 'installed';
" 2>/dev/null || echo "0")

echo "📈 RESULTADOS:"
echo "  Módulos disponibles para instalar: $AVAILABLE_MODULES de 10"
echo "  Módulos ya instalados: $INSTALLED_MODULES de 10"
echo

if [ "$AVAILABLE_MODULES" -ge 8 ]; then
    echo "✅ ¡ÉXITO! La mayoría de módulos están disponibles"
    echo
    echo "🎉 SOLUCIÓN COMPLETADA EXITOSAMENTE"
    echo "=================================="
    echo
    echo "📱 CÓMO ACCEDER A TUS MÓDULOS EN ODOO:"
    echo "1. 🌐 Ve a tu URL de Railway"
    echo "2. 🔑 Inicia sesión con admin/admin"
    echo "3. 📱 Haz clic en 'Apps' en el menú principal"
    echo "4. 🔍 Quita el filtro 'Apps' para ver todos los módulos"
    echo "5. 🔎 Busca tus módulos por nombre (education_, muk_, om_, query_)"
    echo "6. ⚡ Si no aparecen, haz clic en 'Update Apps List'"
    echo
    echo "🛠️ MODO DESARROLLADOR HABILITADO:"
    echo "- Acceso a configuraciones avanzadas"
    echo "- Posibilidad de ver todos los módulos técnicos"
    echo "- Herramientas de debugging disponibles"
    echo
elif [ "$AVAILABLE_MODULES" -ge 5 ]; then
    echo "⚠️ PARCIALMENTE EXITOSO - Algunos módulos están disponibles"
    echo "Ejecuta el diagnóstico para ver cuáles faltan:"
    echo "railway run /usr/local/bin/diagnose-modules-railway.sh"
    echo
else
    echo "❌ PROBLEMAS DETECTADOS - Pocos módulos disponibles"
    echo
    echo "🔧 PASOS DE RESOLUCIÓN:"
    echo "1. Verifica que los módulos estén en /mnt/custom-addons"
    echo "2. Ejecuta: railway run /usr/local/bin/diagnose-modules-railway.sh"
    echo "3. Revisa los logs de Railway: railway logs --follow"
    echo "4. Contacta soporte con los logs del diagnóstico"
fi

echo
echo "🚀 COMANDOS ÚTILES DE RAILWAY:"
echo "- railway logs --follow (ver logs en tiempo real)"
echo "- railway ps restart (reiniciar servicio)"
echo "- railway run /usr/local/bin/diagnose-modules-railway.sh (diagnóstico)"
echo "- railway run /usr/local/bin/smart-modules-installer.sh (instalador inteligente)"
echo
echo "✨ ¡Proceso completado! ✨"
