#!/bin/sh

# Configuración
BACKUP_DIR="/backups"
SCHEMA_DIR="$BACKUP_DIR/schema"
DATA_DIR="$BACKUP_DIR/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30
SUPABASE_DB_URL="${SUPABASE_DB_URL:-}"

# Verificar URL de conexión de base de datos
if [ -z "$SUPABASE_DB_URL" ]; then
    echo "ERROR: SUPABASE_DB_URL no está configurado"
    exit 1
fi

# Crear carpetas
mkdir -p "$SCHEMA_DIR"
mkdir -p "$DATA_DIR"

# Backup de schema
SCHEMA_FILE="$SCHEMA_DIR/equarys_schema_${TIMESTAMP}.sql"
pg_dump "$SUPABASE_DB_URL" --schema-only --file "$SCHEMA_FILE"

if [ -f "$SCHEMA_FILE" ]; then
    echo "Backup de schema completado: $SCHEMA_FILE"
    gzip "$SCHEMA_FILE"
    find "$SCHEMA_DIR" -name "equarys_schema_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
    echo "Backups de schema antiguos eliminados (más de $RETENTION_DAYS días)"
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
    find "$DATA_DIR" -name "equarys_data_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
    echo "Backups de datos antiguos eliminados (más de $RETENTION_DAYS días)"
else
    echo "ERROR: El backup de datos no se creó"
    exit 1
fi

echo "=== Backup completo ==="
echo "Schema: ${SCHEMA_FILE}.gz"
echo "Datos: ${DATA_FILE}.gz"
echo "Fecha: $(date)"
