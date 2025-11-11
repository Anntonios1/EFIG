# Script para levantar ngrok y obtener la URL pública

Write-Host "=== Levantando ngrok con Docker ===" -ForegroundColor Cyan
Write-Host ""

# Levantar ngrok
Write-Host "1. Iniciando contenedor ngrok..." -ForegroundColor Yellow
docker-compose up -d ngrok

Write-Host ""
Write-Host "2. Esperando 5 segundos para que ngrok se conecte..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Obtener la URL pública desde el API de ngrok
Write-Host ""
Write-Host "3. Obteniendo URL publica..." -ForegroundColor Yellow

try {
    $ngrokApi = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = $ngrokApi.tunnels[0].public_url
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  NGROK ACTIVO" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URL Publica de n8n:" -ForegroundColor Yellow
    Write-Host "  $publicUrl" -ForegroundColor White
    Write-Host ""
    Write-Host "Webhooks:" -ForegroundColor Yellow
    Write-Host "  $publicUrl/webhook/agente" -ForegroundColor White
    Write-Host "  $publicUrl/webhook/nuevo-cliente" -ForegroundColor White
    Write-Host "  $publicUrl/webhook/nueva-reserva" -ForegroundColor White
    Write-Host ""
    Write-Host "Dashboard de ngrok:" -ForegroundColor Yellow
    Write-Host "  http://localhost:4040" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # Guardar URL en un archivo para referencia
    $publicUrl | Out-File -FilePath "ngrok_url.txt" -Encoding UTF8
    Write-Host "URL guardada en: ngrok_url.txt" -ForegroundColor Gray
    Write-Host ""
    
    # Ejemplo de uso
    Write-Host "Ejemplo de uso desde PowerShell:" -ForegroundColor Yellow
    Write-Host '$body = @{ mensaje = "Prueba desde ngrok" } | ConvertTo-Json' -ForegroundColor Gray
    Write-Host "Invoke-RestMethod -Uri `"$publicUrl/webhook/agente`" -Method Post -Body `$body -ContentType `"application/json`"" -ForegroundColor Gray
    Write-Host ""
    
    # Abrir dashboard en el navegador
    Write-Host "Abriendo dashboard de ngrok en el navegador..." -ForegroundColor Yellow
    Start-Process "http://localhost:4040"
    
} catch {
    Write-Host ""
    Write-Host "ERROR: No se pudo obtener la URL de ngrok" -ForegroundColor Red
    Write-Host "Detalles: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Posibles causas:" -ForegroundColor Yellow
    Write-Host "  1. n8n no esta corriendo en localhost:5678" -ForegroundColor Gray
    Write-Host "  2. ngrok tarda en conectarse (espera 10 seg y vuelve a ejecutar este script)" -ForegroundColor Gray
    Write-Host "  3. Limite de conexiones gratuitas de ngrok alcanzado" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Dashboard manual: http://localhost:4040" -ForegroundColor White
    Write-Host ""
}

Write-Host "Para detener ngrok:" -ForegroundColor Yellow
Write-Host "  docker-compose stop ngrok" -ForegroundColor Gray
Write-Host ""
