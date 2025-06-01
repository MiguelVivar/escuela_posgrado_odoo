#!/bin/bash

# Script para hacer commit de las mejoras de módulos personalizados para Railway

echo "=== Preparando commit de mejoras de módulos personalizados ==="

# Verificar que estamos en un repositorio Git
if [ ! -d ".git" ]; then
    echo "Error: No estamos en un repositorio Git"
    exit 1
fi

echo "Agregando archivos modificados..."

# Agregar archivos modificados y nuevos
git add start.sh
git add Dockerfile
git add check-modules-railway.sh
git add RAILWAY_DEPLOYMENT.md
git add EXPECTED_LOGS.md
git add CUSTOM_MODULES_RAILWAY.md
git add README.md

echo "Archivos agregados:"
git status --porcelain

echo ""
echo "Creando commit..."

# Crear commit con mensaje descriptivo
git commit -m "✨ Implementar instalación automática de módulos personalizados en Railway

🔧 Mejoras en start.sh:
- Verificación automática del estado de módulos en cada arranque
- Instalación inteligente solo para módulos nuevos o no instalados
- Logs detallados del proceso de instalación
- Verificación de dependencias antes de la instalación

📦 Nuevo script check-modules-railway.sh:
- Verificación completa del estado de módulos personalizados
- Diagnóstico de problemas de instalación
- Comandos de corrección sugeridos
- Códigos de salida informativos

📚 Documentación actualizada:
- RAILWAY_DEPLOYMENT.md: Información sobre módulos automáticos
- EXPECTED_LOGS.md: Logs esperados con instalación de módulos
- CUSTOM_MODULES_RAILWAY.md: Guía completa de módulos personalizados
- README.md: Referencia a nueva funcionalidad

🐳 Dockerfile actualizado:
- Inclusión del nuevo script de verificación
- Permisos correctos para todos los scripts

🎯 Problema resuelto:
- Los módulos personalizados ahora se instalan automáticamente
- Verificación del estado en cada despliegue
- Instalación solo cuando es necesario
- Logs claros para debugging

Los módulos education_*, muk_web_*, om_hr_payroll y query_deluxe
se instalarán automáticamente en Railway 🚀"

if [ $? -eq 0 ]; then
    echo "✅ Commit creado exitosamente!"
    echo ""
    echo "📋 Resumen del commit:"
    git log --oneline -1
    echo ""
    echo "🚀 Para desplegar en Railway:"
    echo "   git push origin main"
    echo ""
    echo "🔍 Para verificar módulos después del despliegue:"
    echo "   railway run /usr/local/bin/check-modules-railway.sh"
else
    echo "❌ Error al crear el commit"
    exit 1
fi

echo ""
echo "=== Cambios listos para Railway ==="
