FROM alpine:latest

# Instalar dependencias necesarias
RUN apk add --no-cache curl

# Instalar Supabase CLI (binario directo desde GitHub)
RUN curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz -o supabase.tar.gz && \
    tar -xzf supabase.tar.gz && \
    mv supabase /usr/local/bin/ && \
    rm supabase.tar.gz

# Crear directorio para backups
RUN mkdir -p /backups

# Copiar script de backup
COPY backup.sh /app/backup.sh

# Dar permisos de ejecución
RUN chmod +x /app/backup.sh

WORKDIR /app

CMD ["/app/backup.sh"]
