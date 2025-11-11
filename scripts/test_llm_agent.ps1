# Script de prueba del LLM Agent Orchestrator

Write-Host "=== Pruebas del LLM Agent Orchestrator ===" -ForegroundColor Cyan
Write-Host ""

$webhookUrl = "http://localhost:5678/webhook/agente"

# Función helper para hacer requests
function Test-LLMAgent {
    param(
        [string]$Mensaje,
        [string]$Descripcion
    )
    
    Write-Host "Test: $Descripcion" -ForegroundColor Yellow
    Write-Host "Mensaje: '$Mensaje'" -ForegroundColor Gray
    
    try {
        $body = @{ mensaje = $Mensaje } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        
        Write-Host "Respuesta:" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 5 | Write-Host
        Write-Host ""
        
        return $response
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        return $null
    }
}

# Verificar que el webhook está disponible
Write-Host "Verificando que el webhook está activo..." -ForegroundColor Yellow
try {
    $testBody = @{ mensaje = "ping" } | ConvertTo-Json
    $null = Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $testBody -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "OK - Webhook activo" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR - El webhook no está disponible" -ForegroundColor Red
    Write-Host "Asegurate de:" -ForegroundColor Yellow
    Write-Host "1. n8n está corriendo (http://localhost:5678)" -ForegroundColor Gray
    Write-Host "2. El workflow 'LLM Agent - Orquestador de Agencia' está importado y ACTIVO" -ForegroundColor Gray
    Write-Host "3. Las credenciales de OpenAI y Postgres están configuradas" -ForegroundColor Gray
    exit 1
}

# Tests
Write-Host "=== Iniciando pruebas ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Registrar cliente
Test-LLMAgent -Mensaje "Registra un cliente llamado Pedro Sánchez, email pedro@test.com, teléfono +34666777888, documento P1234567" `
              -Descripcion "Registrar nuevo cliente"

Start-Sleep -Seconds 2

# Test 2: Consultar clientes
Test-LLMAgent -Mensaje "Muéstrame todos los clientes que se registraron hoy" `
              -Descripcion "Consultar clientes recientes"

Start-Sleep -Seconds 2

# Test 3: Crear reserva
Test-LLMAgent -Mensaje "Crea una reserva de vuelo para el cliente C-0001 con destino a Madrid, origen Barcelona, salida 2025-11-15, regreso 2025-11-20, precio 280 euros" `
              -Descripcion "Crear reserva de vuelo"

Start-Sleep -Seconds 2

# Test 4: Consulta compleja
Test-LLMAgent -Mensaje "Muéstrame las reservas pendientes ordenadas por fecha de salida" `
              -Descripcion "Consultar reservas pendientes"

Start-Sleep -Seconds 2

# Test 5: Actualización
Test-LLMAgent -Mensaje "Cambia el estado de la reserva R-1001 a 'confirmado'" `
              -Descripcion "Actualizar estado de reserva"

Start-Sleep -Seconds 2

# Test 6: Consulta con filtro
Test-LLMAgent -Mensaje "¿Cuántos clientes VIP tenemos?" `
              -Descripcion "Contar clientes VIP"

Start-Sleep -Seconds 2

# Test 7: Consulta con JOIN
Test-LLMAgent -Mensaje "Muéstrame los clientes con sus reservas activas" `
              -Descripcion "Consulta con JOIN"

Write-Host ""
Write-Host "=== Pruebas completadas ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verifica los resultados en la base de datos:" -ForegroundColor Yellow
Write-Host 'docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT * FROM clientes ORDER BY id DESC LIMIT 5;"' -ForegroundColor Gray
Write-Host 'docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT * FROM reservas ORDER BY id DESC LIMIT 5;"' -ForegroundColor Gray
Write-Host ""
