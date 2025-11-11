# Script de Diagnóstico y Solución para Webhook 404

Write-Host "`n=== DIAGNOSTICO: Webhook 404 ===" -ForegroundColor Red
Write-Host ""

Write-Host "PROBLEMA DETECTADO:" -ForegroundColor Yellow
Write-Host "El error dice 'GET agente' pero deberia ser 'POST agente'" -ForegroundColor White
Write-Host "Esto significa que:" -ForegroundColor Gray
Write-Host "  1. El workflow NO esta activo (toggle en rojo/gris)" -ForegroundColor White
Write-Host "  2. Estas usando GET en vez de POST" -ForegroundColor White
Write-Host ""

Write-Host "SOLUCION INMEDIATA:" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPCION A - Activar en la interfaz:" -ForegroundColor Green
Write-Host "  1. Abre: http://localhost:5678/workflow/qekUMhBirvSbpIqX" -ForegroundColor White
Write-Host "  2. Arriba a la DERECHA, busca el toggle" -ForegroundColor White
Write-Host "  3. Si dice 'Inactive' (rojo/gris), HAZLE CLIC" -ForegroundColor White
Write-Host "  4. Debe cambiar a 'Active' (VERDE)" -ForegroundColor Green
Write-Host "  5. Guarda: Ctrl+S" -ForegroundColor White
Write-Host ""

Write-Host "OPCION B - Usar Test URL (mientras activas):" -ForegroundColor Green
Write-Host "  1. En el workflow, haz clic en el nodo 'Webhook'" -ForegroundColor White
Write-Host "  2. Copia la 'Test URL' (algo como http://localhost:5678/webhook-test/...)" -ForegroundColor White
Write-Host "  3. Usa esa URL en vez de la de produccion" -ForegroundColor White
Write-Host "  4. Clic en 'Listen for Test Event' en el nodo" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IMPORTANTE - El metodo debe ser POST:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Comando CORRECTO:" -ForegroundColor Green
Write-Host ""
Write-Host '$body = @{ mensaje = "Lista clientes" } | ConvertTo-Json' -ForegroundColor White
Write-Host 'Invoke-RestMethod -Uri "https://e149bd15a769.ngrok-free.app/webhook/agente" -Method Post -Body $body -ContentType "application/json"' -ForegroundColor Cyan
Write-Host ""

Write-Host "Si usaste GET (navegador), cambia a POST con el comando de arriba." -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "VERIFICACION VISUAL:" -ForegroundColor Yellow
Write-Host ""
Write-Host "En http://localhost:5678/workflow/qekUMhBirvSbpIqX" -ForegroundColor White
Write-Host "Busca esto arriba a la derecha:" -ForegroundColor Gray
Write-Host ""
Write-Host "  Si ves: [Inactive] <- MALO, haz clic aqui" -ForegroundColor Red
Write-Host "  Si ves: [Active]   <- BUENO, deberia funcionar" -ForegroundColor Green
Write-Host ""

Write-Host "Mientras este en 'Inactive', NINGUN webhook funcionara." -ForegroundColor Yellow
Write-Host ""

Write-Host "¿Que ves en tu pantalla? ¿[Inactive] o [Active]?" -ForegroundColor Cyan
Write-Host ""
