#!/bin/bash

# Configurar locale
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Configurar variables de conexión con valores por defecto
PGHOST="${PGHOST:-postgres}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-postgres}"
PGDATABASE="${PGDATABASE:-odoo_db}"

echo "Esperando a que PostgreSQL esté disponible en $PGHOST:$PGPORT..."
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
  sleep 2
done

echo "Verificando si la base de datos $PGDATABASE existe y está inicializada..."
DB_EXISTS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -lqt | cut -d \| -f 1 | grep -w "$PGDATABASE")

if [ -z "$DB_EXISTS" ]; then
  echo "La base de datos $PGDATABASE no existe, creándola..."
  createdb -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$PGDATABASE"
  
  echo "Inicializando la base de datos con módulo base..."
  python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$PGDATABASE" -i base --stop-after-init --without-demo=all
elif ! psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT 1 FROM ir_module_module WHERE name='base'" &> /dev/null; then
  echo "La base de datos existe pero no está inicializada, instalando módulo base..."
  python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$PGDATABASE" -i base --stop-after-init --without-demo=all
fi

echo "Iniciando Odoo normalmente..."
exec python3 /usr/bin/odoo -c /etc/odoo/odoo.conf -d "$PGDATABASE"