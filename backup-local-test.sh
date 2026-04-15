#!/bin/sh

# Configuración para prueba local
BACKUP_DIR="./test-backups"
SCHEMA_DIR="$BACKUP_DIR/schema"
DATA_DIR="$BACKUP_DIR/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30
SUPABASE_PROJECT_REF="dzzyhscbuatnikcfybdl"
SUPABASE_ACCESS_TOKEN="${SUPABASE_ACCESS_TOKEN:-}"

# Verificar credenciales
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "ERROR: SUPABASE_ACCESS_TOKEN no está configurado"
    echo "Seteá: set SUPABASE_ACCESS_TOKEN=<tu_service_role_key>"
    exit 1
fi

# Crear carpetas
mkdir -p "$SCHEMA_DIR"
mkdir -p "$DATA_DIR"

# Backup de schema
SCHEMA_FILE="$SCHEMA_DIR/equarys_schema_${TIMESTAMP}.sql"
supabase db dump --project-ref "$SUPABASE_PROJECT_REF" --schema-only --file "$SCHEMA_FILE"

if [ -f "$SCHEMA_FILE" ]; then
    echo "Backup de schema completado: $SCHEMA_FILE"
    gzip "$SCHEMA_FILE"
    echo "Schema comprimido: ${SCHEMA_FILE}.gz"
else
    echo "ERROR: El backup de schema no se creó"
    exit 1
fi

# Backup de datos
DATA_FILE="$DATA_DIR/equarys_data_${TIMESTAMP}.sql"
supabase db dump --project-ref "$SUPABASE_PROJECT_REF" --data-only --file "$DATA_FILE"

if [ -f "$DATA_FILE" ]; then
    echo "Backup de datos completado: $DATA_FILE"
    gzip "$DATA_FILE"
    echo "Datos comprimidos: ${DATA_FILE}.gz"
else
    echo "ERROR: El backup de datos no se creó"
    exit 1
fi

echo "=== Backup completo ==="
echo "Schema: ${SCHEMA_FILE}.gz"
echo "Datos: ${DATA_FILE}.gz"
echo "Fecha: $(date)"
