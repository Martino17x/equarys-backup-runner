FROM alpine:latest

# Instalar dependencias necesarias
RUN apk add --no-cache curl

# Instalar Supabase CLI (binario oficial)
RUN curl -fsSL https://supabase.com/install.sh | sh

# Agregar supabase al PATH
ENV PATH="/root/.local/bin:${PATH}"

# Crear directorio para backups
RUN mkdir -p /backups

# Copiar script de backup
COPY backup.sh /app/backup.sh

# Dar permisos de ejecución
RUN chmod +x /app/backup.sh

WORKDIR /app

CMD ["/app/backup.sh"]
