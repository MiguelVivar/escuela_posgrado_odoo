FROM odoo:18

# Configurar locale
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

# Instalar dependencias necesarias
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-client \
        postgresql-client-common \
        locales && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen C.UTF-8 && \
    dpkg-reconfigure --frontend=noninteractive locales

# Instalar wkhtmltopdf por separado con dependencias explícitas
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfonts-75dpi \
        xfonts-base \
        fontconfig \
        libjpeg62-turbo \
        libx11-6 \
        libxext6 \
        libxrender1 \
        xfonts-utils && \
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb -O /tmp/wkhtmltox.deb && \
    dpkg -i /tmp/wkhtmltox.deb || apt-get install -yf && \
    rm -rf /var/lib/apt/lists/* /tmp/wkhtmltox.deb

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