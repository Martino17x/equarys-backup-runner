#!/bin/sh

# Configuración
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/equarys_${TIMESTAMP}.sql"
RETENTION_DAYS=30
SUPABASE_PROJECT_REF="dzzyhscbuatnikcfybdl"
SUPABASE_ACCESS_TOKEN="${SUPABASE_ACCESS_TOKEN:-}"

# Verificar credenciales
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "ERROR: SUPABASE_ACCESS_TOKEN no está configurado"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

# Hacer backup
supabase db dump --project-ref "$SUPABASE_PROJECT_REF" --file "$BACKUP_FILE"

if [ -f "$BACKUP_FILE" ]; then
    echo "Backup completado: $BACKUP_FILE"
    gzip "$BACKUP_FILE"
    find "$BACKUP_DIR" -name "equarys_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
    echo "Backups antiguos eliminados (más de $RETENTION_DAYS días)"
else
    echo "ERROR: El backup no se creó"
    exit 1
fi
