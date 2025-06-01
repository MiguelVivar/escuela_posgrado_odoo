#!/bin/bash

# Script mejorado para instalar módulos personalizados con manejo de dependencias
echo "=== INSTALADOR DE MÓDULOS PERSONALIZADOS CON DEPENDENCIAS ==="

# Configurar variables
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

# Función para obtener dependencias de un módulo
get_module_dependencies() {
    local module_path="$1"
    local manifest_file="$module_path/__manifest__.py"
    
    if [ -f "$manifest_file" ]; then
        # Extraer dependencias del archivo manifest
        python3 -c "
import ast
try:
    with open('$manifest_file', 'r') as f:
        content = f.read()
        manifest = ast.literal_eval(content)
        deps = manifest.get('depends', [])
        # Filtrar solo dependencias que están en nuestros módulos personalizados
        custom_deps = []
        for dep in deps:
            if dep in ['education_core', 'education_theme', 'education_attendances', 'muk_web_theme', 'muk_web_appsbar', 'muk_web_chatter', 'muk_web_colors', 'muk_web_dialog', 'om_hr_payroll', 'query_deluxe']:
                custom_deps.append(dep)
        print(','.join(custom_deps))
except:
    print('')
"
    fi
}

# Función para instalar módulos en orden correcto de dependencias
install_modules_with_dependencies() {
    local modules_dir="/mnt/custom-addons"
    
    echo "Iniciando instalación de módulos personalizados..."
    
    if [ ! -d "$modules_dir" ] || [ ! "$(ls -A $modules_dir)" ]; then
        echo "No se encontraron módulos personalizados en $modules_dir"
        return 0
    fi
    
    echo "Módulos encontrados en $modules_dir:"
    ls -la "$modules_dir"
    echo
    
    # Definir orden manual basado en dependencias conocidas
    # Este orden respeta las dependencias: theme -> core -> attendances, y muk modules independientes
    local install_order=(
        "education_theme"      # No depende de otros módulos personalizados
        "query_deluxe"         # Solo depende de base, mail
        "muk_web_colors"       # Base para otros muk modules
        "muk_web_dialog"       # Puede depender de colors
        "muk_web_theme"        # Puede depender de colors y dialog
        "muk_web_chatter"      # Puede depender de theme
        "muk_web_appsbar"      # Puede depender de theme
        "om_hr_payroll"        # Módulo independiente
        "education_core"       # Depende de education_theme
        "education_attendances" # Depende de education_core
    )
    
    echo "Orden de instalación definido:"
    for i in "${!install_order[@]}"; do
        echo "  $((i+1)). ${install_order[i]}"
    done
    echo
    
    # Verificar qué módulos están realmente disponibles
    local available_modules=()
    for module_name in "${install_order[@]}"; do
        if [ -d "$modules_dir/$module_name" ] && [ -f "$modules_dir/$module_name/__manifest__.py" ]; then
            available_modules+=("$module_name")
            echo "✓ Módulo disponible: $module_name"
        else
            echo "⚠ Módulo no encontrado: $module_name"
        fi
    done
    
    echo
    echo "Módulos disponibles para instalación: ${#available_modules[@]}"
    
    if [ ${#available_modules[@]} -eq 0 ]; then
        echo "No se encontraron módulos válidos para instalar"
        return 0
    fi
    
    # Instalar módulos uno por uno en orden
    local successful_installs=()
    local failed_installs=()
    
    for module_name in "${available_modules[@]}"; do
        echo "=== Procesando módulo: $module_name ==="
        
        # Verificar estado actual del módulo
        MODULE_STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "not_found")
        echo "Estado actual: $MODULE_STATE"
        
        if [ "$MODULE_STATE" = "installed" ]; then
            echo "✓ Módulo ya está instalado - omitiendo"
            successful_installs+=("$module_name")
            continue
        fi
        
        if [ "$MODULE_STATE" = "not_found" ] || [ "$MODULE_STATE" = "uninstalled" ] || [ "$MODULE_STATE" = "to install" ]; then
            echo "Instalando módulo: $module_name"
            
            # Intentar instalación
            if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "$module_name" --stop-after-init --without-demo=all --log-level=info; then
                echo "✅ $module_name instalado exitosamente"
                successful_installs+=("$module_name")
            else
                echo "❌ Error instalando $module_name"
                failed_installs+=("$module_name")
                
                # Continuar con el siguiente módulo en lugar de abortar
                echo "Continuando con el siguiente módulo..."
            fi
        elif [ "$MODULE_STATE" = "to upgrade" ]; then
            echo "Actualizando módulo: $module_name"
            
            if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -u "$module_name" --stop-after-init --without-demo=all --log-level=info; then
                echo "✅ $module_name actualizado exitosamente"
                successful_installs+=("$module_name")
            else
                echo "❌ Error actualizando $module_name"
                failed_installs+=("$module_name")
            fi
        fi
        
        echo
    done
    
    # Resumen final
    echo "=== RESUMEN DE INSTALACIÓN ==="
    echo "Módulos instalados exitosamente (${#successful_installs[@]}):"
    for module in "${successful_installs[@]}"; do
        echo "  ✅ $module"
    done
    
    if [ ${#failed_installs[@]} -gt 0 ]; then
        echo
        echo "Módulos que fallaron (${#failed_installs[@]}):"
        for module in "${failed_installs[@]}"; do
            echo "  ❌ $module"
        done
    fi
    
    echo
    echo "Verificando estado final de todos los módulos..."
    
    for module_name in "${available_modules[@]}"; do
        FINAL_STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "not_found")
        if [ "$FINAL_STATE" = "installed" ]; then
            echo "✅ $module_name: INSTALADO"
        else
            echo "⚠️ $module_name: $FINAL_STATE"
        fi
    done
    
    # Devolver código de éxito si al menos un módulo se instaló
    if [ ${#successful_installs[@]} -gt 0 ]; then
        echo
        echo "✅ Instalación completada - ${#successful_installs[@]} módulos instalados"
        return 0
    else
        echo
        echo "❌ No se pudo instalar ningún módulo"
        return 1
    fi
}

# Si el script se ejecuta directamente, llamar a la función principal
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    install_modules_with_dependencies "$@"
fi
