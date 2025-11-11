# Deploy EFIG API to Google Cloud with Docker

Write-Host "Desplegando API EFIG en Google Cloud..." -ForegroundColor Cyan

# Step 1: Copy files
Write-Host "1. Copiando archivos..." -ForegroundColor Yellow
gcloud compute scp --recurse "C:\Users\teamp\Documents\N8N FINAL\api-server" openwebui-server:/home/teamp/ --zone=us-central1-a --project=open-webui-472400

# Step 2: Build Docker image
Write-Host "2. Construyendo imagen Docker..." -ForegroundColor Yellow  
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="cd /home/teamp/api-server; docker build -t efig-api:latest ."

# Step 3: Stop old container
Write-Host "3. Deteniendo contenedor anterior..." -ForegroundColor Yellow
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker stop efig-api 2>/dev/null; docker rm efig-api 2>/dev/null; exit 0"

# Step 4: Start new container
Write-Host "4. Iniciando contenedor..." -ForegroundColor Yellow
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker run -d --name efig-api --restart unless-stopped -p 3000:3000 efig-api:latest"

# Step 5: Configure firewall
Write-Host "5. Configurando firewall..." -ForegroundColor Yellow
$null = gcloud compute firewall-rules create allow-efig-api --direction=INGRESS --action=ALLOW --rules=tcp:3000 --source-ranges=0.0.0.0/0 --project=open-webui-472400 2>&1

# Step 6: Check status
Write-Host "6. Verificando estado..." -ForegroundColor Yellow
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400 --command="docker ps | grep efig-api"

Write-Host ""
Write-Host "Despliegue completado!" -ForegroundColor Green
Write-Host "API URL: http://34.66.86.207:3000" -ForegroundColor Cyan
Write-Host "Health: http://34.66.86.207:3000/health" -ForegroundColor Cyan
Write-Host "Models: http://34.66.86.207:3000/models" -ForegroundColor Cyan
