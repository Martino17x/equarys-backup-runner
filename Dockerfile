FROM alpine:latest

# Instalar dependencias necesarias (postgresql-client para pg_dump)
RUN apk add --no-cache postgresql-client

# Crear directorio para backups
RUN mkdir -p /backups

# Copiar script de backup
COPY backup.sh /app/backup.sh

# Dar permisos de ejecución
RUN chmod +x /app/backup.sh

WORKDIR /app

CMD ["/app/backup.sh"]
