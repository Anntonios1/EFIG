# Solución: Webhook no registrado aunque esté activo

Write-Host "`n=== SOLUCION: Webhook no registrado ===" -ForegroundColor Red
Write-Host ""

Write-Host "PROBLEMA:" -ForegroundColor Yellow
Write-Host "El toggle esta verde PERO el webhook no se registro." -ForegroundColor White
Write-Host "Esto pasa cuando hay un error en las credenciales." -ForegroundColor White
Write-Host ""

Write-Host "SOLUCION EN 5 PASOS:" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Ve a: http://localhost:5678/workflow/qekUMhBirvSbpIqX" -ForegroundColor White
Write-Host ""

Write-Host "2. DESACTIVA el workflow (haz clic en Active -> Inactive)" -ForegroundColor Yellow
Write-Host ""

Write-Host "3. Verifica/configura las credenciales:" -ForegroundColor Yellow
Write-Host "   a) Haz clic en el nodo 'Postgres'" -ForegroundColor Gray
Write-Host "      - Si ves un triangulo rojo, la credencial esta mal" -ForegroundColor Red
Write-Host "      - Configura: host=postgres, db=n8n_db, user=n8n, pass=n8npass" -ForegroundColor White
Write-Host ""
Write-Host "   b) Haz clic en el nodo del LLM (OpenAI/HTTP Request)" -ForegroundColor Gray
Write-Host "      - Si no tienes API key, usa un nodo 'No Operation'" -ForegroundColor White
Write-Host "      - O configura tu API key de Gemini/OpenAI" -ForegroundColor White
Write-Host ""

Write-Host "4. Guarda el workflow (Ctrl+S)" -ForegroundColor Yellow
Write-Host ""

Write-Host "5. REACTIVA el workflow (Inactive -> Active)" -ForegroundColor Yellow
Write-Host "   - Debe cambiar a verde SIN errores" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "ALTERNATIVA - Usar Test URL:" -ForegroundColor Green
Write-Host ""
Write-Host "Mientras arreglas las credenciales:" -ForegroundColor Gray
Write-Host "1. Haz clic en el nodo 'Webhook'" -ForegroundColor White
Write-Host "2. Copia la 'Test URL'" -ForegroundColor White
Write-Host "3. Haz clic en 'Listen for Test Event'" -ForegroundColor White
Write-Host "4. Usa esa URL para probar (solo funciona una vez)" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "CHECKLIST:" -ForegroundColor Yellow
Write-Host "  [ ] Credencial de Postgres configurada y SIN triangulo rojo" -ForegroundColor Gray
Write-Host "  [ ] Credencial de LLM configurada (o nodo deshabilitado)" -ForegroundColor Gray
Write-Host "  [ ] Workflow guardado (Ctrl+S)" -ForegroundColor Gray
Write-Host "  [ ] Workflow desactivado y reactivado" -ForegroundColor Gray
Write-Host "  [ ] Toggle en verde sin errores" -ForegroundColor Gray
Write-Host ""

Write-Host "Cuando todo este OK, prueba:" -ForegroundColor Cyan
Write-Host ""
Write-Host '$body = @{ mensaje = "Lista clientes" } | ConvertTo-Json' -ForegroundColor White
Write-Host 'Invoke-RestMethod -Uri "https://e149bd15a769.ngrok-free.app/webhook/agente" -Method Post -Body $body -ContentType "application/json"' -ForegroundColor White
Write-Host ""

Write-Host "Dime que error ves en el workflow (triangulos rojos en que nodos?)" -ForegroundColor Yellow
Write-Host ""
