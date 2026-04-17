#!/bin/sh

# Configuración
BACKUP_DIR="/backups"
LOCK_FILE="/tmp/backup.lock"
BACKUP_DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H%M%S)
DAY_DIR="$BACKUP_DIR/$BACKUP_DATE"
SCHEMA_DIR="$DAY_DIR/schema"
DATA_DIR="$DAY_DIR/data"
RETENTION_DAYS=30
SUPABASE_DB_URL="${SUPABASE_DB_URL:-}"

# Verificar URL de conexión de base de datos
if [ -z "$SUPABASE_DB_URL" ]; then
    echo "ERROR: SUPABASE_DB_URL no está configurado"
    exit 1
fi

# Evitar ejecuciones simultáneas
if [ -f "$LOCK_FILE" ]; then
    echo "Backup en curso. Se omite esta ejecución."
    exit 0
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Crear carpetas
mkdir -p "$SCHEMA_DIR"
mkdir -p "$DATA_DIR"

# Backup de schema
SCHEMA_FILE="$SCHEMA_DIR/equarys_schema_${TIMESTAMP}.sql"
pg_dump "$SUPABASE_DB_URL" --schema-only --file "$SCHEMA_FILE"

if [ -f "$SCHEMA_FILE" ]; then
    echo "Backup de schema completado: $SCHEMA_FILE"
    gzip "$SCHEMA_FILE"
else
    echo "ERROR: El backup de schema no se creó"
    exit 1
fi

# Backup de datos
DATA_FILE="$DATA_DIR/equarys_data_${TIMESTAMP}.sql"
pg_dump "$SUPABASE_DB_URL" --data-only --file "$DATA_FILE"

if [ -f "$DATA_FILE" ]; then
    echo "Backup de datos completado: $DATA_FILE"
    gzip "$DATA_FILE"
else
    echo "ERROR: El backup de datos no se creó"
    exit 1
fi

# Limpieza por carpetas diarias (más de RETENTION_DAYS)
find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +
echo "Backups diarios antiguos eliminados (más de $RETENTION_DAYS días)"

echo "=== Backup completo ==="
echo "Schema: ${SCHEMA_FILE}.gz"
echo "Datos: ${DATA_FILE}.gz"
echo "Fecha: $(date)"
