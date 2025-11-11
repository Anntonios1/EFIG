# Guía para activar workflows en n8n

Write-Host "`n=== PROBLEMA: Webhook 404 ===" -ForegroundColor Red
Write-Host ""
Write-Host "El error significa que el workflow NO ESTA ACTIVO en n8n." -ForegroundColor Yellow
Write-Host ""

Write-Host "SOLUCION - Sigue estos pasos:" -ForegroundColor Cyan
Write-Host ""

Write-Host "PASO 1: Abre n8n en tu navegador" -ForegroundColor Yellow
Write-Host "  URL local: http://localhost:5678" -ForegroundColor White
Write-Host "  URL publica: https://e149bd15a769.ngrok-free.app" -ForegroundColor White
Write-Host ""

Write-Host "PASO 2: Verifica si tienes workflows importados" -ForegroundColor Yellow
Write-Host "  - Ve a 'Workflows' en el menu lateral izquierdo" -ForegroundColor Gray
Write-Host "  - Deberias ver workflows como:" -ForegroundColor Gray
Write-Host "    * 'LLM Agent - Orquestador de Agencia'" -ForegroundColor White
Write-Host "    * 'Registro de Nuevo Cliente - Postgres'" -ForegroundColor White
Write-Host "    * 'Registro de Reserva - Postgres'" -ForegroundColor White
Write-Host ""

Write-Host "PASO 3: Si NO ves workflows, importalos:" -ForegroundColor Yellow
Write-Host "  1. Clic en '+ Add workflow'" -ForegroundColor Gray
Write-Host "  2. Clic en los 3 puntos (...) arriba a la derecha" -ForegroundColor Gray
Write-Host "  3. 'Import from File'" -ForegroundColor Gray
Write-Host "  4. Selecciona estos archivos (uno por uno):" -ForegroundColor Gray
Write-Host "     - workflows/llm_agent_orchestrator_n8n.json" -ForegroundColor White
Write-Host "     - workflows/register_cliente_postgres_n8n.json" -ForegroundColor White
Write-Host "     - workflows/register_reserva_postgres_n8n.json" -ForegroundColor White
Write-Host ""

Write-Host "PASO 4: ACTIVAR cada workflow" -ForegroundColor Yellow -BackgroundColor DarkRed
Write-Host "  Para cada workflow importado:" -ForegroundColor Gray
Write-Host "  1. Abrelo haciendo clic en el" -ForegroundColor Gray
Write-Host "  2. Configura las credenciales:" -ForegroundColor Gray
Write-Host "     - Nodo 'Postgres': selecciona tu credencial de Postgres" -ForegroundColor White
Write-Host "     - Nodo 'OpenAI/Gemini': selecciona tu credencial de LLM" -ForegroundColor White
Write-Host "  3. Busca el toggle 'Inactive' arriba a la derecha" -ForegroundColor Gray
Write-Host "  4. HAZ CLIC para cambiar a 'Active' (debe ponerse VERDE)" -ForegroundColor Gray
Write-Host "  5. Guarda con Ctrl+S" -ForegroundColor Gray
Write-Host ""

Write-Host "PASO 5: Verifica que el webhook este activo" -ForegroundColor Yellow
Write-Host "  - En el workflow activo, haz clic en el nodo 'Webhook'" -ForegroundColor Gray
Write-Host "  - Deberia mostrar una URL de produccion:" -ForegroundColor Gray
Write-Host "    Production URL: https://e149bd15a769.ngrok-free.app/webhook/agente" -ForegroundColor White
Write-Host ""

Write-Host "PRUEBA RAPIDA:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Una vez activo, ejecuta:" -ForegroundColor Gray
Write-Host ""
Write-Host '$body = @{ mensaje = "Hola" } | ConvertTo-Json' -ForegroundColor White
Write-Host 'Invoke-RestMethod -Uri "https://e149bd15a769.ngrok-free.app/webhook/agente" -Method Post -Body $body -ContentType "application/json"' -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTA IMPORTANTE:" -ForegroundColor Red
Write-Host "El error 404 es NORMAL si el workflow no esta activo." -ForegroundColor Yellow
Write-Host "Solo activando el workflow el webhook se registra." -ForegroundColor Yellow
Write-Host ""

Write-Host "¿Necesitas ayuda para importar o activar workflows?" -ForegroundColor Cyan
Write-Host "Dime y te guio paso a paso." -ForegroundColor Gray
Write-Host ""
