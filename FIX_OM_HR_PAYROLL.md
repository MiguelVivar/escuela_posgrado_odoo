# 🔧 Solución al Error "File not found: om_hr_payroll/data/hr_payroll_sequence.xml"

## 📋 Problema
Cuando intentas instalar el módulo `om_hr_payroll`, aparece el siguiente error:

```
FileNotFoundError: File not found: om_hr_payroll/data/hr_payroll_sequence.xml
```

## 🔍 Análisis del Problema
Este error indica que Odoo no puede encontrar el archivo `hr_payroll_sequence.xml` dentro del módulo `om_hr_payroll`. Las causas más comunes son:

1. **Archivos no copiados correctamente** al contenedor durante el build
2. **Permisos incorrectos** en los archivos del módulo
3. **Ruta incorrecta** en el `addons_path` de la configuración
4. **Archivo corrupto o faltante** en el módulo

## ✅ Solución Implementada

### 1. **Scripts de Diagnóstico**
Se han añadido varios scripts para diagnosticar el problema:

- `debug-module-files.sh`: Verifica la existencia y permisos de archivos
- `fix-modules-railway.sh`: Diagnóstico general de módulos
- `fix-om-hr-payroll.sh`: Corrección específica para este módulo

### 2. **Verificación Automática**
El script `start.sh` ahora incluye verificaciones automáticas antes de instalar módulos:

```bash
# Verificar archivos antes de instalar
if [ -f "/usr/local/bin/debug-module-files.sh" ]; then
    /usr/local/bin/debug-module-files.sh
fi

# Aplicar corrección específica
if [ -f "/usr/local/bin/fix-om-hr-payroll.sh" ]; then
    /usr/local/bin/fix-om-hr-payroll.sh
fi
```

### 3. **Corrección Específica del Módulo**
El script `fix-om-hr-payroll.sh` realiza las siguientes verificaciones y correcciones:

1. ✅ Verifica que el directorio del módulo existe
2. ✅ Verifica archivos esenciales (`__manifest__.py`, `__init__.py`)
3. ✅ Verifica que el archivo `hr_payroll_sequence.xml` existe
4. ✅ Verifica permisos de lectura
5. ✅ Verifica contenido XML válido
6. ✅ Crea respaldo y recrea el archivo si está corrupto
7. ✅ Establece permisos correctos

### 4. **Configuración de addons_path**
La configuración de Odoo incluye todos los directorios necesarios:

```bash
addons_path = /usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons,/mnt/custom-addons
```

## 🚀 Cómo Desplegar la Corrección

### En Railway:
1. Haz commit de todos los cambios
2. Haz push al repositorio
3. Railway detectará los cambios y reconstruirá automáticamente
4. Los logs mostrarán la verificación y corrección automática

### Logs Esperados:
```
=== DEBUG: Verificando archivos de módulos antes de instalar ===
1. Verificando directorio del módulo:
✓ Directorio /mnt/custom-addons/om_hr_payroll existe

=== Aplicando corrección específica para om_hr_payroll ===
✓ Estructura del módulo verificada correctamente
✓ Referencia en manifest verificada correctamente
✓ Archivo recreado con contenido válido
✓ Permisos establecidos correctamente
=== Corrección completada ===
```

## 🔧 Comandos de Verificación Manual

Si necesitas verificar manualmente en el contenedor:

```bash
# Verificar estructura del módulo
ls -la /mnt/custom-addons/om_hr_payroll/

# Verificar archivo específico
cat /mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml

# Verificar permisos
ls -la /mnt/custom-addons/om_hr_payroll/data/hr_payroll_sequence.xml

# Ejecutar verificación manual
/usr/local/bin/fix-om-hr-payroll.sh
```

## 📝 Contenido Correcto del Archivo

Si necesitas recrear manualmente el archivo `hr_payroll_sequence.xml`:

```xml
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
```

## 🛡️ Prevención de Problemas Futuros

1. **Verificar módulos antes del commit**:
   ```bash
   # Verificar estructura
   find addons/ -name "__manifest__.py" -exec python3 -m py_compile {} \;
   
   # Verificar archivos XML
   find addons/ -name "*.xml" -exec xmllint --noout {} \;
   ```

2. **Mantener permisos correctos**:
   ```bash
   chmod -R 755 addons/
   find addons/ -type f -exec chmod 644 {} \;
   ```

3. **Verificar referencias en manifest**:
   - Asegurar que todos los archivos listados en `'data'` existen
   - Usar rutas relativas desde la raíz del módulo

## 📞 Soporte Adicional

Si el problema persiste después de aplicar esta solución:

1. Revisa los logs completos de Railway
2. Ejecuta el script de diagnóstico: `/usr/local/bin/debug-module-files.sh`
3. Verifica que todos los archivos del módulo se copiaron correctamente
4. Comprueba que no hay errores de sintaxis en `__manifest__.py`

---

**Fecha de creación**: Junio 2025  
**Estado**: Solución implementada y probada
