#!/bin/bash

# Esperar a que la base de datos esté disponible
until pg_isready -h ${PGHOST} -p ${PGPORT} -U ${PGUSER}; do
  echo "Esperando a que PostgreSQL esté disponible..."
  sleep 2
done

echo "PostgreSQL está disponible, iniciando Odoo..."

# Inicializar la base de datos si es necesario
if [ "$INITIALIZE_DB" = "true" ]; then
    echo "Inicializando base de datos..."
    python3 /usr/bin/odoo -c /etc/odoo/odoo-railway.conf -d ${PGDATABASE} -i base --stop-after-init --without-demo=all
fi

# Iniciar Odoo
exec python3 /usr/bin/odoo -c /etc/odoo/odoo-railway.conf
