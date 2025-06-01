#!/bin/bash

# Script de verificación para módulos personalizados en Railway
# Este script verifica que todo esté configurado correctamente

echo "=== Verificación de Módulos Personalizados ==="
echo "Fecha: $(date)"
echo

# 1. Verificar estructura de directorios
echo "1. Verificando estructura de directorios..."

if [ -d "/mnt/custom-addons" ]; then
    echo "✓ /mnt/custom-addons existe"
    echo "  Contenido:"
    ls -la /mnt/custom-addons/ | head -10
    if [ "$(ls -A /mnt/custom-addons)" ]; then
        echo "✓ Directorio contiene archivos"
    else
        echo "⚠ Directorio está vacío"
    fi
else
    echo "✗ /mnt/custom-addons NO existe"
fi

if [ -d "/mnt/extra-addons" ]; then
    echo "✓ /mnt/extra-addons existe"
else
    echo "✗ /mnt/extra-addons NO existe"
fi

echo

# 2. Verificar permisos
echo "2. Verificando permisos..."
if [ -d "/mnt/custom-addons" ]; then
    OWNER=$(stat -c '%U:%G' /mnt/custom-addons)
    echo "  Propietario de /mnt/custom-addons: $OWNER"
    if [ "$OWNER" = "odoo:odoo" ]; then
        echo "✓ Permisos correctos"
    else
        echo "⚠ Permisos incorrectos (debería ser odoo:odoo)"
    fi
else
    echo "✗ No se puede verificar permisos (directorio no existe)"
fi

echo

# 3. Verificar configuración de Odoo
echo "3. Verificando configuración de Odoo..."
if [ -f "/etc/odoo/odoo.conf" ]; then
    echo "✓ Archivo de configuración existe"
    ADDONS_PATH=$(grep "addons_path" /etc/odoo/odoo.conf | head -1)
    echo "  $ADDONS_PATH"
    
    if [[ "$ADDONS_PATH" == *"/mnt/custom-addons"* ]]; then
        echo "✓ /mnt/custom-addons está en addons_path"
    else
        echo "✗ /mnt/custom-addons NO está en addons_path"
    fi
    
    if [[ "$ADDONS_PATH" == *"/mnt/extra-addons"* ]]; then
        echo "✓ /mnt/extra-addons está en addons_path"
    else
        echo "✗ /mnt/extra-addons NO está en addons_path"
    fi
else
    echo "✗ Archivo de configuración NO existe"
fi

echo

# 4. Verificar módulos personalizados
echo "4. Verificando módulos personalizados..."
MODULE_COUNT=0
VALID_MODULES=0

if [ -d "/mnt/custom-addons" ]; then
    for module_path in /mnt/custom-addons/*/; do
        if [ -d "$module_path" ]; then
            MODULE_COUNT=$((MODULE_COUNT + 1))
            module_name=$(basename "$module_path")
            echo "  Módulo encontrado: $module_name"
            
            if [ -f "$module_path/__manifest__.py" ]; then
                echo "    ✓ Tiene __manifest__.py"
                VALID_MODULES=$((VALID_MODULES + 1))
                
                # Verificar contenido básico del manifest
                if grep -q "'name'" "$module_path/__manifest__.py"; then
                    echo "    ✓ Manifest tiene campo 'name'"
                else
                    echo "    ⚠ Manifest no tiene campo 'name'"
                fi
                
                if grep -q "'version'" "$module_path/__manifest__.py"; then
                    echo "    ✓ Manifest tiene campo 'version'"
                else
                    echo "    ⚠ Manifest no tiene campo 'version'"
                fi
            else
                echo "    ✗ NO tiene __manifest__.py"
            fi
            
            if [ -f "$module_path/__init__.py" ]; then
                echo "    ✓ Tiene __init__.py"
            else
                echo "    ⚠ NO tiene __init__.py"
            fi
        fi
    done
    
    echo "  Total módulos encontrados: $MODULE_COUNT"
    echo "  Módulos válidos: $VALID_MODULES"
else
    echo "  ✗ Directorio de módulos no existe"
fi

echo

# 5. Verificar conexión a base de datos (si está disponible)
echo "5. Verificando conexión a base de datos..."

DB_HOST="${DB_HOST:-${PGHOST:-localhost}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

echo "  Host: $DB_HOST:$DB_PORT"
echo "  Usuario: $DB_USER"
echo "  Base de datos: $DB_NAME"

if command -v psql >/dev/null 2>&1; then
    if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
        echo "✓ Conexión a base de datos exitosa"
        
        # Verificar si existen tablas de Odoo
        TABLES=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='ir_module_module';" 2>/dev/null || echo "0")
        
        if [ "$TABLES" -gt 0 ]; then
            echo "✓ Base de datos tiene tablas de Odoo"
            
            # Verificar módulos instalados
            INSTALLED_MODULES=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM ir_module_module WHERE state='installed';" 2>/dev/null || echo "0")
            echo "  Módulos instalados en BD: $INSTALLED_MODULES"
            
            # Verificar módulos personalizados en BD
            if [ $VALID_MODULES -gt 0 ]; then
                for module_path in /mnt/custom-addons/*/; do
                    if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
                        module_name=$(basename "$module_path")
                        STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "not_found")
                        echo "  $module_name: $STATE"
                    fi
                done
            fi
        else
            echo "⚠ Base de datos no tiene tablas de Odoo (no inicializada)"
        fi
    else
        echo "✗ No se puede conectar a la base de datos"
    fi
else
    echo "⚠ psql no disponible para verificar BD"
fi

echo

# 6. Verificar logs recientes
echo "6. Verificando logs recientes..."
if [ -f "/var/log/odoo/odoo.log" ]; then
    echo "✓ Archivo de log existe"
    RECENT_ERRORS=$(tail -100 /var/log/odoo/odoo.log | grep -i error | wc -l)
    echo "  Errores recientes (últimas 100 líneas): $RECENT_ERRORS"
    
    MODULE_LOGS=$(tail -100 /var/log/odoo/odoo.log | grep -i "módulo\|module" | wc -l)
    echo "  Menciones de módulos (últimas 100 líneas): $MODULE_LOGS"
else
    echo "⚠ No se encontró archivo de log"
fi

echo

# 7. Resumen final
echo "=== RESUMEN ==="
if [ $VALID_MODULES -gt 0 ] && [ -d "/mnt/custom-addons" ] && [ -f "/etc/odoo/odoo.conf" ]; then
    echo "✓ Configuración de módulos personalizados parece correcta"
    echo "  - $VALID_MODULES módulos válidos encontrados"
    echo "  - Directorios configurados correctamente"
    echo "  - Configuración de Odoo actualizada"
else
    echo "⚠ Hay problemas en la configuración:"
    if [ $VALID_MODULES -eq 0 ]; then
        echo "  - No se encontraron módulos válidos"
    fi
    if [ ! -d "/mnt/custom-addons" ]; then
        echo "  - Directorio de módulos no existe"
    fi
    if [ ! -f "/etc/odoo/odoo.conf" ]; then
        echo "  - Configuración de Odoo no encontrada"
    fi
fi

echo "=== Fin de verificación ==="
