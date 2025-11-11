# Configuración del Workflow Activo
# URL del workflow: http://localhost:5678/workflow/qekUMhBirvSbpIqX

Write-Host "`n=== CONFIGURAR WORKFLOW: LLM Agent ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL del workflow: http://localhost:5678/workflow/qekUMhBirvSbpIqX" -ForegroundColor White
Write-Host ""

Write-Host "PASO 1: Configurar Credenciales" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "A. Credencial de PostgreSQL:" -ForegroundColor Green
Write-Host "   1. Busca el nodo 'Postgres' (color azul/morado)" -ForegroundColor Gray
Write-Host "   2. Haz clic en el nodo" -ForegroundColor Gray
Write-Host "   3. En 'Credential to connect with', selecciona o crea:" -ForegroundColor Gray
Write-Host ""
Write-Host "      Nombre: Postgres - Agencia Viajes" -ForegroundColor White
Write-Host "      Host: postgres (o localhost si no funciona)" -ForegroundColor White
Write-Host "      Database: n8n_db" -ForegroundColor White
Write-Host "      User: n8n" -ForegroundColor White
Write-Host "      Password: n8npass" -ForegroundColor White
Write-Host "      Port: 5432" -ForegroundColor White
Write-Host ""

Write-Host "B. Credencial de Google Gemini:" -ForegroundColor Green
Write-Host "   1. Busca el nodo que dice 'OpenAI' o 'HTTP Request'" -ForegroundColor Gray
Write-Host "   2. Si es OpenAI, cambialo por 'HTTP Request' para usar Gemini" -ForegroundColor Gray
Write-Host "   3. O crea tu API key de Gemini en:" -ForegroundColor Gray
Write-Host "      https://aistudio.google.com/app/apikey" -ForegroundColor Cyan
Write-Host ""

Write-Host "PASO 2: ACTIVAR el Workflow" -ForegroundColor Yellow -BackgroundColor DarkRed
Write-Host "-------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "   1. Busca el toggle 'Inactive' arriba a la DERECHA" -ForegroundColor White
Write-Host "   2. Haz CLIC en el toggle" -ForegroundColor White
Write-Host "   3. Debe cambiar a 'Active' y ponerse VERDE" -ForegroundColor Green
Write-Host "   4. Presiona Ctrl+S para guardar" -ForegroundColor White
Write-Host ""

Write-Host "PASO 3: Verificar el Webhook" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "   1. Haz clic en el nodo 'Webhook' (primer nodo)" -ForegroundColor Gray
Write-Host "   2. Verifica que el 'HTTP Method' sea 'POST'" -ForegroundColor Gray
Write-Host "   3. El 'Path' debe ser: agente" -ForegroundColor White
Write-Host "   4. Deberia mostrar:" -ForegroundColor Gray
Write-Host ""
Write-Host "      Test URL: http://localhost:5678/webhook-test/..." -ForegroundColor Cyan
Write-Host "      Production URL: https://e149bd15a769.ngrok-free.app/webhook/agente" -ForegroundColor Green
Write-Host ""

Write-Host "PASO 4: Probar el Webhook" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejecuta este comando en PowerShell:" -ForegroundColor White
Write-Host ""
Write-Host '$body = @{' -ForegroundColor Cyan
Write-Host '    mensaje = "Lista todos los clientes"' -ForegroundColor Cyan
Write-Host '} | ConvertTo-Json' -ForegroundColor Cyan
Write-Host ""
Write-Host 'Invoke-RestMethod -Uri "https://e149bd15a769.ngrok-free.app/webhook/agente" -Method Post -Body $body -ContentType "application/json"' -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "CHECKLIST RAPIDO:" -ForegroundColor Yellow
Write-Host "  [ ] Credencial de Postgres configurada" -ForegroundColor Gray
Write-Host "  [ ] Credencial de Gemini/OpenAI configurada" -ForegroundColor Gray
Write-Host "  [ ] Toggle cambiado a 'Active' (VERDE)" -ForegroundColor Gray
Write-Host "  [ ] Workflow guardado (Ctrl+S)" -ForegroundColor Gray
Write-Host "  [ ] Production URL visible en nodo Webhook" -ForegroundColor Gray
Write-Host ""

Write-Host "Si completaste todo, el webhook deberia funcionar SIN error 404." -ForegroundColor Green
Write-Host ""
Write-Host "¿Tienes alguna duda o error?" -ForegroundColor Cyan
Write-Host ""
