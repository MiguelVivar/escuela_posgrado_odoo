FROM odoo:18

# Configurar locale
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

# Instalar dependencias necesarias
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-client \
        postgresql-client-common \
        locales \
        wkhtmltopdf && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen C.UTF-8 && \
    dpkg-reconfigure --frontend=noninteractive locales

# Configurar directorios
RUN mkdir -p /mnt/extra-addons /var/log/odoo && \
    chown odoo:odoo /mnt/extra-addons /var/log/odoo

# Copiar archivos
COPY ./config/odoo.conf /etc/odoo/
COPY ./start.sh /usr/local/bin/start.sh
COPY ./addons/ /mnt/extra-addons/

# Ajustar permisos
RUN chmod +x /usr/local/bin/start.sh && \
    chown -R odoo:odoo /mnt/extra-addons

# Usuario para Odoo
USER odoo

# Exponer puerto
EXPOSE 8069

# Comando por defecto
CMD ["/usr/local/bin/start.sh"]