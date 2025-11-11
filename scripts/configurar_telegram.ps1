# Configuración de Telegram Bot con ngrok

Write-Host "`n=== CONFIGURAR TELEGRAM BOT ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "ERROR DETECTADO:" -ForegroundColor Red
Write-Host "'bad webhook: An HTTPS URL must be provided for webhook'" -ForegroundColor White
Write-Host ""

Write-Host "Esto significa que estas configurando un bot de Telegram." -ForegroundColor Yellow
Write-Host "Telegram REQUIERE HTTPS (no HTTP)." -ForegroundColor Yellow
Write-Host ""

# Obtener URL de ngrok
Write-Host "Obteniendo tu URL HTTPS de ngrok..." -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels"
    $httpsUrl = $response.tunnels[0].public_url
    Write-Host "✓ URL HTTPS disponible: $httpsUrl" -ForegroundColor Green
} catch {
    $httpsUrl = "https://e149bd15a769.ngrok-free.app"
    Write-Host "✓ URL HTTPS (anterior): $httpsUrl" -ForegroundColor Green
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "PASOS PARA CONFIGURAR TELEGRAM BOT:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Crea un bot con @BotFather en Telegram:" -ForegroundColor White
Write-Host "   - Abre Telegram y busca: @BotFather" -ForegroundColor Gray
Write-Host "   - Envia: /newbot" -ForegroundColor Gray
Write-Host "   - Sigue las instrucciones" -ForegroundColor Gray
Write-Host "   - Copia el TOKEN que te da" -ForegroundColor Gray
Write-Host ""

Write-Host "2. En n8n, agrega un nodo 'Telegram Trigger':" -ForegroundColor White
Write-Host "   - Busca 'Telegram' en la lista de nodos" -ForegroundColor Gray
Write-Host "   - Selecciona 'Telegram Trigger'" -ForegroundColor Gray
Write-Host "   - Crea una nueva credencial con tu TOKEN" -ForegroundColor Gray
Write-Host ""

Write-Host "3. IMPORTANTE - Configura el Webhook Mode:" -ForegroundColor Yellow
Write-Host "   - En el nodo Telegram Trigger" -ForegroundColor Gray
Write-Host "   - Webhook Mode: Usa esta URL HTTPS:" -ForegroundColor Gray
Write-Host ""
Write-Host "     $httpsUrl/webhook/telegram" -ForegroundColor Cyan
Write-Host ""
Write-Host "   - NO uses localhost (no funciona con Telegram)" -ForegroundColor Red
Write-Host "   - SOLO usa la URL de ngrok (HTTPS)" -ForegroundColor Green
Write-Host ""

Write-Host "4. Activa el workflow y prueba:" -ForegroundColor White
Write-Host "   - Guarda el workflow (Ctrl+S)" -ForegroundColor Gray
Write-Host "   - Activa el workflow (toggle verde)" -ForegroundColor Gray
Write-Host "   - Envia un mensaje a tu bot en Telegram" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "EJEMPLO DE CONFIGURACION:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Nodo Telegram Trigger:" -ForegroundColor White
Write-Host "  - Webhook URL: $httpsUrl/webhook/telegram" -ForegroundColor Cyan
Write-Host "  - Updates: 'message'" -ForegroundColor Gray
Write-Host "  - Credencial: Tu TOKEN de @BotFather" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "INTEGRACION CON TU LLM AGENT:" -ForegroundColor Green
Write-Host ""
Write-Host "Para que Telegram envie mensajes al LLM Agent:" -ForegroundColor White
Write-Host ""
Write-Host "1. Conecta Telegram Trigger -> HTTP Request" -ForegroundColor Gray
Write-Host "2. En HTTP Request configura:" -ForegroundColor Gray
Write-Host "   - Method: POST" -ForegroundColor White
Write-Host "   - URL: http://localhost:5678/webhook/agente" -ForegroundColor Cyan
Write-Host "   - Body: {`"mensaje`": `"{{`$json.message.text`}}`"}" -ForegroundColor White
Write-Host "3. Conecta la respuesta a 'Telegram' (Send Message)" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "¿Quieres que cree un workflow completo de Telegram + LLM?" -ForegroundColor Yellow
Write-Host "Responde 'si' y lo genero para ti." -ForegroundColor Gray
Write-Host ""

Write-Host "URLs IMPORTANTES:" -ForegroundColor Cyan
Write-Host "  HTTPS (para Telegram): $httpsUrl" -ForegroundColor Green
Write-Host "  Dashboard ngrok: http://localhost:4040" -ForegroundColor White
Write-Host "  n8n: http://localhost:5678" -ForegroundColor White
Write-Host ""
