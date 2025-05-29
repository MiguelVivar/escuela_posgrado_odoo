# Configuración para despliegue en Railway

## 📦 Archivos de configuración agregados:

- `Dockerfile`: Imagen Docker optimizada para Railway
- `railway.toml`: Configuración específica de Railway
- `config/odoo-railway.conf`: Configuración de Odoo para producción
- `start.sh`: Script de inicio que maneja la conexión a PostgreSQL
- `.dockerignore`: Archivos excluidos del build

## 🚀 Pasos para desplegar en Railway:

### 1. Crear cuenta en Railway
1. Ve a [railway.app](https://railway.app)
2. Regístrate con GitHub
3. Conecta tu repositorio

### 2. Configurar la base de datos
1. En Railway, crea un nuevo proyecto
2. Agrega una base de datos PostgreSQL desde el catálogo de servicios
3. Railway generará automáticamente las variables de entorno para PostgreSQL

### 3. Configurar las variables de entorno
En Railway, configura estas variables de entorno:

**Variables automáticas de PostgreSQL (Railway las crea automáticamente):**
- `PGHOST` - Host de la base de datos
- `PGPORT` - Puerto de la base de datos (normalmente 5432)
- `PGUSER` - Usuario de la base de datos
- `PGPASSWORD` - Contraseña de la base de datos
- `PGDATABASE` - Nombre de la base de datos

**Variables adicionales (opcionales):**
- `ADMIN_PASSWORD` - Contraseña del usuario admin de PostgreSQL (si es diferente)

**Nota importante:** El script `start.sh` ha sido actualizado para:
- Detectar automáticamente las variables de Railway (`PGHOST`, `PGUSER`, etc.)
- Verificar si la base de datos existe y está inicializada
- Inicializar automáticamente Odoo si es necesario
- Generar la configuración de Odoo dinámicamente

### 4. Desplegar
1. Conecta tu repositorio Git a Railway
2. Railway detectará automáticamente el `Dockerfile`
3. El despliegue iniciará automáticamente

### 5. Acceder a tu aplicación
- Railway te proporcionará una URL pública
- El puerto 8069 será mapeado automáticamente
- Accede con usuario admin y contraseña: admin

## 🔧 Configuraciones optimizadas para Railway:

- **Detección automática de variables de entorno** de Railway
- **Configuración dinámica** de Odoo basada en variables de entorno
- **Verificación inteligente** de inicialización de base de datos
- **Workers limitados a 2** para mejor rendimiento en Railway
- **Memoria optimizada** para contenedores
- **Conexión automática** a PostgreSQL usando variables de Railway
- **Health check** incluido para verificar disponibilidad de la base de datos
- **Manejo robusto de errores** con logs detallados

## 🚀 Mejoras del script de inicio:

El script `start.sh` incluye las siguientes mejoras:
1. **Mapeo automático** de variables de Railway (`PGHOST` → `DB_HOST`, etc.)
2. **Verificación de inicialización** de la base de datos
3. **Generación dinámica** del archivo de configuración de Odoo
4. **Logs detallados** para debugging
5. **Manejo de errores** robusto

## 📋 Checklist de despliegue:

- [ ] Repositorio subido a GitHub
- [ ] Proyecto creado en Railway
- [ ] Base de datos PostgreSQL agregada
- [ ] Repositorio conectado a Railway
- [ ] Primer despliegue completado
- [ ] Aplicación accesible en la URL de Railway

## ⚠️ Notas importantes:

1. **Primer despliegue**: Puede tomar 5-10 minutos debido a la inicialización automática de Odoo
2. **Variables de entorno**: Se detectan automáticamente las variables de Railway
3. **Persistencia**: Los datos se guardan en PostgreSQL, no en el contenedor
4. **Logs**: Revisa los logs en Railway para ver el progreso de inicialización
5. **Configuración**: Se genera automáticamente basada en las variables de entorno

## 🆘 Solución de problemas:

### Error "Database not initialized" (El problema que experimentabas):
**Síntoma:** `Database odoo_db not initialized, you can force it with -i base`

**Solución implementada:**
- El script ahora verifica automáticamente si la base de datos está inicializada
- Si existe pero no está inicializada, ejecuta automáticamente la inicialización
- Logs detallados muestran el proceso de verificación e inicialización

### La aplicación no inicia:
- Verifica que la base de datos PostgreSQL esté corriendo en Railway
- Revisa los logs de Railway para errores específicos
- El script mostrará las variables de entorno detectadas

### Timeout durante la inicialización:
- Es normal en el primer despliegue
- Puede tomar hasta 10 minutos
- Los logs mostrarán "Inicializando la base de datos con módulo base..."

### Error de conexión a la base de datos:
- El script verificará automáticamente la conexión
- Mostrará las variables de entorno detectadas
- Verifica que PostgreSQL esté en el mismo proyecto de Railway

### Variables de entorno no detectadas:
- El script muestra todas las variables detectadas en los logs
- Railway debe crear automáticamente `PGHOST`, `PGUSER`, etc.
- Si no aparecen, recrea la base de datos en Railway
