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
RUN mkdir -p /mnt/extra-addons /mnt/custom-addons /var/log/odoo && \
    chown odoo:odoo /mnt/extra-addons /mnt/custom-addons /var/log/odoo

# Copiar archivos de configuración y scripts
COPY ./config/odoo.conf /etc/odoo/
COPY ./start.sh /usr/local/bin/start.sh
COPY ./start-alternative.sh /usr/local/bin/start-alternative.sh
COPY ./debug-connection.sh /usr/local/bin/debug-connection.sh
COPY ./create-odoo-user.sh /usr/local/bin/create-odoo-user.sh
COPY ./fix-permissions.sh /usr/local/bin/fix-permissions.sh
COPY ./install-custom-modules.sh /usr/local/bin/install-custom-modules.sh
COPY ./verify-custom-modules.sh /usr/local/bin/verify-custom-modules.sh
COPY ./check-modules-railway.sh /usr/local/bin/check-modules-railway.sh
COPY ./debug-modules-railway.sh /usr/local/bin/debug-modules-railway.sh
COPY ./debug-module-files.sh /usr/local/bin/debug-module-files.sh
COPY ./fix-modules-railway.sh /usr/local/bin/fix-modules-railway.sh
COPY ./fix-om-hr-payroll.sh /usr/local/bin/fix-om-hr-payroll.sh
COPY ./emergency-fix-om-hr-payroll.sh /usr/local/bin/emergency-fix-om-hr-payroll.sh
COPY ./smart-modules-installer.sh /usr/local/bin/smart-modules-installer.sh
COPY ./railway-test-modules.sh /usr/local/bin/railway-test-modules.sh
COPY ./modules-installer-function.sh /usr/local/bin/modules-installer-function.sh
COPY ./test-modules-fix.sh /usr/local/bin/test-modules-fix.sh

# Copiar módulos personalizados a un directorio dedicado
COPY ./addons/ /mnt/custom-addons/
RUN chown -R odoo:odoo /mnt/custom-addons

# Ajustar permisos
RUN chmod +x /usr/local/bin/start.sh && \
    chmod +x /usr/local/bin/start-alternative.sh && \
    chmod +x /usr/local/bin/debug-connection.sh && \
    chmod +x /usr/local/bin/create-odoo-user.sh && \
    chmod +x /usr/local/bin/fix-permissions.sh && \
    chmod +x /usr/local/bin/install-custom-modules.sh && \
    chmod +x /usr/local/bin/verify-custom-modules.sh && \    chmod +x /usr/local/bin/check-modules-railway.sh && \    chmod +x /usr/local/bin/debug-module-files.sh && \    chmod +x /usr/local/bin/fix-modules-railway.sh && \    chmod +x /usr/local/bin/fix-om-hr-payroll.sh && \
    chmod +x /usr/local/bin/emergency-fix-om-hr-payroll.sh && \
    chown -R odoo:odoo /mnt/extra-addons /mnt/custom-addons && \
    chown odoo:odoo /etc/odoo/odoo.conf

RUN apt-get update && apt-get install -y ca-certificates libssl-dev

# Usuario para Odoo
USER odoo

# Exponer puerto
EXPOSE 8069

# Comando por defecto
CMD ["/usr/local/bin/start.sh"]