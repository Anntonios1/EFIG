# Node.js 20 Alpine (imagen ligera)
FROM node:20-alpine

# Crear directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm install --production

# Copiar código fuente
COPY server.js ./

# Exponer puerto
EXPOSE 3000

# Variables de entorno opcionales
ENV PORT=3000
ENV NODE_ENV=production

# Comando para iniciar
CMD ["node", "server.js"]
