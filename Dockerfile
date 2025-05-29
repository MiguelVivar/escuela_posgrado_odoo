FROM odoo:18

# Instalar postgresql-client para pg_isready
USER root
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Crear directorio para addons primero
RUN mkdir -p /mnt/extra-addons

# Copiar archivos de configuración
COPY ./config/odoo-railway.conf /etc/odoo/
COPY ./start.sh /usr/local/bin/start.sh

# Copiar addons solo si el directorio existe y no está vacío
COPY ./addons/ /mnt/extra-addons/

# Hacer el script ejecutable
RUN chmod +x /usr/local/bin/start.sh

# Crear directorio para logs
RUN mkdir -p /var/log/odoo && chown odoo:odoo /var/log/odoo

# Asegurar permisos correctos para addons
RUN chown -R odoo:odoo /mnt/extra-addons

# Usuario para Odoo
USER odoo

# Exponer puerto
EXPOSE 8069

# Comando por defecto
CMD ["/usr/local/bin/start.sh"]
