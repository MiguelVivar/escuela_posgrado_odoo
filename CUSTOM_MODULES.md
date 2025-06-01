# Módulos Personalizados en Railway

Este documento explica cómo funcionan los módulos personalizados en el despliegue de Odoo en Railway.

## Estructura de Directorios

El proyecto está configurado para soportar módulos personalizados con la siguiente estructura:

```
/mnt/custom-addons/     # Módulos personalizados del proyecto
/mnt/extra-addons/      # Módulos adicionales (vacío por defecto)
/usr/lib/python3/dist-packages/odoo/addons/  # Módulos core de Odoo
```

## Configuración Automática

### 1. Dockerfile
- Copia los módulos desde `./addons/` a `/mnt/custom-addons/` en el contenedor
- Configura los permisos correctos para el usuario `odoo`
- Incluye las rutas en `addons_path`

### 2. Script de Inicio (start.sh)
- Detecta automáticamente módulos en `/mnt/custom-addons/`
- Instala los módulos durante la inicialización de la base de datos
- Registra el proceso en los logs para debugging

### 3. Configuración de Odoo
- `addons_path` incluye todas las rutas necesarias
- Configuración optimizada para Railway con límites de memoria apropiados
- Soporte para proxy_mode y server_wide_modules

## Agregar Nuevos Módulos

### Método 1: Durante el Build
1. Coloca tu módulo en la carpeta `addons/` del proyecto
2. Asegúrate de que tenga un archivo `__manifest__.py` válido
3. Redespliega en Railway - el módulo se instalará automáticamente

### Método 2: Script Manual
Usa el script `install-custom-modules.sh` para instalar módulos después del despliegue:

```bash
# Desde dentro del contenedor
/usr/local/bin/install-custom-modules.sh
```

## Estructura de un Módulo Personalizado

Un módulo válido debe tener al menos:

```
mi_modulo/
├── __init__.py
├── __manifest__.py
├── models/
│   ├── __init__.py
│   └── mi_modelo.py
├── views/
│   └── mi_vista.xml
└── security/
    └── ir.model.access.csv
```

### Ejemplo de __manifest__.py

```python
{
    'name': 'Mi Módulo Personalizado',
    'version': '18.0.1.0.0',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/mi_vista.xml',
    ],
    'installable': True,
    'application': False,
    'auto_install': False,
}
```

## Debugging

### Verificar Módulos Disponibles
Los logs de inicio mostrarán:
- Módulos encontrados en `/mnt/custom-addons/`
- Proceso de instalación
- Errores de dependencias o configuración

### Logs Relevantes
```bash
# Verificar que los módulos están disponibles
ls -la /mnt/custom-addons/

# Ver logs de instalación
grep "Módulo personalizado" /var/log/odoo/odoo.log
```

### Variables de Entorno Útiles
- `ODOO_ADDONS_PATH`: Personalizar rutas de addons
- `INSTALL_CUSTOM_MODULES`: Controlar instalación automática
- `LOG_LEVEL`: Nivel de logging (debug, info, warning, error)

## Consideraciones para Railway

### Límites de Memoria
- `limit_memory_hard`: 2.5GB
- `limit_memory_soft`: 2GB
- Workers configurados según los recursos disponibles

### Persistencia
- Los módulos se instalan en la base de datos PostgreSQL
- La configuración persiste entre reinicios
- Los archivos de módulos están en el contenedor (no persisten cambios en runtime)

### Actualizaciones
Para actualizar un módulo:
1. Modifica el código en tu repositorio
2. Incrementa la versión en `__manifest__.py`
3. Redespliega en Railway
4. El sistema detectará y actualizará automáticamente

## Módulos Incluidos

### query_deluxe
- **Descripción**: Ejecutor de consultas PostgreSQL en interfaz Odoo
- **Versión**: 18.0.0.1
- **Dependencias**: base, mail
- **Funcionalidades**:
  - Ejecución de consultas SQL personalizadas
  - Exportación a PDF con orientación configurable
  - Sistema de seguridad integrado

## Solución de Problemas

### Error: Módulo no encontrado
1. Verificar que el directorio tiene `__manifest__.py`
2. Comprobar permisos de archivos
3. Revisar dependencias en el manifest

### Error: Dependencias no satisfechas
1. Instalar módulos dependientes primero
2. Verificar nombres exactos en `depends`
3. Comprobar compatibilidad de versiones

### Error: Permisos de base de datos
1. Verificar configuración de PostgreSQL
2. Comprobar permisos del usuario Odoo
3. Revisar logs de conexión a BD

## Mejores Prácticas

1. **Versionado**: Siempre incrementa la versión al hacer cambios
2. **Dependencias**: Declara todas las dependencias explícitamente
3. **Seguridad**: Incluye archivos de seguridad apropiados
4. **Testing**: Prueba localmente antes de desplegar
5. **Documentación**: Documenta funcionalidades personalizadas
6. **Backup**: Respalda la base de datos antes de actualizaciones importantes
