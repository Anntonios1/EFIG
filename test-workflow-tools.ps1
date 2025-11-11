# Test del workflow con Tool Calls
Write-Host "`n🔧 Test de Tool Calls con AI Agent" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Gray

# URL del webhook (ajusta según tu n8n)
$webhookUrl = "https://teampikiautomation.app.n8n.cloud/webhook/test-tool-calls"

# Tests
$tests = @(
    @{
        name = "Test 1: Listar todos los clientes"
        message = "lista todos los clientes"
        description = "Debería usar la tool 'listar_clientes'"
    },
    @{
        name = "Test 2: Buscar cliente específico"
        message = "busca el cliente C-0036"
        description = "Debería usar la tool 'buscar_cliente'"
    },
    @{
        name = "Test 3: Ver reservas de un cliente"
        message = "muéstrame las reservas del cliente C-0036"
        description = "Debería usar 'buscar_cliente' y luego 'listar_reservas_cliente'"
    },
    @{
        name = "Test 4: Múltiples operaciones"
        message = "busca el cliente Jeyler y dime cuántas reservas tiene"
        description = "Debería usar múltiples tools en secuencia"
    },
    @{
        name = "Test 5: Sin tools necesarios"
        message = "hola, cómo estás?"
        description = "No debería usar ninguna tool, solo responder"
    }
)

foreach ($test in $tests) {
    Write-Host "`n" -NoNewline
    Write-Host "📌 $($test.name)" -ForegroundColor Yellow
    Write-Host "   $($test.description)" -ForegroundColor Gray
    Write-Host "   Mensaje: '$($test.message)'" -ForegroundColor Cyan
    
    try {
        $body = @{
            message = $test.message
            session = "test-session-$(Get-Date -Format 'HHmmss')"
        } | ConvertTo-Json
        
        Write-Host "   ⏳ Enviando..." -ForegroundColor Gray
        
        $response = Invoke-RestMethod -Uri $webhookUrl `
            -Method Post `
            -ContentType "application/json" `
            -Body $body `
            -TimeoutSec 30
        
        Write-Host "   ✅ Respuesta:" -ForegroundColor Green
        Write-Host "   $($response.response)" -ForegroundColor White
        
    } catch {
        Write-Host "   ❌ Error:" -ForegroundColor Red
        Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 2
}

Write-Host "`n" -NoNewline
Write-Host "="*60 -ForegroundColor Gray
Write-Host "✅ Tests completados" -ForegroundColor Green
Write-Host "`nNOTA: Revisa los logs del servidor Copilot para ver los tool calls:" -ForegroundColor Yellow
Write-Host "docker logs copilot_api_cloud --tail 50" -ForegroundColor Cyan
