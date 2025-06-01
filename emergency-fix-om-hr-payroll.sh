#!/bin/bash

echo "=== 🚑 Script de Emergencia para om_hr_payroll ==="
echo "Este script soluciona problemas críticos con el módulo om_hr_payroll"
echo ""

# Variables
MODULE_PATH="/mnt/custom-addons/om_hr_payroll"
BACKUP_DIR="/tmp/om_hr_payroll_backup"

# Función de respaldo
create_full_backup() {
    echo "📦 Creando respaldo completo del módulo..."
    if [ -d "$MODULE_PATH" ]; then
        rm -rf "$BACKUP_DIR"
        cp -r "$MODULE_PATH" "$BACKUP_DIR"
        echo "✅ Respaldo creado en: $BACKUP_DIR"
    fi
}

# Función para recrear archivos esenciales
recreate_essential_files() {
    echo "🔧 Recreando archivos esenciales..."
    
    # Crear __init__.py si no existe
    if [ ! -f "$MODULE_PATH/__init__.py" ]; then
        echo "Creando __init__.py..."
        cat > "$MODULE_PATH/__init__.py" << 'EOF'
# -*- coding: utf-8 -*-
from . import models
from . import wizard
EOF
        echo "✅ __init__.py creado"
    fi
    
    # Verificar y recrear directorio data
    if [ ! -d "$MODULE_PATH/data" ]; then
        echo "Creando directorio data..."
        mkdir -p "$MODULE_PATH/data"
        echo "✅ Directorio data creado"
    fi
    
    # Recrear hr_payroll_sequence.xml con contenido garantizado
    echo "Recreando hr_payroll_sequence.xml..."
    cat > "$MODULE_PATH/data/hr_payroll_sequence.xml" << 'EOF'
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
    echo "✅ hr_payroll_sequence.xml recreado"
    
    # Verificar otros archivos de datos críticos
    recreate_data_files
}

# Función para recrear todos los archivos de datos
recreate_data_files() {
    echo "📋 Verificando y recreando archivos de datos..."
    
    # hr_payroll_category.xml
    if [ ! -f "$MODULE_PATH/data/hr_payroll_category.xml" ]; then
        echo "Creando hr_payroll_category.xml..."
        cat > "$MODULE_PATH/data/hr_payroll_category.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data noupdate="1">
        <!-- Categorías de nómina básicas -->
        <record id="alw" model="hr.salary.rule.category">
            <field name="name">Allowance</field>
            <field name="code">ALW</field>
        </record>
        <record id="ded" model="hr.salary.rule.category">
            <field name="name">Deduction</field>
            <field name="code">DED</field>
        </record>
        <record id="basic" model="hr.salary.rule.category">
            <field name="name">Basic</field>
            <field name="code">BASIC</field>
        </record>
        <record id="gross" model="hr.salary.rule.category">
            <field name="name">Gross</field>
            <field name="code">GROSS</field>
        </record>
        <record id="net" model="hr.salary.rule.category">
            <field name="name">Net</field>
            <field name="code">NET</field>
        </record>
    </data>
</odoo>
EOF
        echo "✅ hr_payroll_category.xml creado"
    fi
    
    # hr_payroll_data.xml (archivo básico)
    if [ ! -f "$MODULE_PATH/data/hr_payroll_data.xml" ]; then
        echo "Creando hr_payroll_data.xml..."
        cat > "$MODULE_PATH/data/hr_payroll_data.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data noupdate="1">
        <!-- Datos básicos de nómina -->
        <record id="structure_base" model="hr.payroll.structure">
            <field name="name">Base Structure</field>
            <field name="code">BASE</field>
        </record>
    </data>
</odoo>
EOF
        echo "✅ hr_payroll_data.xml creado"
    fi
    
    # mail_template.xml (archivo básico)
    if [ ! -f "$MODULE_PATH/data/mail_template.xml" ]; then
        echo "Creando mail_template.xml..."
        cat > "$MODULE_PATH/data/mail_template.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data noupdate="1">
        <!-- Plantillas de correo básicas -->
    </data>
</odoo>
EOF
        echo "✅ mail_template.xml creado"
    fi
}

# Función para establecer permisos correctos
fix_permissions() {
    echo "🔐 Estableciendo permisos correctos..."
    
    # Cambiar propietario a odoo
    chown -R odoo:odoo "$MODULE_PATH"
    
    # Permisos para directorios
    find "$MODULE_PATH" -type d -exec chmod 755 {} \;
    
    # Permisos para archivos
    find "$MODULE_PATH" -type f -exec chmod 644 {} \;
    
    # Permisos específicos para archivos Python
    find "$MODULE_PATH" -name "*.py" -exec chmod 644 {} \;
    
    # Permisos específicos para archivos XML
    find "$MODULE_PATH" -name "*.xml" -exec chmod 644 {} \;
    
    echo "✅ Permisos establecidos correctamente"
}

# Función para verificar el manifest
verify_and_fix_manifest() {
    echo "📄 Verificando y corrigiendo __manifest__.py..."
    
    if [ ! -f "$MODULE_PATH/__manifest__.py" ]; then
        echo "❌ ERROR: __manifest__.py no existe. Recreando..."
        cat > "$MODULE_PATH/__manifest__.py" << 'EOF'
{
    'name': 'Odoo 18 HR Payroll',
    'category': 'Generic Modules/Human Resources',
    'version': '1.0.0',
    'sequence': 1,
    'author': 'Odoo Mates, Odoo SA',
    'summary': 'Payroll For Odoo 18 Community Edition',
    'description': "Odoo 18 Payroll, Payroll Odoo 18, Odoo Community Payroll",
    'website': 'https://www.odoomates.tech',
    'license': 'LGPL-3',
    'depends': [
        'mail',
        'hr_contract',
        'hr_holidays',
    ],
    'data': [
        'security/hr_payroll_security.xml',
        'security/ir.model.access.csv',
        'data/hr_payroll_sequence.xml',
        'data/hr_payroll_category.xml',
        'data/hr_payroll_data.xml',
        'data/mail_template.xml',
    ],
    'images': ['static/description/banner.png'],
    'application': True,
}
EOF
        echo "✅ __manifest__.py recreado con configuración básica"
    else
        echo "✅ __manifest__.py existe"
    fi
}

# Función para verificar dependencias
check_dependencies() {
    echo "🔍 Verificando dependencias..."
    
    DEPS=("mail" "hr_contract" "hr_holidays")
    
    for dep in "${DEPS[@]}"; do
        if [ -d "/usr/lib/python3/dist-packages/odoo/addons/$dep" ]; then
            echo "✅ $dep disponible en core"
        elif [ -d "/mnt/extra-addons/$dep" ]; then
            echo "✅ $dep disponible en extra-addons"
        else
            echo "⚠️  $dep no encontrado - podría causar problemas"
        fi
    done
}

# Función principal
main() {
    echo "Iniciando corrección de emergencia para om_hr_payroll..."
    echo ""
    
    if [ ! -d "$MODULE_PATH" ]; then
        echo "❌ ERROR CRÍTICO: El módulo om_hr_payroll no existe en $MODULE_PATH"
        echo "Verifica que el módulo esté correctamente copiado al contenedor."
        exit 1
    fi
    
    echo "📍 Módulo encontrado en: $MODULE_PATH"
    echo ""
    
    # Ejecutar correcciones
    create_full_backup
    verify_and_fix_manifest
    recreate_essential_files
    fix_permissions
    check_dependencies
    
    echo ""
    echo "🎉 Corrección de emergencia completada!"
    echo ""
    echo "📋 Resumen:"
    echo "   - Respaldo creado: $BACKUP_DIR"
    echo "   - Archivos esenciales recreados"
    echo "   - Permisos corregidos"
    echo "   - Dependencias verificadas"
    echo ""
    echo "🔄 Ahora puedes intentar instalar el módulo nuevamente."
    echo ""
    
    # Verificación final
    echo "🔍 Verificación final:"
    if [ -f "$MODULE_PATH/data/hr_payroll_sequence.xml" ]; then
        echo "✅ hr_payroll_sequence.xml existe y es accesible"
        echo "📄 Contenido:"
        head -5 "$MODULE_PATH/data/hr_payroll_sequence.xml"
    else
        echo "❌ hr_payroll_sequence.xml aún no existe"
        exit 1
    fi
}

# Ejecutar función principal
main

echo ""
echo "=== 🏁 Script de emergencia completado ==="
