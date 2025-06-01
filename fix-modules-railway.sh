#!/bin/bash

echo "=== Script de corrección para módulos de Odoo ==="

# Verificar estructura de directorios
echo "1. Verificando estructura de directorios de addons..."
ls -la /usr/lib/python3/dist-packages/odoo/addons/ | head -10
echo "..."
echo ""

echo "2. Verificando addons extra..."
if [ -d "/mnt/extra-addons" ]; then
    ls -la /mnt/extra-addons/
else
    echo "Directorio /mnt/extra-addons no existe"
fi
echo ""

echo "3. Verificando addons personalizados..."
if [ -d "/mnt/custom-addons" ]; then
    ls -la /mnt/custom-addons/
else
    echo "Directorio /mnt/custom-addons no existe"
fi
echo ""

# Verificar permisos
echo "4. Verificando permisos de directorios..."
ls -ld /mnt/custom-addons/
if [ -d "/mnt/custom-addons/om_hr_payroll" ]; then
    ls -ld /mnt/custom-addons/om_hr_payroll/
    ls -ld /mnt/custom-addons/om_hr_payroll/data/
    ls -la /mnt/custom-addons/om_hr_payroll/data/ | grep hr_payroll_sequence.xml
fi
echo ""

# Verificar configuración de addons_path
echo "5. Verificando configuración de addons_path..."
grep "addons_path" /etc/odoo/odoo.conf
echo ""

# Función para reparar permisos
fix_permissions() {
    echo "6. Reparando permisos..."
    chown -R odoo:odoo /mnt/custom-addons/ 2>/dev/null || true
    chmod -R 755 /mnt/custom-addons/ 2>/dev/null || true
    
    # Permisos específicos para archivos XML
    find /mnt/custom-addons/ -name "*.xml" -exec chmod 644 {} \; 2>/dev/null || true
    find /mnt/custom-addons/ -name "*.py" -exec chmod 644 {} \; 2>/dev/null || true
    
    echo "Permisos reparados"
}

# Función para verificar integridad de módulos
verify_module_integrity() {
    echo "7. Verificando integridad de módulos..."
    
    for module_dir in /mnt/custom-addons/*/; do
        if [ -d "$module_dir" ]; then
            module_name=$(basename "$module_dir")
            echo "Verificando módulo: $module_name"
            
            # Verificar __manifest__.py
            if [ ! -f "$module_dir/__manifest__.py" ]; then
                echo "  ✗ Falta __manifest__.py"
                continue
            else
                echo "  ✓ __manifest__.py existe"
            fi
            
            # Verificar __init__.py
            if [ ! -f "$module_dir/__init__.py" ]; then
                echo "  ✗ Falta __init__.py"
                continue
            else
                echo "  ✓ __init__.py existe"
            fi
            
            # Verificar archivos de datos mencionados en manifest
            if [ -f "$module_dir/__manifest__.py" ]; then
                echo "  Verificando archivos de datos del manifest..."
                python3 -c "
import sys
sys.path.insert(0, '$module_dir')
try:
    import imp
    spec = imp.load_source('manifest', '$module_dir/__manifest__.py')
    manifest = eval(open('$module_dir/__manifest__.py').read())
    data_files = manifest.get('data', [])
    for data_file in data_files:
        file_path = '$module_dir/' + data_file
        import os
        if os.path.exists(file_path):
            print(f'    ✓ {data_file}')
        else:
            print(f'    ✗ {data_file} - FALTA')
except Exception as e:
    print(f'    Error leyendo manifest: {e}')
"
            fi
            echo ""
        fi
    done
}

# Ejecutar funciones de reparación
fix_permissions
verify_module_integrity

# Función específica para om_hr_payroll
fix_om_hr_payroll() {
    echo "8. Verificación específica de om_hr_payroll..."
    
    if [ -d "/mnt/custom-addons/om_hr_payroll" ]; then
        echo "Módulo om_hr_payroll encontrado"
        
        # Verificar archivo específico del error
        if [ -f "/mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml" ]; then
            echo "✓ Archivo hr_payroll_sequence.xml existe"
            echo "Contenido del archivo:"
            cat /mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml
        else
            echo "✗ Archivo hr_payroll_sequence.xml NO EXISTE"
            echo "Contenido del directorio data:"
            ls -la /mnt/custom-addons/om_hr_payroll/data/
        fi
        
        # Verificar que el archivo esté en el manifest
        echo "Verificando manifest de om_hr_payroll..."
        if grep -q "hr_payroll_sequence.xml" /mnt/custom-addons/om_hr_payroll/__manifest__.py; then
            echo "✓ hr_payroll_sequence.xml está referenciado en el manifest"
        else
            echo "✗ hr_payroll_sequence.xml NO está referenciado en el manifest"
        fi
    else
        echo "✗ Módulo om_hr_payroll NO encontrado"
    fi
}

fix_om_hr_payroll

echo "=== Fin del script de corrección ==="
