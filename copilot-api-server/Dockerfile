# Dockerfile para GitHub Copilot API Server

FROM python:3.11-slim

WORKDIR /app

# Copiar archivos
COPY requirements.txt .
COPY server_simple.py server.py

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["python", "server.py"]
