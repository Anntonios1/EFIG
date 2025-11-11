#!/bin/bash

# Script para preparar la VM y desplegar PostgreSQL + Copilot API

echo "=== Verificando Docker ==="
if ! command -v docker &> /dev/null; then
    echo "Docker no está instalado. Instalando..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker instalado. Necesitas reconectar SSH para aplicar cambios."
else
    echo "Docker ya está instalado: $(docker --version)"
fi

echo ""
echo "=== Verificando Docker Compose ==="
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose no está instalado. Instalando..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose instalado: $(docker-compose --version)"
else
    echo "Docker Compose ya está instalado: $(docker-compose --version)"
fi

echo ""
echo "=== Creando directorio de trabajo ==="
mkdir -p ~/n8n-backend
cd ~/n8n-backend

echo ""
echo "✅ Preparación completa"
echo "Ahora necesitas subir los archivos desde tu PC:"
echo "1. docker-compose.cloud.yml"
echo "2. init.sql"
echo "3. copilot-api-server/ (carpeta completa)"
