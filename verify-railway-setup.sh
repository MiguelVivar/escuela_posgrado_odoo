#!/bin/bash

# Script de verificación para el despliegue de Railway
# Este script te ayuda a verificar que todo esté configurado correctamente

echo "🔍 Verificando configuración para Railway..."
echo "============================================="

# Verificar que los archivos necesarios existen
echo "📁 Verificando archivos necesarios..."
files_to_check=(
    "Dockerfile"
    "start.sh"
    "railway.toml"
    "config/odoo.conf"
    "addons/README.md"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file - Existe"
    else
        echo "❌ $file - No encontrado"
    fi
done

echo ""
echo "🔧 Verificando permisos del script..."
if [ -x "start.sh" ]; then
    echo "✅ start.sh - Ejecutable"
else
    echo "❌ start.sh - No ejecutable"
    echo "   Ejecuta: chmod +x start.sh"
fi

echo ""
echo "📋 Verificando contenido de archivos clave..."

# Verificar Dockerfile
if grep -q "CMD \[\"\/usr\/local\/bin\/start.sh\"\]" Dockerfile; then
    echo "✅ Dockerfile - CMD correcto"
else
    echo "❌ Dockerfile - CMD incorrecto"
fi

# Verificar railway.toml
if grep -q "builder = \"dockerfile\"" railway.toml; then
    echo "✅ railway.toml - Builder correcto"
else
    echo "❌ railway.toml - Builder incorrecto"
fi

# Verificar start.sh
if grep -q "PGHOST" start.sh; then
    echo "✅ start.sh - Variables de Railway detectadas"
else
    echo "❌ start.sh - Variables de Railway no encontradas"
fi

echo ""
echo "🐳 Estructura del proyecto:"
echo "├── Dockerfile"
echo "├── railway.toml"
echo "├── start.sh"
echo "├── config/"
echo "│   └── odoo.conf"
echo "└── addons/"
echo "    └── (tus addons personalizados)"

echo ""
echo "📝 Variables de entorno que Railway debería crear automáticamente:"
echo "   - PGHOST (Host de PostgreSQL)"
echo "   - PGPORT (Puerto, normalmente 5432)"
echo "   - PGUSER (Usuario de la base de datos)"
echo "   - PGPASSWORD (Contraseña de la base de datos)"
echo "   - PGDATABASE (Nombre de la base de datos)"

echo ""
echo "🚀 Pasos para desplegar en Railway:"
echo "1. Sube este repositorio a GitHub"
echo "2. Crea un proyecto en Railway"
echo "3. Agrega una base de datos PostgreSQL"
echo "4. Conecta tu repositorio GitHub"
echo "5. Railway detectará el Dockerfile automáticamente"
echo "6. El despliegue iniciará automáticamente"

echo ""
echo "✨ ¡Verificación completa!"
echo "Si todos los elementos están ✅, tu proyecto está listo para Railway."
