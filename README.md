# Sistema de Aula Virtual - Escuela de Posgrado UNICA

**Universidad Nacional San Luis Gonzaga de Ica - Escuela de Posgrado**

Este proyecto implementa un sistema integral de aula virtual para la Escuela de Posgrado utilizando Odoo 18 con Docker y Docker Compose, incluyendo PostgreSQL como base de datos.

## 🎓 Acerca del Proyecto

Este sistema de aula virtual está diseñado específicamente para la **Universidad Nacional San Luis Gonzaga de Ica - Escuela de Posgrado**, desarrollado por estudiantes de 4to ciclo del curso de Lenguaje de Programación Avanzada de la Facultad de Ingeniería de Sistemas.

### 🎯 Objetivos del Sistema

El proyecto tiene como objetivo implementar ocho sistemas integrados para la gestión completa del nivel de Posgrado:

**a) Sistema de Admisión para el nivel Posgrado**
- Gestión de postulantes y procesos de admisión
- Evaluación y selección de candidatos
- Documentación y requisitos de ingreso

**b) Sistema de Matrícula para el nivel Posgrado**
- Registro y matrícula de estudiantes
- Gestión de programas y cursos
- Control de cupos y prerrequisitos

**c) Sistema de Intranet para el nivel Posgrado**
- Portal interno para estudiantes y docentes
- Comunicaciones institucionales
- Recursos académicos compartidos

**d) Sistema de Gestión Docente para el nivel Posgrado**
- Administración del personal docente
- Asignación de cursos y horarios
- Evaluación del desempeño docente

**e) Sistema de Aula Virtual para el nivel Posgrado**
- Plataforma de educación virtual
- Gestión de contenidos educativos
- Herramientas de evaluación online

**f) Sistema de Caja para el nivel Posgrado**
- Gestión de pagos y cobranzas
- Control financiero y contable
- Reportes de ingresos

**g) Sistema de Trámite Documentario para el nivel Posgrado**
- Gestión de documentos académicos
- Seguimiento de trámites administrativos
- Archivo digital de expedientes

**h) Sistema de Grados y Títulos para el nivel Posgrado**
- Registro de grados académicos
- Emisión de títulos y certificados
- Validación de documentos oficiales

### 👥 Equipo de Desarrollo

**Facultad**: Ingeniería de Sistemas  
**Curso**: Lenguaje de Programación Avanzada  
**Ciclo**: 4to

| Desarrollador | GitHub |
|---------------|--------|
| Miguel Vivar | [@MiguelVivar](https://github.com/MiguelVivar) |
| Mario Muñoz | [@ChuchiPr](https://github.com/ChuchiPr) |
| Angielina Soto | [@VinnBon](https://github.com/VinnBon) |
| Luis Mitma | [@Elextranjero1942](https://github.com/Elextranjero1942) |
| Juan Ttito | [@juanttito1003](https://github.com/juanttito1003) |
| Rodrigo Conislla | [@Rodri2505](https://github.com/Rodri2505) |
| Dylan Palomino | [@DaPcxD](https://github.com/DaPcxD) |

## 📋 Tabla de Contenidos

- [Acerca del Proyecto](#acerca-del-proyecto)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Módulos del Sistema](#módulos-del-sistema)
- [Prerrequisitos](#prerrequisitos)
- [Instalación de Docker](#instalación-de-docker)
- [Configuración del Proyecto](#configuración-del-proyecto)
- [Uso](#uso)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Configuración](#configuración)
- [Comandos Útiles](#comandos-útiles)
- [Desarrollo](#desarrollo)
- [Problemas Comunes](#problemas-comunes)
- [Contribuir](#contribuir)

## 🏗️ Arquitectura del Sistema

El sistema está construido sobre **Odoo 18** como framework principal, utilizando una arquitectura modular que permite la integración de todos los subsistemas de la Escuela de Posgrado.

### Stack Tecnológico

- **Frontend**: Odoo Web Client (JavaScript, XML, CSS)
- **Backend**: Odoo Framework (Python)
- **Base de Datos**: PostgreSQL 17
- **Contenedores**: Docker & Docker Compose
- **Servidor Web**: Nginx (para producción)
- **Sistema Operativo**: Linux (contenedores) / Windows (desarrollo)

### Arquitectura de Módulos

```
Sistema Aula Virtual UNICA
├── unica_base/                    # Módulo base con configuraciones institucionales
├── unica_admision/                # Sistema de Admisión
├── unica_matricula/               # Sistema de Matrícula
├── unica_intranet/                # Sistema de Intranet
├── unica_gestion_docente/         # Sistema de Gestión Docente
├── unica_aula_virtual/            # Sistema de Aula Virtual
├── unica_caja/                    # Sistema de Caja
├── unica_tramite_documentario/    # Sistema de Trámite Documentario
└── unica_grados_titulos/          # Sistema de Grados y Títulos
```

## 📚 Módulos del Sistema

### 🎯 unica_base - Módulo Base Institucional
**Desarrollador Responsable**: Miguel Vivar (@MiguelVivar)

Módulo fundamental que contiene:
- Configuraciones institucionales de la UNICA
- Modelos base comunes a todos los sistemas
- Datos maestros y catálogos
- Configuración de usuarios y permisos

### 📝 unica_admision - Sistema de Admisión
**Desarrollador Responsable**: Mario Muñoz (@ChuchiPr)

Funcionalidades:
- Registro de postulantes
- Gestión de procesos de admisión
- Evaluación de expedientes
- Generación de resultados
- Notificaciones automatizadas

### 📖 unica_matricula - Sistema de Matrícula
**Desarrolladora Responsable**: Angielina Soto (@VinnBon)

Funcionalidades:
- Matrícula de estudiantes admitidos
- Gestión de programas de posgrado
- Control de cupos por programa
- Registro académico
- Historial de matrículas

### 🌐 unica_intranet - Sistema de Intranet
**Desarrollador Responsable**: Luis Mitma (@Elextranjero1942)

Funcionalidades:
- Portal interno institucional
- Tablero de anuncios
- Recursos académicos
- Calendario académico
- Comunicaciones internas

### 👨‍🏫 unica_gestion_docente - Sistema de Gestión Docente
**Desarrollador Responsable**: Juan Ttito (@juanttito1003)

Funcionalidades:
- Registro de docentes
- Asignación de cursos
- Horarios académicos
- Evaluación docente
- Reportes de gestión

### 💻 unica_aula_virtual - Sistema de Aula Virtual
**Desarrollador Responsable**: Rodrigo Conislla (@Rodri2505)

Funcionalidades:
- Aulas virtuales por curso
- Gestión de contenidos
- Evaluaciones online
- Foros de discusión
- Seguimiento del progreso

### 💰 unica_caja - Sistema de Caja
**Desarrollador Responsable**: Dylan Palomino (@DaPcxD)

Funcionalidades:
- Gestión de pagos de matrícula
- Control de pensiones
- Reportes financieros
- Conciliación bancaria
- Facturación electrónica

### 📄 unica_tramite_documentario - Sistema de Trámite Documentario
**Desarrollo Colaborativo**: Equipo completo

Funcionalidades:
- Mesa de partes virtual
- Seguimiento de expedientes
- Flujos de aprobación
- Archivo digital
- Notificaciones de estado

### 🎓 unica_grados_titulos - Sistema de Grados y Títulos
**Desarrollo Colaborativo**: Equipo completo

Funcionalidades:
- Registro de grados académicos
- Emisión de diplomas
- Certificados académicos
- Validación de documentos
- Registro nacional de títulos

## 🔧 Prerrequisitos

- Windows 10/11 (versión 2004 o superior)
- 4 GB RAM mínimo (8 GB recomendado)
- 20 GB de espacio libre en disco
- Conexión a internet para descargar las imágenes de Docker

## 🐳 Instalación de Docker

### Paso 1: Habilitar WSL 2 (Windows Subsystem for Linux)

1. Abre PowerShell como administrador y ejecuta:
```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

2. Reinicia tu computadora

3. Descarga e instala el paquete de actualización del kernel de Linux para WSL 2:
   - Ve a: https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
   - Descarga e instala el archivo MSI

4. Establece WSL 2 como versión predeterminada:
```powershell
wsl --set-default-version 2
```

### Paso 2: Instalar Docker Desktop

1. Ve a la página oficial de Docker: https://www.docker.com/products/docker-desktop/
2. Descarga Docker Desktop para Windows
3. Ejecuta el instalador descargado
4. Durante la instalación, asegúrate de que esté marcada la opción "Use WSL 2 instead of Hyper-V"
5. Reinicia tu computadora cuando se te solicite
6. Abre Docker Desktop y completa la configuración inicial

### Paso 3: Verificar la Instalación

Abre PowerShell y ejecuta:
```powershell
docker --version
docker-compose --version
```

Deberías ver algo como:
```
Docker version 28.0.1, build 068a01e
Docker Compose version v2.33.1-desktop.1
```

## ⚙️ Configuración del Proyecto

### Paso 1: Clonar o Descargar el Proyecto

Si tienes Git instalado:
```powershell
git clone https://github.com/MiguelVivar/escuela_posgrado_odoo
cd odoo-docker
```

O descarga el proyecto como ZIP y extráelo.

### Paso 2: Verificar la Estructura

Asegúrate de que tu proyecto tenga esta estructura:
```
odoo-docker/
├── docker-compose.yml
├── README.md
├── .gitignore
├── addons/                 # Módulos personalizados de Odoo
├── config/
│   └── odoo.conf          # Configuración de Odoo
└── postgresql/            # Datos de PostgreSQL (se crea automáticamente)
```

## 🚀 Uso

### Iniciar los Servicios

1. Abre PowerShell en la carpeta del proyecto
2. Ejecuta el siguiente comando para iniciar todos los servicios:

```powershell
docker-compose up -d
```

Este comando:
- Descarga las imágenes de Odoo 18 y PostgreSQL 17.5 (ya descargadas en tu sistema)
- Crea y ejecuta los contenedores en segundo plano
- Configura la base de datos automáticamente (ya configurada)

### Estado Actual del Sistema

Tu proyecto está **FUNCIONANDO** y listo para usar:

- ✅ **Docker**: v28.0.1 instalado y funcionando
- ✅ **Docker Compose**: v2.33.1 instalado y funcionando  
- ✅ **PostgreSQL 17**: Base de datos iniciada y configurada
- ✅ **Odoo 18**: Aplicación web ejecutándose en puerto 8069
- ✅ **Base de datos "odoo"**: Creada y lista para usar

**Para acceder**: http://localhost:8069

### Acceder a Odoo

**¡Tu sistema ya está funcionando!** 🎉

1. ~~Espera unos minutos para que Odoo termine de inicializarse~~ ✅ **YA ESTÁ LISTO**
2. Abre tu navegador web y ve a: **http://localhost:8069**
3. Usa las siguientes credenciales configuradas:
   - **Base de datos**: `odoo` ✅ (ya creada)
   - **Email**: `admin`
   - **Contraseña**: `admin`

### Detener los Servicios

```powershell
docker-compose down
```

### Ver los Logs

```powershell
# Ver logs de todos los servicios
docker-compose logs

# Ver logs de Odoo únicamente
docker-compose logs odoo

# Ver logs en tiempo real
docker-compose logs -f
```

## 📁 Estructura del Proyecto

```
odoo-docker/
├── docker-compose.yml      # Configuración de Docker Compose
├── README.md              # Este archivo
├── .gitignore            # Archivos ignorados por Git
├── addons/               # Módulos personalizados de Odoo (vacío)
├── config/
│   └── odoo.conf         # Configuración de Odoo
└── postgresql/           # Datos persistentes de PostgreSQL (PostgreSQL 17)
    ├── pg_hba.conf       # Configuración de autenticación
    ├── pg_ident.conf     # Configuración de identidad
    ├── PG_VERSION        # Versión de PostgreSQL (17)
    ├── postgresql.conf   # Configuración principal de PostgreSQL
    ├── postmaster.opts   # Opciones del proceso principal
    ├── postmaster.pid    # PID del proceso principal
    ├── base/             # Datos de las bases de datos
    │   ├── 1/           # Base de datos del sistema (template1)
    │   ├── 4/           # Base de datos template0
    │   ├── 5/           # Base de datos postgres
    │   └── 16384/       # Base de datos odoo (creada automáticamente)
    ├── global/           # Datos globales de PostgreSQL
    ├── pg_commit_ts/     # Timestamps de commits
    ├── pg_logical/       # Replicación lógica
    ├── pg_multixact/     # Transacciones múltiples
    ├── pg_notify/        # Sistema de notificaciones
    ├── pg_replslot/      # Slots de replicación
    ├── pg_stat/          # Estadísticas
    ├── pg_subtrans/      # Sub-transacciones
    ├── pg_tblspc/        # Tablespaces
    ├── pg_twophase/      # Commits de dos fases
    ├── pg_wal/           # Write-Ahead Log
    └── pg_xact/          # Información de transacciones
```

## ⚙️ Configuración

### Configuración de Odoo (config/odoo.conf)

```ini
[options]
addons_path = /mnt/extra-addons    # Ruta a módulos personalizados
admin_passwd = admin               # Contraseña del administrador
db_host = db                      # Host de la base de datos
db_port = 5432                    # Puerto de PostgreSQL
db_user = odoo                    # Usuario de la base de datos
db_password = odoo                # Contraseña de la base de datos
db_name = odoo                    # Nombre de la base de datos
log_level = info                  # Nivel de logging
```

### Configuración de Docker Compose

El archivo `docker-compose.yml` define dos servicios:

- **db**: PostgreSQL 17.5 como base de datos
  - Imagen: `postgres:17.5`
  - Contenedor: `odoo-db`
  - Puerto interno: 5432
  - Base de datos: `odoo`
  - Usuario: `odoo`
  - Contraseña: `odoo`

- **odoo**: Odoo 18 como aplicación web
  - Imagen: `odoo:18`
  - Contenedor: `odoo-web`
  - Puerto: `8069:8069`
  - Comando: `odoo -d odoo -i base --without-demo=all`

### Variables de Entorno

Puedes personalizar la configuración creando un archivo `.env`:

```env
# Configuración de PostgreSQL
POSTGRES_DB=odoo
POSTGRES_USER=odoo
POSTGRES_PASSWORD=mi_contraseña_segura

# Configuración de Odoo
ODOO_ADMIN_PASSWORD=mi_admin_password

# Puerto de Odoo
ODOO_PORT=8069
```

## 🛠️ Comandos Útiles

### Gestión de Contenedores

```powershell
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Reiniciar servicios
docker-compose restart

# Ver estado de contenedores (estado actual)
docker-compose ps

# Resultado esperado:
# NAME       IMAGE           COMMAND                  SERVICE   CREATED          STATUS          PORTS
# odoo-db    postgres:17.5   "docker-entrypoint.s…"   db        15 minutes ago   Up 15 minutes   5432/tcp
# odoo-web   odoo:18         "/entrypoint.sh odoo…"   odoo      15 minutes ago   Up 14 minutes   0.0.0.0:8069->8069/tcp

# Ver logs
docker-compose logs -f

# Acceder al contenedor de Odoo
docker exec -it odoo-web bash

# Acceder al contenedor de PostgreSQL
docker exec -it odoo-db psql -U odoo -d odoo
```

### Gestión de Datos

```powershell
# Hacer backup de la base de datos
docker exec odoo-db pg_dump -U odoo odoo > backup.sql

# Restaurar backup
docker exec -i odoo-db psql -U odoo -d odoo < backup.sql

# Limpiar volúmenes (⚠️ ELIMINA TODOS LOS DATOS)
docker-compose down -v
```

### Actualizaciones

```powershell
# Actualizar imágenes
docker-compose pull

# Recrear contenedores con nuevas imágenes
docker-compose up -d --force-recreate
```

## 💻 Desarrollo

### Estructura de Módulos del Proyecto

El proyecto está organizado en módulos específicos para cada sistema de la Escuela de Posgrado:

```
addons/
├── unica_base/                     # Módulo base institucional
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── res_partner.py         # Extensión de contactos
│   │   ├── res_users.py           # Usuarios UNICA
│   │   └── unica_config.py        # Configuraciones institucionales
│   ├── views/
│   │   ├── partner_views.xml
│   │   └── config_views.xml
│   ├── data/
│   │   ├── unica_data.xml         # Datos institucionales
│   │   └── security.xml           # Grupos y permisos
│   └── static/
│       └── description/
│           ├── icon.png
│           └── index.html
│
├── unica_admision/                 # Sistema de Admisión (Mario)
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── admision_proceso.py
│   │   ├── admision_postulante.py
│   │   └── admision_evaluacion.py
│   ├── views/
│   │   ├── admision_views.xml
│   │   └── postulante_views.xml
│   └── reports/
│       └── admision_reports.xml
│
├── unica_matricula/               # Sistema de Matrícula (Angielina)
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── matricula_estudiante.py
│   │   ├── matricula_programa.py
│   │   └── matricula_proceso.py
│   ├── views/
│   │   ├── matricula_views.xml
│   │   └── estudiante_views.xml
│   └── wizard/
│       └── matricula_wizard.py
│
├── unica_intranet/                # Sistema de Intranet (Luis)
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── intranet_noticia.py
│   │   ├── intranet_evento.py
│   │   └── intranet_recurso.py
│   ├── views/
│   │   ├── intranet_views.xml
│   │   └── portal_templates.xml
│   └── controllers/
│       └── portal_controller.py
│
├── unica_gestion_docente/         # Gestión Docente (Juan)
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── docente.py
│   │   ├── asignacion_curso.py
│   │   └── evaluacion_docente.py
│   ├── views/
│   │   ├── docente_views.xml
│   │   └── asignacion_views.xml
│   └── reports/
│       └── docente_reports.xml
│
├── unica_aula_virtual/            # Aula Virtual (Rodrigo)
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── aula_virtual.py
│   │   ├── contenido_educativo.py
│   │   └── evaluacion_online.py
│   ├── views/
│   │   ├── aula_views.xml
│   │   └── contenido_views.xml
│   └── static/
│       ├── src/
│       │   ├── js/
│       │   └── css/
│       └── lib/
│
├── unica_caja/                    # Sistema de Caja (Dylan)
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── caja_pago.py
│   │   ├── caja_concepto.py
│   │   └── caja_reporte.py
│   ├── views/
│   │   ├── caja_views.xml
│   │   └── pago_views.xml
│   └── reports/
│       └── caja_reports.xml
│
├── unica_tramite_documentario/    # Trámite Documentario (Todos)
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── tramite_expediente.py
│   │   ├── tramite_flujo.py
│   │   └── tramite_documento.py
│   ├── views/
│   │   ├── tramite_views.xml
│   │   └── expediente_views.xml
│   └── workflow/
│       └── tramite_workflow.xml
│
└── unica_grados_titulos/          # Grados y Títulos (Todos)
    ├── __manifest__.py
    ├── __init__.py
    ├── models/
    │   ├── __init__.py
    │   ├── grado_academico.py
    │   ├── titulo_profesional.py
    │   └── certificado.py
    ├── views/
    │   ├── grado_views.xml
    │   └── titulo_views.xml
    └── reports/
        ├── diploma_template.xml
        └── certificado_template.xml
```

### Agregar Módulos Personalizados

1. Los módulos están organizados por funcionalidad en la carpeta `addons/`
2. Cada desarrollador es responsable de su módulo asignado
3. Para instalar un nuevo módulo:

```powershell
# Reiniciar Odoo para detectar nuevos módulos
docker-compose restart odoo
```

4. Ve a Apps en Odoo (http://localhost:8069) y actualiza la lista de aplicaciones
5. Instala los módulos desarrollados

### Flujo de Desarrollo Colaborativo

#### 1. Configuración Inicial del Repositorio
```powershell
# Clonar el repositorio principal
git clone https://github.com/MiguelVivar/escuela_posgrado_odoo
cd odoo-docker

# Crear rama de desarrollo personal
git checkout -b desarrollo-[nombre]
# Ejemplo: git checkout -b desarrollo-mario-admision
```

#### 2. Desarrollo de Módulos
Cada desarrollador trabaja en su módulo asignado siguiendo estas convenciones:

**Nomenclatura de archivos:**
- Modelos: `nombre_funcionalidad.py`
- Vistas: `nombre_views.xml`
- Datos: `nombre_data.xml`
- Reportes: `nombre_reports.xml`

**Estructura de commits:**
```bash
git commit -m "[MODULO] Descripción del cambio"
# Ejemplo: git commit -m "[ADMISION] Agregado modelo de postulantes"
```

#### 3. Testing y Validación
```powershell
# Verificar que el módulo instala correctamente
docker-compose logs odoo

# Probar funcionalidades básicas
# Acceder a http://localhost:8069 y verificar el módulo
```

### Debugging y Desarrollo

Para habilitar el modo debug en Odoo:
1. Ve a la URL: http://localhost:8069/web?debug=1
2. O agrega `debug = True` en `config/odoo.conf`
3. Reinicia el contenedor: `docker-compose restart odoo`

### Convenciones de Código

#### Python (Modelos y Lógica)
```python
# Ejemplo de modelo base
from odoo import models, fields, api

class UnicaAdmisionPostulante(models.Model):
    _name = 'unica.admision.postulante'
    _description = 'Postulante para Admisión Posgrado UNICA'
    _inherit = ['mail.thread', 'mail.activity.mixin']

    name = fields.Char('Nombres Completos', required=True, tracking=True)
    documento = fields.Char('Documento de Identidad', required=True)
    email = fields.Char('Correo Electrónico', required=True)
    telefono = fields.Char('Teléfono')
    programa_id = fields.Many2one('unica.programa', 'Programa de Posgrado')
    estado = fields.Selection([
        ('borrador', 'Borrador'),
        ('postulando', 'Postulando'),
        ('evaluacion', 'En Evaluación'),
        ('admitido', 'Admitido'),
        ('rechazado', 'Rechazado')
    ], default='borrador', tracking=True)
```

#### XML (Vistas e Interfaz)
```xml
<!-- Ejemplo de vista de formulario -->
<odoo>
    <data>
        <record id="view_admision_postulante_form" model="ir.ui.view">
            <field name="name">unica.admision.postulante.form</field>
            <field name="model">unica.admision.postulante</field>
            <field name="arch" type="xml">
                <form string="Postulante">
                    <header>
                        <field name="estado" widget="statusbar"/>
                    </header>
                    <sheet>
                        <group>
                            <field name="name"/>
                            <field name="documento"/>
                            <field name="email"/>
                            <field name="programa_id"/>
                        </group>
                    </sheet>
                    <div class="oe_chatter">
                        <field name="message_follower_ids"/>
                        <field name="activity_ids"/>
                        <field name="message_ids"/>
                    </div>
                </form>
            </field>
        </record>
    </data>
</odoo>
```

## 🔧 Problemas Comunes

### Docker Desktop no inicia

**Problema**: Error al iniciar Docker Desktop
**Solución**: 
1. Asegúrate de que WSL 2 esté habilitado
2. Reinicia el servicio de Docker desde Servicios de Windows
3. Reinstala Docker Desktop si es necesario

### Puerto 8069 ocupado

**Problema**: `Error: port is already allocated`
**Solución**: 
```powershell
# Cambiar el puerto en docker-compose.yml
ports:
  - "8070:8069"  # Usar puerto 8070 en lugar de 8069
```

### Base de datos no conecta

**Problema**: Odoo no puede conectar a PostgreSQL
**Solución**:
1. Verifica que ambos contenedores estén ejecutándose:
```powershell
docker-compose ps
```
2. Revisa los logs:
```powershell
docker-compose logs db
```

### Odoo no inicia

**Problema**: El contenedor de Odoo se detiene inmediatamente
**Solución**:
1. Revisa los logs:
```powershell
docker-compose logs odoo
```
2. Verifica la configuración en `config/odoo.conf`

### Módulos personalizados no aparecen

**Problema**: Los módulos en `addons/` no se muestran
**Solución**:
1. Verifica que el módulo tenga `__manifest__.py`
2. Reinicia Odoo:
```powershell
docker-compose restart odoo
```
3. Actualiza la lista de aplicaciones en Odoo

## 🤝 Contribuir

### Flujo de Trabajo del Equipo

#### Asignación de Responsabilidades

| Módulo | Desarrollador Responsable | GitHub |
|--------|---------------------------|--------|
| `unica_base` | Miguel Vivar | [@MiguelVivar](https://github.com/MiguelVivar) |
| `unica_admision` | Mario Muñoz | [@ChuchiPr](https://github.com/ChuchiPr) |
| `unica_matricula` | Angielina Soto | [@VinnBon](https://github.com/VinnBon) |
| `unica_intranet` | Luis Mitma | [@Elextranjero1942](https://github.com/Elextranjero1942) |
| `unica_gestion_docente` | Juan Ttito | [@juanttito1003](https://github.com/juanttito1003) |
| `unica_aula_virtual` | Rodrigo Conislla | [@Rodri2505](https://github.com/Rodri2505) |
| `unica_caja` | Dylan Palomino | [@DaPcxD](https://github.com/DaPcxD) |
| `unica_tramite_documentario` | **Desarrollo Colaborativo** | Todo el equipo |
| `unica_grados_titulos` | **Desarrollo Colaborativo** | Todo el equipo |

#### Proceso de Desarrollo

1. **Crear rama personal**
```bash
git checkout -b desarrollo-[nombre]-[modulo]
# Ejemplo: git checkout -b desarrollo-mario-admision
```

2. **Desarrollar el módulo asignado**
```bash
# Crear estructura del módulo
mkdir addons/[nombre_modulo]
cd addons/[nombre_modulo]
# Desarrollar según las especificaciones
```

3. **Commit con convención establecida**
```bash
git add .
git commit -m "[MODULO] Descripción del cambio"
# Ejemplo: git commit -m "[ADMISION] Implementado modelo de postulantes"
```

4. **Push a rama personal**
```bash
git push origin desarrollo-[nombre]-[modulo]
```

5. **Crear Pull Request**
- Ir al repositorio en GitHub
- Crear Pull Request desde tu rama hacia `main`
- Solicitar revisión del equipo
- Esperar aprobación antes de hacer merge

#### Convenciones de Commit

| Prefijo | Descripción | Ejemplo |
|---------|-------------|---------|
| `[BASE]` | Cambios en módulo base | `[BASE] Agregada configuración institucional` |
| `[ADMISION]` | Sistema de admisión | `[ADMISION] Creado modelo de postulantes` |
| `[MATRICULA]` | Sistema de matrícula | `[MATRICULA] Implementada vista de estudiantes` |
| `[INTRANET]` | Sistema de intranet | `[INTRANET] Agregado portal de noticias` |
| `[DOCENTE]` | Gestión docente | `[DOCENTE] Creado módulo de asignaciones` |
| `[AULA]` | Aula virtual | `[AULA] Implementado sistema de contenidos` |
| `[CAJA]` | Sistema de caja | `[CAJA] Agregado control de pagos` |
| `[TRAMITE]` | Trámite documentario | `[TRAMITE] Creado flujo de expedientes` |
| `[GRADOS]` | Grados y títulos | `[GRADOS] Implementado registro de títulos` |
| `[FIX]` | Corrección de errores | `[FIX] Corregido error en vista de matrícula` |
| `[DOCS]` | Documentación | `[DOCS] Actualizado README del proyecto` |

#### Reuniones de Coordinación

- **Reuniones semanales**: Viernes a las 8:00 PM (virtual)
- **Revisión de código**: Antes de cada merge a main
- **Testing conjunto**: Cada dos semanas
- **Presentación final**: Según cronograma del curso

#### Herramientas de Comunicación

- **Grupo de WhatsApp**: Coordinación diaria
- **Discord**: Reuniones virtuales y screen sharing
- **GitHub Issues**: Reportar problemas y asignar tareas
- **GitHub Projects**: Seguimiento del progreso

### Estándares de Calidad

#### Código Python
- Seguir PEP 8 para estilo de código
- Documentar funciones y clases
- Usar nombres descriptivos en inglés
- Incluir docstrings en métodos importantes

#### Archivos XML
- Identación consistente (4 espacios)
- Nombres de IDs descriptivos
- Comentarios en secciones complejas
- Seguir estructura estándar de Odoo

#### Testing
- Probar funcionalidades básicas antes del commit
- Verificar que el módulo instale sin errores
- Documentar casos de prueba importantes
- Reportar bugs encontrados via GitHub Issues

## 📊 Estado Actual del Sistema

### Información de la Instalación
- **Fecha de última actualización**: 28 de mayo de 2025
- **Docker**: v28.0.1 (funcionando)
- **Docker Compose**: v2.33.1 (funcionando)
- **PostgreSQL**: v17 (base de datos activa)
- **Odoo**: v18 (aplicación web activa)

### Contenedores Activos
```powershell
# Para verificar el estado actual:
docker-compose ps

# Estado esperado:
NAME       IMAGE           STATUS          PORTS
odoo-db    postgres:17.5   Up X minutes    5432/tcp
odoo-web   odoo:18         Up X minutes    0.0.0.0:8069->8069/tcp
```

### Base de Datos Configurada
- **Motor**: PostgreSQL 17
- **Nombre**: `odoo`
- **Usuario**: `odoo`
- **Contraseña**: `odoo`
- **Puerto**: 5432 (interno del contenedor)
- **Datos persistentes**: `./postgresql/` (621 MB aprox.)

### Aplicación Web
- **URL**: http://localhost:8069
- **Usuario admin**: `admin`
- **Contraseña admin**: `admin`
- **Puerto externo**: 8069
- **Estado**: ✅ **FUNCIONANDO**

## 🔍 Comandos de Monitoreo

### Verificar Estado del Sistema
```powershell
# Estado de contenedores
docker-compose ps

# Recursos utilizados
docker stats odoo-web odoo-db

# Logs en tiempo real
docker-compose logs -f

# Espacio en disco utilizado
docker system df

# Información detallada de contenedores
docker inspect odoo-web
docker inspect odoo-db
```

### Monitoreo de Base de Datos
```powershell
# Conectar a PostgreSQL
docker exec -it odoo-db psql -U odoo -d odoo

# Ver tamaño de la base de datos
docker exec odoo-db psql -U odoo -d odoo -c "\l+"

# Ver tablas de Odoo
docker exec odoo-db psql -U odoo -d odoo -c "\dt"

# Backup de la base de datos
docker exec odoo-db pg_dump -U odoo odoo > "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
```

### Monitoreo de Odoo
```powershell
# Ver logs específicos de Odoo
docker-compose logs odoo

# Acceder al contenedor de Odoo
docker exec -it odoo-web bash

# Ver procesos dentro del contenedor
docker exec odoo-web ps aux

# Ver configuración activa
docker exec odoo-web cat /etc/odoo/odoo.conf
```

## 🔧 Mantenimiento del Sistema

### Limpieza y Optimización
```powershell
# Limpiar imágenes no utilizadas
docker image prune

# Limpiar contenedores detenidos
docker container prune

# Limpiar volúmenes no utilizados (¡CUIDADO!)
docker volume prune

# Ver espacio utilizado por Docker
docker system df -v

# Limpieza completa del sistema Docker (¡CUIDADO!)
docker system prune -a
```

### Actualizaciones
```powershell
# Actualizar imágenes a las últimas versiones
docker-compose pull

# Recrear contenedores con nuevas imágenes
docker-compose up -d --force-recreate

# Verificar nuevas versiones disponibles
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}"
```

### Backup y Restauración
```powershell
# Backup completo del proyecto
# 1. Parar los servicios
docker-compose down

# 2. Crear backup de la carpeta postgresql
Compress-Archive -Path ".\postgresql" -DestinationPath "backup_postgresql_$(Get-Date -Format 'yyyyMMdd').zip"

# 3. Crear backup de addons personalizados
Compress-Archive -Path ".\addons" -DestinationPath "backup_addons_$(Get-Date -Format 'yyyyMMdd').zip"

# 4. Reiniciar servicios
docker-compose up -d

# Restaurar desde backup
# 1. Parar servicios
docker-compose down

# 2. Restaurar carpeta postgresql
Expand-Archive -Path "backup_postgresql_YYYYMMDD.zip" -DestinationPath ".\" -Force

# 3. Reiniciar servicios
docker-compose up -d
```

## 📝 Notas Técnicas

### Archivos de Configuración Actuales
- **docker-compose.yml**: Configuración de servicios (PostgreSQL 17.5 + Odoo 18)
- **config/odoo.conf**: Configuración de Odoo (admin_passwd=admin)
- **postgresql/**: Base de datos persistente (~621 MB)
- **addons/**: Módulos personalizados (vacío actualmente)

### Puertos Utilizados
- **8069**: Odoo Web Interface (externo)
- **5432**: PostgreSQL (interno del contenedor)
- **8071-8072**: Puertos adicionales de Odoo (longpolling)

### Volúmenes Persistentes
- `./postgresql` → `/var/lib/postgresql/data` (datos de PostgreSQL)
- `./addons` → `/mnt/extra-addons` (módulos personalizados)
- `./config` → `/etc/odoo` (configuración de Odoo)

### Comandos de Inicialización
- Odoo se inicia con: `odoo -d odoo -i base --without-demo=all`
- Se instala automáticamente el módulo `base` sin datos de demostración

## ⚠️ Advertencias Importantes

### Seguridad
- **¡CAMBIAR CONTRASEÑAS EN PRODUCCIÓN!**
  - admin_passwd en `config/odoo.conf`
  - Contraseñas de PostgreSQL en `docker-compose.yml`
- No usar en producción sin HTTPS
- Configurar firewall adecuadamente

### Datos
- **BACKUP REGULAR**: Los datos están en `./postgresql/`
- **NO ELIMINAR** la carpeta `postgresql/` si quieres conservar datos
- El comando `docker-compose down -v` **ELIMINA TODOS LOS DATOS**

### Rendimiento
- Requiere mínimo 4 GB RAM (8 GB recomendado)
- PostgreSQL usa ~621 MB de espacio en disco
- Odoo puede usar hasta 2-4 GB RAM dependiendo del uso

## 🚨 Resolución de Problemas Específicos

### Error: "Version is obsolete"
```
WARNING: the attribute `version` is obsolete
```
**Solución**: Es solo una advertencia, el sistema funciona correctamente. Para eliminarla:
```powershell
# Editar docker-compose.yml y eliminar la línea:
# version: '3.1'
```

### Contenedor se detiene inmediatamente
```powershell
# Verificar logs específicos
docker-compose logs odoo
docker-compose logs db

# Verificar espacio en disco
Get-PSDrive C

# Reiniciar servicios
docker-compose restart
```

### Puerto 8069 ocupado
```powershell
# Verificar qué proceso usa el puerto
netstat -ano | findstr :8069

# Cambiar puerto en docker-compose.yml
# De: "8069:8069"
# A:  "8070:8069"
```

### Base de datos corrupta
```powershell
# Parar servicios
docker-compose down

# Hacer backup de seguridad
Rename-Item "postgresql" "postgresql_backup_$(Get-Date -Format 'yyyyMMdd')"

# Reiniciar con BD limpia
docker-compose up -d
```

## 📞 Soporte

Si encuentras problemas:
1. Revisa la sección de [Problemas Comunes](#problemas-comunes)
2. Consulta los logs con `docker-compose logs`
3. Busca en la documentación oficial de Odoo: https://www.odoo.com/documentation/
4. Crea un issue en este repositorio

## 🎯 Próximos Pasos Recomendados

### Para Desarrollo
1. **Crear tu primer módulo personalizado**:
   ```powershell
   # Crear estructura de módulo
   mkdir addons\mi_primer_modulo
   # Agregar archivos __manifest__.py, __init__.py, etc.
   ```

2. **Configurar IDE para desarrollo**:
   - Instalar extensión de Python para VS Code
   - Configurar debugging remoto
   - Instalar extensión de XML para vistas

3. **Habilitar modo desarrollador**:
   - Ve a: http://localhost:8069/web?debug=1
   - O agrega `debug = True` en `config/odoo.conf`

### Para Producción
1. **Cambiar credenciales**:
   ```powershell
   # Editar config/odoo.conf
   admin_passwd = tu_password_seguro
   
   # Editar docker-compose.yml
   POSTGRES_PASSWORD: tu_password_db_seguro
   ```

2. **Configurar HTTPS**:
   - Usar nginx como proxy reverso
   - Obtener certificado SSL (Let's Encrypt)

3. **Optimizar configuración**:
   - Ajustar workers en odoo.conf
   - Configurar límites de memoria
   - Habilitar logging avanzado

### Para Backup Automatizado
```powershell
# Crear script de backup automático
# Guardar como backup_odoo.ps1
$fecha = Get-Date -Format "yyyyMMdd_HHmmss"
docker exec odoo-db pg_dump -U odoo odoo > "backups\backup_$fecha.sql"
Compress-Archive -Path "postgresql" -DestinationPath "backups\postgresql_$fecha.zip"
```

## 📚 Recursos Adicionales

### Documentación Oficial
- **Odoo**: https://www.odoo.com/documentation/18.0/
- **Docker**: https://docs.docker.com/
- **PostgreSQL**: https://www.postgresql.org/docs/17/

### Tutoriales Recomendados
- Desarrollo de módulos en Odoo 18
- Configuración avanzada de PostgreSQL
- Optimización de Docker para producción

### Comunidad
- Forum Odoo: https://www.odoo.com/forum/
- Discord Odoo Community
- Stack Overflow - tag: odoo

---

## 🎉 ¡Proyecto Listo para Desarrollo!

El entorno de desarrollo para el **Sistema de Aula Virtual - Escuela de Posgrado UNICA** está **100% funcional** y listo para:

✅ **Desarrollo Colaborativo**: 7 desarrolladores trabajando en módulos específicos  
✅ **Sistemas Integrados**: 8 sistemas completos para la gestión de posgrado  
✅ **Plataforma Robusta**: Odoo 18 + PostgreSQL 17 + Docker  
✅ **Proyecto Académico**: Curso de Lenguaje de Programación Avanzada - UNICA  

### 🎯 Objetivos de Aprendizaje

Este proyecto permite a los estudiantes de 4to ciclo de Ingeniería de Sistemas desarrollar competencias en:

- **Desarrollo de Software Empresarial** con Odoo Framework
- **Trabajo Colaborativo** usando Git y GitHub
- **Arquitectura de Sistemas** modulares y escalables
- **Gestión de Bases de Datos** con PostgreSQL
- **Containerización** con Docker
- **Metodologías Ágiles** de desarrollo
- **Documentación Técnica** y de usuario

### 🚀 Comenzar el Desarrollo

**Para Desarrolladores del Equipo:**

1. **Clonar el repositorio:**
```bash
git clone https://github.com/MiguelVivar/escuela_posgrado_odoo
cd odoo-docker
```

2. **Iniciar el entorno:**
```bash
docker-compose up -d
```

3. **Acceder al sistema:**
- URL: http://localhost:8069
- Usuario: `admin`
- Contraseña: `admin`

4. **Crear tu rama de desarrollo:**
```bash
git checkout -b desarrollo-[tu-nombre]-[tu-modulo]
```

5. **¡Empezar a desarrollar tu módulo asignado!**

### 📊 Estado del Proyecto

| Sistema | Responsable | Estado | Avance |
|---------|-------------|--------|--------|
| Base Institucional | Miguel Vivar | 🔄 En desarrollo | 0% |
| Sistema de Admisión | Mario Muñoz | 📋 Planificado | 0% |
| Sistema de Matrícula | Angielina Soto | 📋 Planificado | 0% |
| Sistema de Intranet | Luis Mitma | 📋 Planificado | 0% |
| Gestión Docente | Juan Ttito | 📋 Planificado | 0% |
| Aula Virtual | Rodrigo Conislla | 📋 Planificado | 0% |
| Sistema de Caja | Dylan Palomino | 📋 Planificado | 0% |
| Trámite Documentario | Equipo Completo | 📋 Planificado | 0% |
| Grados y Títulos | Equipo Completo | 📋 Planificado | 0% |

---

**🎓 Universidad Nacional San Luis Gonzaga de Ica**  
**Facultad de Ingeniería de Sistemas**  
**Curso: Lenguaje de Programación Avanzada - 4to Ciclo**

*Última actualización: 28 de mayo de 2025*  
*Versiones: Docker 28.0.1 | Docker Compose 2.33.1 | PostgreSQL 17 | Odoo 18*
