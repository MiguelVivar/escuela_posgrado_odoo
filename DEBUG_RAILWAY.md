# DEBUG para problemas de deployment en Railway

## Problema identificado

El error que estás viendo indica que aunque PostgreSQL está disponible y acepta conexiones, Odoo no puede completar la inicialización de la base de datos. Esto puede deberse a:

1. **Permisos insuficientes del usuario de base de datos**
2. **Problemas de timeout en la conexión**
3. **Configuración incorrecta de variables de entorno**
4. **Problemas específicos de Railway con PostgreSQL**

## Soluciones implementadas

### 1. Script mejorado (`start.sh`)
- Mejor manejo de permisos de usuario
- Verificaciones adicionales de conexión
- Logging más detallado
- Timeouts de conexión configurables

### 2. Script alternativo (`start-alternative.sh`)
- Enfoque simplificado para la inicialización
- Mejor manejo de errores
- Creación automática de usuario si no existe

### 3. Script de debugging (`debug-connection.sh`)
- Diagnóstico completo de conectividad
- Verificación de permisos
- Test de operaciones de base de datos

## Cómo usar los scripts de debugging

### En Railway CLI:

```bash
# 1. Ejecutar el script de debugging
railway run /usr/local/bin/debug-connection.sh

# 2. Si hay problemas, usar el script alternativo
# Modificar temporalmente el Dockerfile para usar start-alternative.sh
```

### Modificación temporal del Dockerfile:

Para usar el script alternativo, cambia esta línea en el Dockerfile:

```dockerfile
# De:
COPY ./start.sh /usr/local/bin/start.sh

# A:
COPY ./start-alternative.sh /usr/local/bin/start.sh
```

## Variables de entorno a verificar en Railway

Asegúrate de que estas variables estén configuradas correctamente:

```
DB_HOST=postgres.railway.internal
DB_PORT=5432
DB_USER=odoo
DB_PASSWORD=[tu_password]
DB_NAME=odoo_db
PGHOST=postgres.railway.internal
PGPORT=5432
PGUSER=postgres
PGPASSWORD=[admin_password]
PGDATABASE=odoo_db
```

## Pasos de troubleshooting

1. **Ejecutar el script de debugging:**
   ```bash
   railway run /usr/local/bin/debug-connection.sh
   ```

2. **Verificar logs detallados:**
   ```bash
   railway logs --follow
   ```

3. **Conectarse manualmente a la base de datos:**
   ```bash
   railway connect postgres
   ```

4. **Si el problema persiste, usar script alternativo:**
   - Modificar Dockerfile para usar `start-alternative.sh`
   - Hacer redeploy

## Cambios principales en el código

### start.sh mejorado:
- Verificación de permisos antes de inicialización
- Mejor manejo de usuarios y conexiones
- Logging de debug más detallado
- Timeouts configurables

### start-alternative.sh:
- Enfoque más simple y directo
- Creación automática de usuarios
- Mejor manejo de errores de conexión
- Workers = 0 para reducir complejidad

### debug-connection.sh:
- Test completo de conectividad
- Verificación de permisos de usuario
- Diagnóstico de base de datos existentes
- Test de operaciones CRUD

## Próximos pasos recomendados

1. Hacer commit de los cambios
2. Hacer push al repositorio
3. Redeploy en Railway
4. Si el problema persiste, ejecutar el script de debugging
5. Basado en los resultados, decidir si usar el script alternativo

## Contacto para soporte adicional

Si estos cambios no resuelven el problema, proporciona:
1. Output completo del script de debugging
2. Logs completos de Railway
3. Variables de entorno configuradas (sin passwords)
