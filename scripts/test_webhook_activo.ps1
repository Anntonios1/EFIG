# Prueba del webhook activo

Write-Host "`n=== PRUEBA DE WEBHOOK ACTIVO ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "El workflow esta ACTIVO (toggle verde) ✓" -ForegroundColor Green
Write-Host "Ahora probemos el webhook..." -ForegroundColor White
Write-Host ""

# Prueba 1: Verificar que ngrok está corriendo
Write-Host "1. Verificando ngrok..." -ForegroundColor Yellow
$ngrokStatus = docker ps --filter "name=n8n_ngrok" --format "{{.Status}}"
if ($ngrokStatus) {
    Write-Host "   ✓ ngrok esta corriendo" -ForegroundColor Green
} else {
    Write-Host "   ✗ ngrok NO esta corriendo" -ForegroundColor Red
    Write-Host "   Ejecuta: docker-compose up -d ngrok" -ForegroundColor Yellow
}
Write-Host ""

# Prueba 2: Obtener URL de ngrok
Write-Host "2. Obteniendo URL de ngrok..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = $response.tunnels[0].public_url
    Write-Host "   ✓ URL publica: $publicUrl" -ForegroundColor Green
    $publicUrl | Out-File "ngrok_url.txt" -Encoding utf8
} catch {
    Write-Host "   ✗ No se pudo obtener URL (¿ngrok corriendo?)" -ForegroundColor Red
    $publicUrl = "https://e149bd15a769.ngrok-free.app"
    Write-Host "   Usando URL anterior: $publicUrl" -ForegroundColor Yellow
}
Write-Host ""

# Prueba 3: Test del webhook con POST
Write-Host "3. Probando webhook con POST..." -ForegroundColor Yellow
Write-Host "   URL: $publicUrl/webhook/agente" -ForegroundColor White
Write-Host ""

$testBody = @{
    mensaje = "Lista todos los clientes"
} | ConvertTo-Json

Write-Host "   Enviando peticion..." -ForegroundColor Gray
try {
    $result = Invoke-RestMethod -Uri "$publicUrl/webhook/agente" -Method Post -Body $testBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "   ✓ EXITO! Respuesta recibida:" -ForegroundColor Green
    Write-Host ""
    $result | ConvertTo-Json -Depth 5
} catch {
    Write-Host "   ✗ ERROR:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Message -match "404") {
        Write-Host "   POSIBLES CAUSAS:" -ForegroundColor Yellow
        Write-Host "   - El path del webhook no es 'agente'" -ForegroundColor White
        Write-Host "   - El workflow se desactivo" -ForegroundColor White
        Write-Host "   - n8n se reinicio y perdio la configuracion" -ForegroundColor White
        Write-Host ""
        Write-Host "   SOLUCION:" -ForegroundColor Cyan
        Write-Host "   1. Ve al workflow: http://localhost:5678/workflow/qekUMhBirvSbpIqX" -ForegroundColor White
        Write-Host "   2. Haz clic en el nodo Webhook (primer nodo)" -ForegroundColor White
        Write-Host "   3. Verifica que 'Path' sea: agente" -ForegroundColor White
        Write-Host "   4. Copia la 'Production URL' que aparece" -ForegroundColor White
    } elseif ($_.Exception.Message -match "401") {
        Write-Host "   Problema de autenticacion con el LLM" -ForegroundColor Yellow
    } elseif ($_.Exception.Message -match "500") {
        Write-Host "   Error interno en el workflow" -ForegroundColor Yellow
        Write-Host "   Revisa las credenciales de Postgres y LLM" -ForegroundColor White
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "COMANDO PARA COPIAR Y PEGAR:" -ForegroundColor Yellow
Write-Host ""
Write-Host '$body = @{ mensaje = "Lista todos los clientes" } | ConvertTo-Json' -ForegroundColor White
Write-Host "Invoke-RestMethod -Uri `"$publicUrl/webhook/agente`" -Method Post -Body `$body -ContentType `"application/json`"" -ForegroundColor White
Write-Host ""
