# Configuración para Railway - Guía de Despliegue con Addons Personalizados

## Pasos para desplegar en Railway

### 1. Preparar el repositorio
Asegúrate de que todos los archivos estén committeados:
```bash
git add .
git commit -m "Configuración para Railway con addons personalizados"
git push origin main
```

### 2. Variables de entorno en Railway
En el dashboard de Railway, configura las siguientes variables de entorno:

**Variables requeridas:**
- `DATABASE_URL`: Se configura automáticamente al agregar PostgreSQL
- `PORT`: 8069 (Puerto por defecto de Odoo)
- `ODOO_ADMIN_PASSWD`: admin123 (o tu contraseña preferida)

**Variables opcionales (ya tienen valores por defecto):**
- `ODOO_ADDONS_PATH`: /usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons
- `ODOO_LOG_LEVEL`: info
- `ODOO_WORKERS`: 2

### 3. Agregar servicio PostgreSQL
En Railway:
1. Crear un nuevo servicio PostgreSQL
2. Railway automáticamente configurará `DATABASE_URL`

### 4. Configurar el servicio web
1. Conectar tu repositorio GitHub
2. Railway detectará automáticamente el `Dockerfile`
3. El build usará la configuración de `railway.toml`

### 5. Health Check
Railway verificará la salud de la aplicación en `/web/health`

## Estructura de Addons Personalizados

Los addons personalizados deben estar en la carpeta `addons/` con la siguiente estructura:

```
addons/
├── mi_addon/
│   ├── __init__.py
│   ├── __manifest__.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── mi_modelo.py
│   ├── views/
│   │   └── mi_vista.xml
│   └── security/
│       └── ir.model.access.csv
```

### Ejemplo de __manifest__.py
```python
{
    'name': 'Mi Addon Personalizado',
    'version': '18.0.1.0.0',
    'category': 'Custom',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/mi_vista.xml',
    ],
    'installable': True,
    'application': True,
}
```

## Monitoreo y Logs

Para ver los logs en Railway:
1. Ve al dashboard de tu proyecto
2. Selecciona el servicio web
3. Ve a la pestaña "Logs"

Los logs mostrarán:
- Inicio de Odoo
- Carga de addons personalizados
- Conexión a la base de datos
- Errores si los hay

## Actualización de Addons

Para actualizar addons existentes:
1. Modifica los archivos en la carpeta `addons/`
2. Commit y push los cambios
3. Railway hará redeploy automáticamente
4. Los addons se actualizarán automáticamente

## Troubleshooting

### Problema: Addon no se carga
- Verificar que `__manifest__.py` existe y es válido
- Verificar que las dependencias están correctas
- Revisar los logs para errores específicos

### Problema: Error de permisos
- Los permisos se configuran automáticamente en el Dockerfile
- Si persiste, verificar que el usuario `odoo` tiene acceso

### Problema: Base de datos no conecta
- Verificar que PostgreSQL está corriendo en Railway
- Verificar que `DATABASE_URL` está configurado
- Revisar logs de conexión

## URLs de acceso

Una vez desplegado:
- **Aplicación**: `https://tu-proyecto.railway.app`
- **Login**: Usuario `admin`, contraseña según `ODOO_ADMIN_PASSWD`
- **Health Check**: `https://tu-proyecto.railway.app/web/health`
