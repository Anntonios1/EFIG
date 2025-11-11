# Script de despliegue para API EFIG en Google Cloud con Docker (PowerShell)

Write-Host "🚀 Desplegando API EFIG en Google Cloud..." -ForegroundColor Cyan
Write-Host ""

# 1. Copiar archivos al servidor
Write-Host "📦 1. Copiando archivos al servidor..." -ForegroundColor Yellow
gcloud compute scp --recurse "C:\Users\teamp\Documents\N8N FINAL\api-server" openwebui-server:/home/teamp/ --zone=us-central1-a --project=open-webui-472400

# 2. Construir imagen Docker
Write-Host ""
Write-Host "🐳 2. Construyendo imagen Docker..." -ForegroundColor Yellow
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="cd /home/teamp/api-server; docker build -t efig-api:latest ."

# 3. Detener contenedor anterior si existe
Write-Host ""
Write-Host "🛑 3. Deteniendo contenedor anterior..." -ForegroundColor Yellow
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker stop efig-api 2>/dev/null; docker rm efig-api 2>/dev/null; exit 0"

# 4. Iniciar nuevo contenedor
Write-Host ""
Write-Host "▶️  4. Iniciando contenedor..." -ForegroundColor Yellow
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker run -d --name efig-api --restart unless-stopped -p 3000:3000 efig-api:latest"

# 5. Crear regla de firewall si no existe
Write-Host ""
Write-Host "🔥 5. Configurando firewall..." -ForegroundColor Yellow
gcloud compute firewall-rules create allow-efig-api --direction=INGRESS --action=ALLOW --rules=tcp:3000 --source-ranges=0.0.0.0/0 --project=open-webui-472400 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Firewall rule already exists" -ForegroundColor Gray
}

# 6. Verificar estado
Write-Host ""
Write-Host "✅ 6. Verificando estado..." -ForegroundColor Yellow
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker ps | grep efig-api"

Write-Host ""
Write-Host "🎉 ¡Despliegue completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 URL de la API: http://34.66.86.207:3000" -ForegroundColor Cyan
Write-Host "🏥 Health check: http://34.66.86.207:3000/health" -ForegroundColor Cyan
Write-Host "🤖 Modelos: http://34.66.86.207:3000/models" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Para ver logs:" -ForegroundColor Yellow
Write-Host "   gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command=`"docker logs -f efig-api`"" -ForegroundColor Gray
