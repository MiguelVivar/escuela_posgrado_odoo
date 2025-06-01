# Logs Esperados Durante el Despliegue en Railway

## 🚀 Logs de un Despliegue Exitoso

Durante un despliegue exitoso en Railway, deberías ver logs similares a estos:

### 1. Inicio del Contenedor
```
=== Configuración de conexión ===
DB_HOST: postgres.railway.internal
DB_PORT: 5432
DB_USER: postgres
DB_NAME: railway
ADMIN_USER: postgres
=================================
```

### 2. Generación de Configuración
```
Generando configuración dinámica de Odoo...
Configuración de Odoo generada:
[options]
addons_path = /mnt/extra-addons
admin_passwd = admin
db_host = postgres.railway.internal
db_port = 5432
db_user = postgres
db_password = [HIDDEN]
db_name = railway
log_level = info
workers = 2
max_cron_threads = 1
list_db = False
db_template = template0
```

### 3. Verificación de PostgreSQL
```
Esperando a que PostgreSQL esté disponible en postgres.railway.internal:5432...
PostgreSQL está disponible!
Verificando credenciales de conexión...
Conexión a PostgreSQL establecida correctamente!
```

### 4. Verificación de Base de Datos
```
Verificando si la base de datos railway existe...
Verificando si la base de datos está inicializada...
DB_EXISTS: railway
DB_INITIALIZED: f
```

### 5. Inicialización (Solo Primera Vez)
```
La base de datos railway existe pero no está inicializada. Inicializando...
2025-05-29 23:45:00,000 1 INFO ? odoo: Odoo version 18.0-20250520
2025-05-29 23:45:00,000 1 INFO ? odoo: Using configuration file at /etc/odoo/odoo.conf
2025-05-29 23:45:00,000 1 INFO ? odoo: addons paths: ['/usr/lib/python3/dist-packages/odoo/addons', '/var/lib/odoo/.local/share/Odoo/addons/18.0', '/mnt/extra-addons', '/mnt/custom-addons']
2025-05-29 23:45:00,000 1 INFO ? odoo: database: postgres@postgres.railway.internal:5432
2025-05-29 23:45:05,000 1 INFO railway odoo.modules.loading: loading base
2025-05-29 23:45:30,000 1 INFO railway odoo.modules.loading: 42 modules loaded in 25.0s
Base de datos inicializada correctamente!

Verificando módulos personalizados disponibles...
Módulos personalizados encontrados en /mnt/custom-addons:
drwxr-xr-x 8 odoo odoo 4096 Jun  1 12:00 education_core
drwxr-xr-x 8 odoo odoo 4096 Jun  1 12:00 education_attendances
drwxr-xr-x 8 odoo odoo 4096 Jun  1 12:00 education_theme
drwxr-xr-x 8 odoo odoo 4096 Jun  1 12:00 muk_web_theme
drwxr-xr-x 8 odoo odoo 4096 Jun  1 12:00 om_hr_payroll

Módulo personalizado encontrado: education_core
Módulo personalizado encontrado: education_attendances
Módulo personalizado encontrado: education_theme
Módulo personalizado encontrado: muk_web_theme
Módulo personalizado encontrado: om_hr_payroll

Instalando módulos personalizados: education_core,education_attendances,education_theme,muk_web_theme,om_hr_payroll
2025-05-29 23:46:00,000 1 INFO railway odoo.modules.loading: loading education_core
2025-05-29 23:46:05,000 1 INFO railway odoo.modules.loading: loading education_attendances
2025-05-29 23:46:10,000 1 INFO railway odoo.modules.loading: loading education_theme
2025-05-29 23:46:15,000 1 INFO railway odoo.modules.loading: loading muk_web_theme
2025-05-29 23:46:20,000 1 INFO railway odoo.modules.loading: loading om_hr_payroll
Módulos personalizados instalados exitosamente!
```

### 5b. Verificación de Módulos (Despliegues Posteriores)
```
La base de datos railway ya existe y está inicializada.
Verificando módulos personalizados disponibles...
Módulos personalizados encontrados en /mnt/custom-addons:
drwxr-xr-x 8 odoo odoo 4096 Jun  1 12:00 education_core
drwxr-xr-x 8 odoo odoo 4096 Jun  1 12:00 education_attendances

Módulo personalizado encontrado: education_core
Estado del módulo education_core: installed
Módulo personalizado encontrado: education_attendances
Estado del módulo education_attendances: installed

Todos los módulos personalizados ya están instalados
```

### 6. Inicio Normal de Odoo
```
Iniciando Odoo normalmente...
Comando: python3 /usr/bin/odoo -c /etc/odoo/odoo.conf
2025-05-29 23:46:00,000 1 INFO ? odoo: Odoo version 18.0-20250520
2025-05-29 23:46:00,000 1 INFO ? odoo: Using configuration file at /etc/odoo/odoo.conf
2025-05-29 23:46:00,000 1 INFO ? odoo: addons paths: ['/usr/lib/python3/dist-packages/odoo/addons', '/var/lib/odoo/.local/share/Odoo/addons/18.0', '/mnt/extra-addons', '/mnt/custom-addons']
2025-05-29 23:46:00,000 1 INFO ? odoo: database: postgres@postgres.railway.internal:5432
2025-05-29 23:46:01,000 1 INFO ? odoo.service.server: HTTP service (werkzeug) running on [contenedor]:8069
2025-05-29 23:46:01,000 1 INFO railway odoo.modules.registry: Registry loaded in 0.5s
```

**Nota:** En el addons_path ahora debe aparecer `/mnt/custom-addons` para confirmar que los módulos personalizados están disponibles.

## ❌ Logs de Errores Comunes

### Error de Conexión a Base de Datos
```
Error: No se puede conectar a PostgreSQL con las credenciales proporcionadas
Verificando variables de entorno disponibles...
PGHOST=postgres.railway.internal
PGPORT=5432
PGUSER=postgres
PGPASSWORD=[HIDDEN]
PGDATABASE=railway
```

### Error de Inicialización
```
Error: Falló la inicialización de la base de datos
2025-05-29 23:40:00,000 1 ERROR ? odoo.modules.loading: Module base not found
```

## 🔍 Qué Buscar en los Logs

1. **Variables de entorno detectadas correctamente**
2. **Conexión exitosa a PostgreSQL**
3. **Configuración de Odoo generada**
4. **Inicialización completa (primera vez)**
5. **Servidor HTTP corriendo en puerto 8069**

## ⏱️ Tiempos Esperados

- **Primera inicialización**: 5-10 minutos
- **Despliegues posteriores**: 30-60 segundos
- **Carga del registro**: 0.5-2 segundos

## 🚨 Cuándo Contactar Soporte

Si ves estos logs, puede haber un problema más profundo:
- Timeouts constantes de PostgreSQL
- Errores de permisos persistentes
- Fallos de memoria (OOM)
- Errores de módulos de Odoo
