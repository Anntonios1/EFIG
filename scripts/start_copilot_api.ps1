# Script de inicio rápido del Copilot API Server

Write-Host "`n=== COPILOT API SERVER - INICIO ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar token
$token = $env:GITHUB_COPILOT_TOKEN
if (-not $token) {
    Write-Host "❌ GITHUB_COPILOT_TOKEN no configurado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Configúralo así:" -ForegroundColor Yellow
    Write-Host '  $env:GITHUB_COPILOT_TOKEN = "ghu_tu_token_aqui"' -ForegroundColor White
    Write-Host ""
    Write-Host "O agrega al archivo .env:" -ForegroundColor Yellow
    Write-Host "  GITHUB_COPILOT_TOKEN=ghu_tu_token_aqui" -ForegroundColor White
    Write-Host ""
    exit 1
}

if (-not $token.StartsWith("ghu_")) {
    Write-Host "❌ Token inválido (debe empezar con ghu_)" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Token configurado" -ForegroundColor Green
Write-Host ""

# 2. Construir imagen
Write-Host "Construyendo imagen Docker..." -ForegroundColor Yellow
docker-compose build copilot-api

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo imagen" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Imagen construida" -ForegroundColor Green
Write-Host ""

# 3. Iniciar servicio
Write-Host "Iniciando Copilot API Server..." -ForegroundColor Yellow
docker-compose up -d copilot-api

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error iniciando servidor" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Servidor iniciado" -ForegroundColor Green
Write-Host ""

# 4. Esperar a que esté listo
Write-Host "Esperando que el servidor esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 5. Verificar salud
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8000/health" -Method Get
    Write-Host "✓ Servidor saludable" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Servidor iniciado pero no responde aún" -ForegroundColor Yellow
    Write-Host "   Verifica logs: docker logs copilot_api_server" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== SERVIDOR LISTO ===" -ForegroundColor Green
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  API: http://localhost:8000" -ForegroundColor White
Write-Host "  Health: http://localhost:8000/health" -ForegroundColor White
Write-Host "  Models: http://localhost:8000/v1/models" -ForegroundColor White
Write-Host ""

Write-Host "Endpoints compatibles con OpenAI:" -ForegroundColor Cyan
Write-Host "  GET  /v1/models" -ForegroundColor White
Write-Host "  POST /v1/chat/completions" -ForegroundColor White
Write-Host ""

Write-Host "Prueba rápida:" -ForegroundColor Yellow
Write-Host ""
Write-Host '$body = @{' -ForegroundColor Gray
Write-Host '    model = "gpt-4o"' -ForegroundColor Gray
Write-Host '    messages = @(@{ role = "user"; content = "Hola" })' -ForegroundColor Gray
Write-Host '} | ConvertTo-Json' -ForegroundColor Gray
Write-Host ""
Write-Host 'Invoke-RestMethod -Uri "http://localhost:8000/v1/chat/completions" -Method Post -Body $body -ContentType "application/json"' -ForegroundColor Gray
Write-Host ""

Write-Host "Ver logs:" -ForegroundColor Yellow
Write-Host "  docker logs -f copilot_api_server" -ForegroundColor White
Write-Host ""

Write-Host "Detener:" -ForegroundColor Yellow
Write-Host "  docker-compose stop copilot-api" -ForegroundColor White
Write-Host ""
