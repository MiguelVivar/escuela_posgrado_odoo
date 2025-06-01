#!/bin/bash

# Script de instalación de módulos que se puede incluir en start.sh
install_custom_modules_improved() {
    echo "🚀 INSTALADOR MEJORADO DE MÓDULOS PERSONALIZADOS"
    echo "==============================================="
    
    # Verificar si existe el instalador inteligente
    if [ -f "/usr/local/bin/smart-modules-installer.sh" ]; then
        echo "✅ Usando instalador inteligente..."
        if /usr/local/bin/smart-modules-installer.sh; then
            echo "✅ Instalación inteligente completada exitosamente"
            return 0
        else
            echo "⚠️ Instalación inteligente falló, usando método tradicional..."
        fi
    else
        echo "ℹ️ Instalador inteligente no disponible, usando método tradicional..."
    fi
    
    # Método tradicional mejorado
    echo "📦 Iniciando instalación tradicional..."
    
    if [ ! -d "/mnt/custom-addons" ] || [ ! "$(ls -A /mnt/custom-addons)" ]; then
        echo "❌ No se encontraron módulos personalizados en /mnt/custom-addons"
        return 1
    fi
    
    echo "📋 Módulos encontrados:"
    ls -la /mnt/custom-addons/
    echo
    
    # Orden manual basado en dependencias
    local MODULE_ORDER=(
        "education_theme"
        "query_deluxe"
        "muk_web_colors"
        "muk_web_dialog"
        "muk_web_theme"
        "muk_web_chatter"
        "muk_web_appsbar"
        "om_hr_payroll"
        "education_core"
        "education_attendances"
    )
    
    local MODULES_TO_INSTALL=""
    local SUCCESS_COUNT=0
    
    for module_name in "${MODULE_ORDER[@]}"; do
        if [ -d "/mnt/custom-addons/$module_name" ] && [ -f "/mnt/custom-addons/$module_name/__manifest__.py" ]; then
            echo "🔍 Verificando: $module_name"
            
            # Verificar estado del módulo
            MODULE_STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "not_found")
            echo "  Estado: $MODULE_STATE"
            
            if [ "$MODULE_STATE" = "installed" ]; then
                echo "  ✅ Ya instalado"
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            elif [ "$MODULE_STATE" = "not_found" ] || [ "$MODULE_STATE" = "uninstalled" ]; then
                echo "  🚀 Instalando $module_name..."
                if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "$module_name" --stop-after-init --without-demo=all --log-level=info; then
                    echo "  ✅ Instalado exitosamente"
                    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
                else
                    echo "  ❌ Error en instalación"
                fi
            elif [ "$MODULE_STATE" = "to upgrade" ]; then
                echo "  ⬆️ Actualizando $module_name..."
                if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -u "$module_name" --stop-after-init --without-demo=all --log-level=info; then
                    echo "  ✅ Actualizado exitosamente"
                    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
                else
                    echo "  ❌ Error en actualización"
                fi
            fi
        fi
    done
    
    echo
    echo "📊 RESUMEN: $SUCCESS_COUNT módulos procesados exitosamente"
    
    if [ $SUCCESS_COUNT -gt 0 ]; then
        echo "✅ Instalación de módulos personalizados completada"
        return 0
    else
        echo "❌ No se pudo instalar ningún módulo"
        return 1
    fi
}

# Si se ejecuta directamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    install_custom_modules_improved
fi