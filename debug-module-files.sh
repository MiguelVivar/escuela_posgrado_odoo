#!/bin/bash

echo "=== Debug: Verificación de archivos del módulo om_hr_payroll ==="

# Verificar si el directorio del módulo existe
echo "1. Verificando directorio del módulo:"
if [ -d "/mnt/custom-addons/om_hr_payroll" ]; then
    echo "✓ Directorio /mnt/custom-addons/om_hr_payroll existe"
    ls -la /mnt/custom-addons/om_hr_payroll/
else
    echo "✗ Directorio /mnt/custom-addons/om_hr_payroll NO existe"
    echo "Contenido de /mnt/custom-addons/:"
    ls -la /mnt/custom-addons/
fi

echo ""
echo "2. Verificando directorio data:"
if [ -d "/mnt/custom-addons/om_hr_payroll/data" ]; then
    echo "✓ Directorio /mnt/custom-addons/om_hr_payroll/data existe"
    ls -la /mnt/custom-addons/om_hr_payroll/data/
else
    echo "✗ Directorio /mnt/custom-addons/om_hr_payroll/data NO existe"
fi

echo ""
echo "3. Verificando archivo hr_payroll_sequence.xml:"
if [ -f "/mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml" ]; then
    echo "✓ Archivo hr_payroll_sequence.xml existe"
    echo "Contenido del archivo:"
    cat /mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml
else
    echo "✗ Archivo hr_payroll_sequence.xml NO existe"
fi

echo ""
echo "4. Verificando permisos:"
if [ -f "/mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml" ]; then
    ls -la /mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml
fi

echo ""
echo "5. Verificando addons_path en configuración:"
grep "addons_path" /etc/odoo/odoo.conf

echo ""
echo "6. Verificando __manifest__.py:"
if [ -f "/mnt/custom-addons/om_hr_payroll/__manifest__.py" ]; then
    echo "✓ Archivo __manifest__.py existe"
    echo "Sección 'data' del manifest:"
    grep -A 20 "'data'" /mnt/custom-addons/om_hr_payroll/__manifest__.py
else
    echo "✗ Archivo __manifest__.py NO existe"
fi

echo ""
echo "=== Fin del debug ==="
