# Directorio para módulos personalizados de Odoo

Este directorio está destinado a contener los módulos personalizados de Odoo para el sistema de aula virtual.

## Estructura sugerida:
```
addons/
├── escuela_admision/          # Sistema de Admisión
├── escuela_matricula/         # Sistema de Matrícula  
├── escuela_intranet/          # Sistema de Intranet
├── escuela_docente/           # Sistema de Gestión Docente
├── escuela_aula_virtual/      # Sistema de Aula Virtual
├── escuela_caja/              # Sistema de Caja
├── escuela_tramite/           # Sistema de Trámite Documentario
└── escuela_grados/            # Sistema de Grados y Títulos
```

## Desarrollo de módulos:
Para crear un nuevo módulo, puedes usar el comando scaffold de Odoo o crear la estructura manualmente.

Ejemplo para crear un módulo:
```bash
docker exec -it odoo-web odoo scaffold escuela_admision /mnt/extra-addons/
```
