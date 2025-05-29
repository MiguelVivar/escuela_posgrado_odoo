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

**Variables automáticas de PostgreSQL (Railway las crea):**
- `PGHOST`
- `PGPORT` 
- `PGUSER`
- `PGPASSWORD`
- `PGDATABASE`

**Variables adicionales que debes agregar:**
```
INITIALIZE_DB=true
```

**Nota:** Después del primer despliegue exitoso, cambia `INITIALIZE_DB=false` para evitar reinicializar la base de datos.

### 4. Desplegar
1. Conecta tu repositorio Git a Railway
2. Railway detectará automáticamente el `Dockerfile`
3. El despliegue iniciará automáticamente

### 5. Acceder a tu aplicación
- Railway te proporcionará una URL pública
- El puerto 8069 será mapeado automáticamente
- Accede con usuario admin y contraseña: admin

## 🔧 Configuraciones optimizadas para Railway:

- **Workers limitados a 1** para el plan gratuito
- **Memoria optimizada** para contenedores pequeños
- **Proxy mode habilitado** para funcionar detrás del proxy de Railway
- **Conexión automática** a PostgreSQL usando variables de entorno
- **Health check** incluido para verificar disponibilidad de la base de datos

## 📋 Checklist de despliegue:

- [ ] Repositorio subido a GitHub
- [ ] Proyecto creado en Railway
- [ ] Base de datos PostgreSQL agregada
- [ ] Variables de entorno configuradas
- [ ] Primer despliegue completado
- [ ] `INITIALIZE_DB` cambiado a `false`
- [ ] Aplicación accesible en la URL de Railway

## ⚠️ Notas importantes:

1. **Primer despliegue**: Puede tomar 5-10 minutos debido a la inicialización de Odoo
2. **Límites del plan gratuito**: 1GB RAM, 1 vCPU
3. **Persistencia**: Los datos se guardan en PostgreSQL, no en el contenedor
4. **Logs**: Revisa los logs en Railway si hay problemas de conexión

## 🆘 Solución de problemas:

### La aplicación no inicia:
- Verifica que todas las variables de entorno estén configuradas
- Revisa los logs de Railway para errores específicos
- Asegúrate de que PostgreSQL esté corriendo

### Timeout durante la inicialización:
- Es normal en el primer despliegue
- Puede tomar hasta 10 minutos
- Verifica los logs para el progreso

### Error de conexión a la base de datos:
- Verifica las variables de entorno de PostgreSQL
- Asegúrate de que la base de datos esté en el mismo proyecto de Railway
