#!/bin/bash

echo "=== Corrección específica para om_hr_payroll ==="

# Variables
MODULE_NAME="om_hr_payroll"
MODULE_PATH="/mnt/custom-addons/$MODULE_NAME"
DATA_FILE="$MODULE_PATH/data/hr_payroll_sequence.xml"

# Función para verificar y corregir el módulo
fix_om_hr_payroll_module() {
    echo "1. Verificando estructura del módulo $MODULE_NAME..."
    
    if [ ! -d "$MODULE_PATH" ]; then
        echo "✗ ERROR: Directorio del módulo $MODULE_PATH no existe"
        return 1
    fi
    
    echo "✓ Directorio del módulo existe: $MODULE_PATH"
    
    # Verificar archivos esenciales
    if [ ! -f "$MODULE_PATH/__manifest__.py" ]; then
        echo "✗ ERROR: __manifest__.py no existe"
        return 1
    fi
    echo "✓ __manifest__.py existe"
    
    if [ ! -f "$MODULE_PATH/__init__.py" ]; then
        echo "✗ ERROR: __init__.py no existe"
        return 1
    fi
    echo "✓ __init__.py existe"
    
    # Verificar directorio data
    if [ ! -d "$MODULE_PATH/data" ]; then
        echo "✗ ERROR: Directorio data no existe"
        return 1
    fi
    echo "✓ Directorio data existe"
    
    # Verificar archivo específico del error
    if [ ! -f "$DATA_FILE" ]; then
        echo "✗ ERROR: Archivo hr_payroll_sequence.xml no existe en $DATA_FILE"
        echo "Contenido del directorio data:"
        ls -la "$MODULE_PATH/data/"
        return 1
    fi
    echo "✓ Archivo hr_payroll_sequence.xml existe"
    
    # Verificar contenido del archivo
    if [ ! -s "$DATA_FILE" ]; then
        echo "✗ ERROR: Archivo hr_payroll_sequence.xml está vacío"
        return 1
    fi
    echo "✓ Archivo hr_payroll_sequence.xml tiene contenido"
    
    # Verificar sintaxis XML básica
    if ! head -1 "$DATA_FILE" | grep -q "<?xml"; then
        echo "✗ ERROR: Archivo hr_payroll_sequence.xml no parece ser XML válido"
        echo "Primera línea:"
        head -1 "$DATA_FILE"
        return 1
    fi
    echo "✓ Archivo hr_payroll_sequence.xml parece ser XML válido"
    
    # Verificar permisos
    if [ ! -r "$DATA_FILE" ]; then
        echo "✗ ERROR: Archivo hr_payroll_sequence.xml no es legible"
        echo "Permisos actuales:"
        ls -la "$DATA_FILE"
        
        echo "Corrigiendo permisos..."
        chmod 644 "$DATA_FILE"
        chown odoo:odoo "$DATA_FILE"
        
        if [ ! -r "$DATA_FILE" ]; then
            echo "✗ ERROR: No se pudieron corregir los permisos"
            return 1
        fi
        echo "✓ Permisos corregidos"
    else
        echo "✓ Archivo es legible"
    fi
    
    return 0
}

# Función para verificar que el archivo esté referenciado correctamente en el manifest
verify_manifest_reference() {
    echo "2. Verificando referencia en manifest..."
    
    if grep -q "data/hr_payroll_sequence.xml" "$MODULE_PATH/__manifest__.py"; then
        echo "✓ Archivo está correctamente referenciado en el manifest"
        return 0
    else
        echo "✗ ERROR: Archivo no está referenciado en el manifest"
        echo "Contenido de la sección 'data' en el manifest:"
        grep -A 20 "'data':" "$MODULE_PATH/__manifest__.py"
        return 1
    fi
}

# Función para verificar dependencias
verify_dependencies() {
    echo "3. Verificando dependencias del módulo..."
    
    echo "Dependencias declaradas en el manifest:"
    grep -A 10 "'depends':" "$MODULE_PATH/__manifest__.py"
    
    # Verificar que las dependencias básicas existan
    REQUIRED_DEPS=("mail" "hr_contract" "hr_holidays")
    
    for dep in "${REQUIRED_DEPS[@]}"; do
        if [ -d "/usr/lib/python3/dist-packages/odoo/addons/$dep" ]; then
            echo "✓ Dependencia $dep encontrada en addons core"
        elif [ -d "/mnt/extra-addons/$dep" ]; then
            echo "✓ Dependencia $dep encontrada en extra-addons"
        elif [ -d "/mnt/custom-addons/$dep" ]; then
            echo "✓ Dependencia $dep encontrada en custom-addons"
        else
            echo "⚠ ADVERTENCIA: Dependencia $dep no encontrada"
        fi
    done
}

# Función para crear una copia de respaldo del archivo problemático
create_backup_and_fix() {
    echo "4. Creando respaldo y aplicando corrección..."
    
    # Crear respaldo
    cp "$DATA_FILE" "$DATA_FILE.backup"
    echo "✓ Respaldo creado: $DATA_FILE.backup"
    
    # Verificar que el contenido sea válido
    echo "Contenido actual del archivo:"
    cat "$DATA_FILE"
    
    # Si el archivo parece corrupto, recrearlo
    if ! grep -q "ir.sequence" "$DATA_FILE"; then
        echo "⚠ Archivo parece corrupto, recreando..."
        cat > "$DATA_FILE" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data noupdate="1">
    
        <record id="seq_salary_slip" model="ir.sequence">
            <field name="name">Salary Slip</field>
            <field name="code">salary.slip</field>
            <field name="prefix">SLIP/</field>
            <field name="padding">3</field>
        </record>
      
    </data>
</odoo>
EOF
        echo "✓ Archivo recreado con contenido válido"
    fi
    
    # Establecer permisos correctos
    chmod 644 "$DATA_FILE"
    chown odoo:odoo "$DATA_FILE"
    echo "✓ Permisos establecidos correctamente"
}

# Ejecutar todas las verificaciones y correcciones
echo "Iniciando corrección específica para $MODULE_NAME..."

if fix_om_hr_payroll_module; then
    echo "✓ Estructura del módulo verificada correctamente"
else
    echo "✗ ERROR en la estructura del módulo"
    exit 1
fi

if verify_manifest_reference; then
    echo "✓ Referencia en manifest verificada correctamente"
else
    echo "✗ ERROR en la referencia del manifest"
    exit 1
fi

verify_dependencies

create_backup_and_fix

echo "=== Corrección completada ==="
echo "El módulo $MODULE_NAME debería funcionar correctamente ahora"
