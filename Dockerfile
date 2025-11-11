FROM n8nio/n8n:latest

# Instalar dependencias adicionales si es necesario
USER root
RUN apk add --no-cache postgresql-client curl

# Cambiar de vuelta al usuario n8n
USER node

# Variables de entorno para producción
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV N8N_LOG_LEVEL=info
ENV N8N_LOG_OUTPUT=console

# Configuración de timezone
ENV TZ=America/Bogota

# Configuración de base de datos PostgreSQL
ENV DB_TYPE=postgresdb
ENV DB_POSTGRESDB_SSL_ENABLED=true
ENV DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false

# Configuración de seguridad
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_SECURE_COOKIE=true

# Configuración de webhook y editor
ENV WEBHOOK_URL=https://efig.onrender.com
ENV N8N_EDITOR_BASE_URL=https://efig.onrender.com

# Directorio de trabajo
WORKDIR /home/node/.n8n

# Crear directorios necesarios
RUN mkdir -p /home/node/.n8n/nodes

# Exponer puerto
EXPOSE 5678

# Healthcheck mejorado
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Comando de inicio con PATH explícito
CMD ["/usr/local/bin/n8n", "start"]