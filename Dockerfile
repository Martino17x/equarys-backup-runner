FROM node:18-alpine

# Instalar Supabase CLI (método oficial)
RUN npm install supabase@latest

# Crear directorio para backups
RUN mkdir -p /backups

# Copiar script de backup
COPY backup.sh /app/backup.sh

# Dar permisos de ejecución
RUN chmod +x /app/backup.sh

WORKDIR /app

CMD ["/app/backup.sh"]
