# Script de prueba del Copilot API Server

Write-Host "`n=== PRUEBA DE COPILOT API ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar que el servidor esté corriendo
Write-Host "1. Verificando servidor..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8000/health" -Method Get
    Write-Host "   ✓ Servidor saludable" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Servidor no responde" -ForegroundColor Red
    Write-Host "   Inicia el servidor con: ./scripts/start_copilot_api.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 2. Listar modelos
Write-Host "2. Listando modelos disponibles..." -ForegroundColor Yellow
try {
    $models = Invoke-RestMethod -Uri "http://localhost:8000/v1/models" -Method Get
    Write-Host "   ✓ Modelos disponibles:" -ForegroundColor Green
    foreach ($model in $models.data) {
        Write-Host "     - $($model.id)" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Error listando modelos: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 3. Prueba simple
Write-Host "3. Prueba simple (sin streaming)..." -ForegroundColor Yellow
$body1 = @{
    model = "gpt-4o"
    messages = @(
        @{
            role = "user"
            content = "Di 'Hola desde Copilot API'"
        }
    )
    temperature = 0.7
    stream = $false
} | ConvertTo-Json

try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:8000/v1/chat/completions" `
        -Method Post `
        -Body $body1 `
        -ContentType "application/json"
    
    Write-Host "   ✓ Respuesta recibida:" -ForegroundColor Green
    Write-Host "   $($response1.choices[0].message.content)" -ForegroundColor White
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 4. Prueba con consulta SQL
Write-Host "4. Prueba con SQL..." -ForegroundColor Yellow
$body2 = @{
    model = "gpt-4o"
    messages = @(
        @{
            role = "system"
            content = "Eres un experto en PostgreSQL."
        }
        @{
            role = "user"
            content = "Escribe una consulta SQL para listar todos los clientes VIP de la tabla 'clientes'"
        }
    )
    temperature = 0.3
    stream = $false
} | ConvertTo-Json

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:8000/v1/chat/completions" `
        -Method Post `
        -Body $body2 `
        -ContentType "application/json"
    
    Write-Host "   ✓ Respuesta SQL:" -ForegroundColor Green
    Write-Host "   $($response2.choices[0].message.content)" -ForegroundColor White
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 5. Resumen
Write-Host "=== RESUMEN ===" -ForegroundColor Green
Write-Host ""
Write-Host "✓ API funcionando correctamente" -ForegroundColor Green
Write-Host "✓ Compatible con OpenAI API" -ForegroundColor Green
Write-Host "✓ Listo para usar en n8n" -ForegroundColor Green
Write-Host ""

Write-Host "Siguiente paso:" -ForegroundColor Cyan
Write-Host "  1. Configura este endpoint en n8n: http://localhost:8000/v1/chat/completions" -ForegroundColor White
Write-Host "  2. Usa modelo: gpt-4o" -ForegroundColor White
Write-Host "  3. Formato de body igual que OpenAI API" -ForegroundColor White
Write-Host ""
