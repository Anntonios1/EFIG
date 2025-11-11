#!/bin/bash

# Script de despliegue para API EFIG en Google Cloud con Docker

echo "🚀 Desplegando API EFIG en Google Cloud..."
echo ""

# 1. Copiar archivos al servidor
echo "📦 1. Copiando archivos al servidor..."
gcloud compute scp --recurse ../api-server openwebui-server:/home/teamp/ --zone=us-central1-a --project=open-webui-472400

# 2. Construir imagen Docker
echo ""
echo "🐳 2. Construyendo imagen Docker..."
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="cd /home/teamp/api-server && docker build -t efig-api:latest ."

# 3. Detener contenedor anterior si existe
echo ""
echo "🛑 3. Deteniendo contenedor anterior..."
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker stop efig-api 2>/dev/null || true && docker rm efig-api 2>/dev/null || true"

# 4. Iniciar nuevo contenedor
echo ""
echo "▶️  4. Iniciando contenedor..."
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker run -d --name efig-api --restart unless-stopped -p 3000:3000 efig-api:latest"

# 5. Crear regla de firewall si no existe
echo ""
echo "🔥 5. Configurando firewall..."
gcloud compute firewall-rules create allow-efig-api --direction=INGRESS --action=ALLOW --rules=tcp:3000 --source-ranges=0.0.0.0/0 --project=open-webui-472400 2>/dev/null || echo "   Firewall rule already exists"

# 6. Verificar estado
echo ""
echo "✅ 6. Verificando estado..."
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker ps | grep efig-api"

echo ""
echo "🎉 ¡Despliegue completado!"
echo ""
echo "📊 URL de la API: http://34.66.86.207:3000"
echo "🏥 Health check: http://34.66.86.207:3000/health"
echo "🤖 Modelos: http://34.66.86.207:3000/models"
echo ""
echo "📋 Para ver logs:"
echo "   gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command='docker logs -f efig-api'"
