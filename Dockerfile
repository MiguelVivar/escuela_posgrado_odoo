FROM odoo:18

# Instalar postgresql-client para pg_isready
USER root
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Copiar archivos de configuración y addons
COPY ./config/odoo-railway.conf /etc/odoo/
COPY ./addons /mnt/extra-addons/
COPY ./start.sh /usr/local/bin/start.sh

# Hacer el script ejecutable
RUN chmod +x /usr/local/bin/start.sh

# Crear directorio para logs
RUN mkdir -p /var/log/odoo && chown odoo:odoo /var/log/odoo

# Usuario para Odoo
USER odoo

# Exponer puerto
EXPOSE 8069

# Comando por defecto
CMD ["/usr/local/bin/start.sh"]
