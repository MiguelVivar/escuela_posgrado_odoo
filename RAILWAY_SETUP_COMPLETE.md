# 🎓 Sistema de Gestión de Postgrado - Odoo 18 con Railway

**Configuración completa para despliegue en Railway con addons personalizados**

## 🌟 Resumen de Configuración Realizada

Tu proyecto ahora está **completamente configurado** para usar addons personalizados en Railway con las siguientes mejoras:

### ✅ Configuraciones Implementadas

1. **Dockerfile optimizado** para Railway con:
   - Dependencias Python adicionales para addons
   - Script de inicio específico para Railway (`start-railway.sh`)
   - Gestión automática de permisos
   - Soporte completo para variables de entorno

2. **Configuración de Odoo actualizada** (`config/odoo.conf`):
   - Path de addons incluyendo módulos estándar y personalizados
   - Configuración de base de datos para Railway
   - Modo proxy habilitado
   - Configuraciones de rendimiento optimizadas

3. **Railway.toml mejorado** con:
   - Health check configurado
   - Variables de entorno específicas
   - Configuración de restart policy

4. **Scripts automatizados**:
   - `start-railway.sh`: Inicio inteligente con detección automática de DB
   - `install-addons.sh`: Instalación automática de addons personalizados

5. **Addons de ejemplo** creados:
   - `escuela_base`: Módulo base del sistema
   - `escuela_estudiantes`: Ejemplo completo con modelos, vistas y funcionalidad

## 🚀 Pasos para Desplegar en Railway

### 1. Preparar el repositorio
```bash
git add .
git commit -m "Configuración completa para Railway con addons personalizados"
git push origin main
```

### 2. Configurar en Railway
1. **Conectar repositorio** a Railway
2. **Agregar PostgreSQL** como servicio
3. **Configurar variables de entorno** (opcional, ya tienen valores por defecto):
   ```env
   # Variables principales (Railway configura automáticamente DATABASE_URL)
   ODOO_ADMIN_PASSWD=admin123
   PORT=8069
   
   # Variables opcionales (ya configuradas por defecto)
   ODOO_LOG_LEVEL=info
   ODOO_WORKERS=2
   ```

### 3. Deploy automático
Railway detectará automáticamente:
- El `Dockerfile` optimizado
- La configuración en `railway.toml`
- El health check en `/web/health`

## 📦 Estructura de Addons Personalizados

Tu proyecto ya incluye ejemplos de addons bien estructurados:

```
addons/
├── escuela_base/              # ✅ Módulo base creado
│   ├── __manifest__.py        # Configuración del módulo
│   ├── __init__.py           # Importaciones
│   ├── models/               # Modelos de datos
│   ├── views/                # Interfaces de usuario
│   └── security/             # Permisos y accesos
│
├── escuela_estudiantes/       # ✅ Ejemplo completo creado
│   ├── __manifest__.py        # Sistema de estudiantes
│   ├── models/
│   │   ├── estudiante.py     # Modelo de estudiante
│   │   └── programa.py       # Modelo de programa
│   ├── views/                # Vistas del sistema
│   └── security/             # Control de acceso
│
└── [tus_addons_aquí]/        # 🔄 Agrega tus módulos aquí
```

## 🔧 Características Implementadas

### Script de Inicio Inteligente (`start-railway.sh`)
- **Detección automática** de variables de Railway vs configuración local
- **Verificación de conexión** a base de datos antes de iniciar
- **Creación automática** de base de datos si no existe
- **Configuración dinámica** según el entorno

### Dockerfile Optimizado
- **Dependencias Python** preinstaladas para addons comunes:
  - xlsxwriter (reportes Excel)
  - qrcode (códigos QR)
  - cryptography (seguridad)
  - requests (APIs externas)
  - Y más...

### Configuración Robusta
- **Addons path** configurado para incluir módulos estándar y personalizados
- **Proxy mode** habilitado para Railway
- **Workers** configurados para rendimiento óptimo
- **Logging** configurado adecuadamente

## 📊 Addons de Ejemplo Incluidos

### `escuela_base` - Módulo Base
- Configuración institucional
- Menús principales
- Estructura base para otros módulos

### `escuela_estudiantes` - Sistema Completo
- **Modelo Estudiante** con:
  - Información personal y académica
  - Estados de matriculación
  - Seguimiento (mail.thread)
  - Validaciones automáticas
- **Modelo Programa** con:
  - Tipos de programa (maestría, doctorado, etc.)
  - Duraciones y modalidades
  - Conteo automático de estudiantes
- **Funcionalidades**:
  - Generación automática de códigos
  - Cálculo de edad automático
  - Acciones de estado (activar, suspender, egresar)
  - Validaciones de datos

## 🌐 URLs de Acceso Post-Despliegue

Una vez desplegado en Railway:
- **Aplicación principal**: `https://tu-proyecto.railway.app`
- **Login**: 
  - Usuario: `admin`
  - Contraseña: según `ODOO_ADMIN_PASSWD` (por defecto: `admin123`)
- **Health check**: `https://tu-proyecto.railway.app/web/health`

## 🛠️ Desarrollo de Nuevos Addons

Para agregar tus propios addons:

### 1. Crear estructura básica
```bash
mkdir addons/mi_nuevo_addon
cd addons/mi_nuevo_addon
```

### 2. Crear archivos esenciales
```python
# __manifest__.py
{
    'name': 'Mi Addon Personalizado',
    'version': '18.0.1.0.0',
    'category': 'Custom',
    'depends': ['base', 'escuela_base'],  # Depender del módulo base
    'data': [
        'security/ir.model.access.csv',
        'views/mi_vista.xml',
    ],
    'installable': True,
    'application': True,
}
```

```python
# __init__.py
from . import models
```

### 3. Crear modelos
```python
# models/__init__.py
from . import mi_modelo

# models/mi_modelo.py
from odoo import models, fields, api

class MiModelo(models.Model):
    _name = 'mi.modelo'
    _description = 'Mi Modelo Personalizado'
    
    name = fields.Char('Nombre', required=True)
    # Agregar más campos según necesidad
```

### 4. Deploy automático
```bash
git add .
git commit -m "Agregado nuevo addon: mi_nuevo_addon"
git push origin main
```

Railway automáticamente:
- Rebuildeará la imagen
- Incluirá tu nuevo addon
- Lo hará disponible para instalación en Odoo

## 📈 Monitoreo y Logs

### En Railway Dashboard:
1. Ve a tu proyecto → Servicio web → Logs
2. Busca mensajes como:
   ```
   🚀 Iniciando Odoo en Railway...
   🌐 Usando variables de entorno de Railway
   ✅ Base de datos disponible
   📦 Addons personalizados disponibles:
   ✅ Addon encontrado: escuela_base
   ✅ Addon encontrado: escuela_estudiantes
   ```

### Verificar addons cargados:
1. Accede a tu aplicación en Railway
2. Ve a Apps → Update Apps List
3. Busca tus addons personalizados
4. Instálalos según necesidad

## 🔒 Variables de Entorno Recomendadas

### Esenciales (configurar en Railway):
```env
ODOO_ADMIN_PASSWD=tu_password_seguro_aqui
PORT=8069
```

### Opcionales (ya configuradas):
```env
ODOO_ADDONS_PATH=/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons
ODOO_LOG_LEVEL=info
ODOO_WORKERS=2
ODOO_PROXY_MODE=True
```

## 🚨 Troubleshooting

### Addon no aparece
1. Verificar que `__manifest__.py` existe y es válido
2. Verificar logs de Railway para errores de sintaxis
3. Revisar dependencias en el manifest

### Error de base de datos
1. Verificar que PostgreSQL está agregado en Railway
2. Verificar que `DATABASE_URL` está configurado automáticamente
3. Revisar logs de conexión

### Performance issues
1. Ajustar `ODOO_WORKERS` (valores recomendados: 2-4)
2. Monitorear uso de memoria en Railway
3. Optimizar consultas en addons personalizados

## 📚 Recursos y Documentación

- **Guía completa**: `RAILWAY_ADDONS_GUIDE.md` (creado en tu proyecto)
- **Variables de entorno**: `.env.railway` (ejemplo incluido)
- **Documentación Odoo**: https://www.odoo.com/documentation/18.0/
- **Railway Docs**: https://docs.railway.app/

## ✅ Lista de Verificación Final

- [x] Dockerfile optimizado para Railway
- [x] Scripts de inicio configurados
- [x] Railway.toml configurado
- [x] Odoo.conf actualizado para Railway
- [x] Addons de ejemplo creados
- [x] Documentación completa
- [x] Variables de entorno configuradas
- [x] Health check implementado
- [x] Permisos y seguridad configurados

## 🎯 Siguientes Pasos

1. **Commit y push** todos los cambios
2. **Conectar** a Railway
3. **Agregar PostgreSQL** en Railway
4. **Configurar** variables de entorno básicas
5. **Deploy** y verificar funcionamiento
6. **Desarrollar** tus addons personalizados
7. **Escalar** según necesidades

¡Tu proyecto está **100% listo** para Railway con soporte completo para addons personalizados! 🚀
