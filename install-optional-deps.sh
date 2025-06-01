#!/bin/bash

# Script para instalar dependencias adicionales de Python después del deployment
# Esto evita problemas durante el build inicial en Railway

echo "🔧 Instalando dependencias adicionales de Python..."

# Lista de paquetes que pueden requerir compilación
OPTIONAL_PACKAGES=(
    "num2words"
    "qrcode"
    "cryptography"
    "pillow"
    "reportlab"
    "openpyxl"
    "pandas"
)

# Función para instalar un paquete de forma segura
install_package() {
    local package=$1
    echo "📦 Intentando instalar $package..."
    
    if pip3 install --no-cache-dir "$package"; then
        echo "✅ $package instalado correctamente"
        return 0
    else
        echo "❌ Error instalando $package - continuando..."
        return 1
    fi
}

# Instalar paquetes opcionales
for package in "${OPTIONAL_PACKAGES[@]}"; do
    install_package "$package"
done

echo "🎯 Instalación de dependencias adicionales completada"
echo "📝 Los paquetes que fallaron se pueden instalar manualmente cuando sea necesario"
