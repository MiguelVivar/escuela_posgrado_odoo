#!/bin/bash

# Script para verificar el estado de los módulos personalizados en Railway
# Ejecutar desde Railway con: railway run /usr/local/bin/check-modules-railway.sh

echo "=== Verificador de Módulos Personalizados en Railway ==="
echo "Fecha: $(date)"
echo

# Configurar variables de entorno
DB_HOST="${DB_HOST:-${PGHOST:-localhost}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

echo "Configuración de conexión:"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"
echo "DB_NAME: $DB_NAME"
echo

# 1. Verificar conexión a la base de datos
echo "1. Verificando conexión a la base de datos..."
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✓ Conexión exitosa"
else
    echo "✗ Error de conexión"
    exit 1
fi

# 2. Verificar que el directorio de módulos existe y tiene contenido
echo "2. Verificando módulos en /mnt/custom-addons..."
if [ -d "/mnt/custom-addons" ]; then
    echo "✓ Directorio existe"
    MODULE_COUNT=$(find /mnt/custom-addons -name "__manifest__.py" | wc -l)
    echo "  Módulos encontrados: $MODULE_COUNT"
    
    if [ $MODULE_COUNT -gt 0 ]; then
        echo "  Lista de módulos:"
        for module_path in /mnt/custom-addons/*/; do
            if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
                module_name=$(basename "$module_path")
                echo "    - $module_name"
            fi
        done
    fi
else
    echo "✗ Directorio no existe"
fi

echo

# 3. Verificar configuración de Odoo
echo "3. Verificando configuración de Odoo..."
if [ -f "/etc/odoo/odoo.conf" ]; then
    echo "✓ Archivo de configuración existe"
    ADDONS_PATH=$(grep "addons_path" /etc/odoo/odoo.conf)
    echo "  $ADDONS_PATH"
    
    if [[ "$ADDONS_PATH" == *"/mnt/custom-addons"* ]]; then
        echo "✓ /mnt/custom-addons está incluido en addons_path"
    else
        echo "✗ /mnt/custom-addons NO está en addons_path"
    fi
else
    echo "✗ Archivo de configuración no existe"
fi

echo

# 4. Verificar estado de módulos en la base de datos
echo "4. Verificando estado de módulos en la base de datos..."

# Verificar que las tablas de Odoo existen
TABLES_EXIST=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name='ir_module_module');" 2>/dev/null || echo "f")

if [ "$TABLES_EXIST" = "t" ]; then
    echo "✓ Base de datos inicializada"
    
    # Contar módulos instalados
    TOTAL_INSTALLED=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM ir_module_module WHERE state='installed';" 2>/dev/null || echo "0")
    echo "  Total de módulos instalados: $TOTAL_INSTALLED"
    
    # Verificar módulos personalizados específicamente
    echo "  Estado de módulos personalizados:"
    CUSTOM_INSTALLED=0
    CUSTOM_UNINSTALLED=0
    
    if [ -d "/mnt/custom-addons" ]; then
        for module_path in /mnt/custom-addons/*/; do
            if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
                module_name=$(basename "$module_path")
                STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "not_found")
                
                case $STATE in
                    "installed")
                        echo "    ✓ $module_name: INSTALADO"
                        CUSTOM_INSTALLED=$((CUSTOM_INSTALLED + 1))
                        ;;
                    "uninstalled")
                        echo "    ✗ $module_name: NO INSTALADO"
                        CUSTOM_UNINSTALLED=$((CUSTOM_UNINSTALLED + 1))
                        ;;
                    "to install")
                        echo "    ⏳ $module_name: PENDIENTE DE INSTALACIÓN"
                        CUSTOM_UNINSTALLED=$((CUSTOM_UNINSTALLED + 1))
                        ;;
                    "to upgrade")
                        echo "    ⚠ $module_name: NECESITA ACTUALIZACIÓN"
                        ;;
                    "not_found")
                        echo "    ❓ $module_name: NO ENCONTRADO EN BD"
                        CUSTOM_UNINSTALLED=$((CUSTOM_UNINSTALLED + 1))
                        ;;
                    *)
                        echo "    ? $module_name: ESTADO DESCONOCIDO ($STATE)"
                        ;;
                esac
            fi
        done
    fi
    
    echo "  Resumen de módulos personalizados:"
    echo "    Instalados: $CUSTOM_INSTALLED"
    echo "    No instalados: $CUSTOM_UNINSTALLED"
    
else
    echo "✗ Base de datos no está inicializada"
fi

echo

# 5. Sugerencias y comandos de corrección
echo "5. Comandos para corregir problemas (si los hay):"

if [ $CUSTOM_UNINSTALLED -gt 0 ]; then
    echo "  Para instalar módulos faltantes:"
    echo "    railway run /usr/local/bin/install-custom-modules.sh"
    echo
fi

echo "  Para verificar logs de Odoo:"
echo "    railway logs --follow"
echo

echo "  Para ejecutar Odoo en modo de actualización:"
echo "    railway run python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d $DB_NAME -u all --stop-after-init"
echo

echo "=== Verificación completada ==="

# Código de salida basado en el estado
if [ $CUSTOM_UNINSTALLED -eq 0 ] && [ $CUSTOM_INSTALLED -gt 0 ]; then
    echo "🎉 RESULTADO: Todos los módulos personalizados están instalados correctamente"
    exit 0
elif [ $CUSTOM_INSTALLED -gt 0 ] && [ $CUSTOM_UNINSTALLED -gt 0 ]; then
    echo "⚠️ RESULTADO: Algunos módulos están instalados, otros necesitan instalación"
    exit 1
elif [ $CUSTOM_INSTALLED -eq 0 ] && [ $CUSTOM_UNINSTALLED -gt 0 ]; then
    echo "❌ RESULTADO: Ningún módulo personalizado está instalado"
    exit 2
else
    echo "ℹ️ RESULTADO: No se encontraron módulos personalizados para verificar"
    exit 0
fi
