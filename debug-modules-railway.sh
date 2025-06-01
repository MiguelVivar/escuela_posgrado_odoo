#!/bin/bash

# Script de debugging específico para módulos personalizados en Railway
echo "=== DEBUG DE MÓDULOS PERSONALIZADOS EN RAILWAY ==="
echo "Fecha: $(date)"
echo

# Configurar variables como el script principal
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"
DB_PORT="${DB_PORT:-${PGPORT:-5432}}"
DB_USER="${DB_USER:-${PGUSER:-postgres}}"
DB_PASSWORD="${DB_PASSWORD:-${PGPASSWORD:-postgres}}"
DB_NAME="${DB_NAME:-${PGDATABASE:-odoo_db}}"

echo "=== Variables de conexión ==="
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"
echo "DB_NAME: $DB_NAME"
echo

# 1. Verificar que el directorio custom-addons existe y tiene contenido
echo "=== 1. Verificando directorio de módulos personalizados ==="
if [ -d "/mnt/custom-addons" ]; then
    echo "✓ Directorio /mnt/custom-addons existe"
    
    echo "Contenido del directorio:"
    ls -la /mnt/custom-addons/
    echo
    
    if [ "$(ls -A /mnt/custom-addons)" ]; then
        echo "✓ Directorio tiene contenido"
        
        # Contar módulos válidos
        MODULE_COUNT=0
        echo "Módulos encontrados:"
        for module_path in /mnt/custom-addons/*/; do
            if [ -d "$module_path" ]; then
                module_name=$(basename "$module_path")
                echo "  - Directorio: $module_name"
                
                if [ -f "$module_path/__manifest__.py" ]; then
                    echo "    ✓ Tiene __manifest__.py"
                    MODULE_COUNT=$((MODULE_COUNT + 1))
                    
                    # Verificar contenido del manifest
                    echo "    Contenido del manifest:"
                    head -10 "$module_path/__manifest__.py" | sed 's/^/      /'
                    echo
                else
                    echo "    ✗ NO tiene __manifest__.py"
                fi
            fi
        done
        
        echo "Total de módulos válidos encontrados: $MODULE_COUNT"
    else
        echo "✗ Directorio está vacío"
        exit 1
    fi
else
    echo "✗ Directorio /mnt/custom-addons NO existe"
    exit 1
fi

echo

# 2. Verificar configuración de Odoo
echo "=== 2. Verificando configuración de Odoo ==="
if [ -f "/etc/odoo/odoo.conf" ]; then
    echo "✓ Archivo de configuración existe"
    
    echo "addons_path configurado:"
    grep "addons_path" /etc/odoo/odoo.conf || echo "  ✗ addons_path no encontrado en configuración"
    
    echo
else
    echo "✗ Archivo de configuración NO existe"
fi

# 3. Verificar conexión a base de datos
echo "=== 3. Verificando conexión a base de datos ==="
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✓ Conexión a base de datos exitosa"
    
    # Verificar si Odoo está inicializado
    DB_INITIALIZED=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name='ir_module_module');" 2>/dev/null || echo "f")
    
    if [ "$DB_INITIALIZED" = "t" ]; then
        echo "✓ Base de datos está inicializada con Odoo"
        
        echo
        echo "=== 4. Verificando estado de módulos personalizados ==="
        
        # Verificar cada módulo
        for module_path in /mnt/custom-addons/*/; do
            if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
                module_name=$(basename "$module_path")
                
                # Obtener estado del módulo
                MODULE_STATE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT state FROM ir_module_module WHERE name='$module_name';" 2>/dev/null || echo "not_found")
                
                echo "Módulo: $module_name"
                echo "  Estado: $MODULE_STATE"
                
                if [ "$MODULE_STATE" = "not_found" ]; then
                    echo "  ⚠️  Módulo no existe en ir_module_module"
                    
                    # Verificar si el módulo está en addons_path disponible
                    MODULE_AVAILABLE=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM ir_module_module WHERE name='$module_name' LIMIT 1;" 2>/dev/null || echo "0")
                    if [ "$MODULE_AVAILABLE" = "0" ]; then
                        echo "  ⚠️  Módulo no está disponible para instalación"
                        echo "  📋 Verificando dependencias en manifest..."
                        if grep -q "depends.*:" "$module_path/__manifest__.py"; then
                            echo "  Dependencias encontradas:"
                            grep -A 5 "depends.*:" "$module_path/__manifest__.py" | sed 's/^/    /'
                        fi
                    fi
                elif [ "$MODULE_STATE" = "installed" ]; then
                    echo "  ✅ Módulo instalado correctamente"
                elif [ "$MODULE_STATE" = "uninstalled" ]; then
                    echo "  📦 Módulo disponible pero no instalado"
                elif [ "$MODULE_STATE" = "to upgrade" ]; then
                    echo "  ⬆️  Módulo necesita actualización"
                elif [ "$MODULE_STATE" = "to install" ]; then
                    echo "  ⏳ Módulo marcado para instalación"
                fi
                
                echo
            fi
        done
        
    else
        echo "✗ Base de datos NO está inicializada con Odoo"
    fi
    
else
    echo "✗ Error de conexión a base de datos"
    echo "Verificando conectividad..."
    
    # Test de conectividad básica
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" >/dev/null 2>&1; then
        echo "✓ PostgreSQL está respondiendo"
        echo "✗ Error de autenticación o permisos"
    else
        echo "✗ PostgreSQL no está respondiendo o no es accesible"
    fi
fi

echo
echo "=== 5. Prueba de instalación manual de un módulo ==="
echo "Intentando instalar un módulo específico para testing..."

# Buscar el primer módulo disponible para testing
TEST_MODULE=""
for module_path in /mnt/custom-addons/*/; do
    if [ -d "$module_path" ] && [ -f "$module_path/__manifest__.py" ]; then
        TEST_MODULE=$(basename "$module_path")
        break
    fi
done

if [ ! -z "$TEST_MODULE" ]; then
    echo "Probando instalación de: $TEST_MODULE"
    
    # Intentar instalación con logs detallados
    echo "Comando a ejecutar:"
    echo "python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d \"$DB_NAME\" -i \"$TEST_MODULE\" --stop-after-init --without-demo=all --log-level=debug"
    
    echo
    echo "Ejecutando instalación de prueba..."
    if python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "$TEST_MODULE" --stop-after-init --without-demo=all --log-level=debug 2>&1 | head -50; then
        echo "✅ Instalación de prueba exitosa"
    else
        echo "❌ Error en instalación de prueba"
        echo "Últimas líneas del error:"
        python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$DB_NAME" -i "$TEST_MODULE" --stop-after-init --without-demo=all --log-level=debug 2>&1 | tail -20
    fi
else
    echo "❌ No se encontró ningún módulo para testing"
fi

echo
echo "=== RESUMEN DE DEBUG ==="
echo "Directorio custom-addons: $([ -d "/mnt/custom-addons" ] && echo "✓" || echo "✗")"
echo "Módulos encontrados: $MODULE_COUNT"
echo "Conexión BD: $(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1 && echo "✓" || echo "✗")"
echo "BD inicializada: $([ "$DB_INITIALIZED" = "t" ] && echo "✓" || echo "✗")"
echo
echo "=== FIN DEL DEBUG ==="
