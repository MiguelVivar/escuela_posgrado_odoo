# DEBUG para problemas de deployment en Railway

## Problema identificado

**ACTUALIZACIÓN**: El problema ahora es que el usuario `odoo` existe pero no tiene permisos de esquema suficientes. El error específico es:

```
ERROR: permission denied for schema public
```

Esto indica que aunque el usuario puede conectarse, no tiene permisos para crear objetos en el esquema `public` de PostgreSQL.

## Solución implementada

### Script de corrección de permisos (`fix-permissions.sh`)
- Otorga permisos de SUPERUSER al usuario `odoo`
- Verifica que los permisos se hayan aplicado correctamente
- Solución rápida y directa para el problema actual

### Scripts mejorados
- `start.sh`: Ahora otorga automáticamente SUPERUSER al crear/verificar usuarios
- Eliminación de permisos granulares innecesarios
- Enfoque simplificado que funciona con Railway

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

### 🚀 SOLUCIÓN INMEDIATA (RECOMENDADA):

```bash
# 1. Ejecutar el script de corrección de permisos
railway run /usr/local/bin/fix-permissions.sh

# 2. Una vez otorgados los permisos de SUPERUSER, hacer redeploy
railway up --detach
```

### Alternativas si necesitas debugging:

```bash
# 1. Ejecutar el script de debugging completo
railway run /usr/local/bin/debug-connection.sh

# 2. Crear usuario desde cero si es necesario
railway run /usr/local/bin/create-odoo-user.sh
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

### ⚡ SOLUCIÓN RÁPIDA (Para el error actual):

1. **Otorgar permisos de SUPERUSER:**
   ```bash
   railway run /usr/local/bin/fix-permissions.sh
   ```

2. **Hacer redeploy:**
   ```bash
   railway up --detach
   ```

3. **Verificar logs:**
   ```bash
   railway logs --follow
   ```

### 🔍 DEBUGGING COMPLETO (Si persisten problemas):

1. **Ejecutar diagnóstico completo:**
   ```bash
   railway run /usr/local/bin/debug-connection.sh
   ```

2. **Conectarse manualmente a verificar:**
   ```bash
   railway connect postgres
   \du
   \l
   ```

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
