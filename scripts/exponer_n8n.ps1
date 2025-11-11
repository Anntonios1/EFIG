# Script para exponer n8n públicamente con ngrok o tunneling

Write-Host "=== Opciones para exponer n8n al exterior ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPCION 1: ngrok (Recomendado - Rapido y facil)" -ForegroundColor Yellow
Write-Host "  - Crea un tunel HTTPS seguro a tu localhost:5678" -ForegroundColor Gray
Write-Host "  - Gratis hasta 20,000 requests/mes" -ForegroundColor Gray
Write-Host "  - URL tipo: https://abc123.ngrok.io" -ForegroundColor Gray
Write-Host ""
Write-Host "  Pasos:" -ForegroundColor White
Write-Host "  1. Descarga ngrok: https://ngrok.com/download" -ForegroundColor Gray
Write-Host "  2. Descomprime y copia ngrok.exe a esta carpeta" -ForegroundColor Gray
Write-Host "  3. Ejecuta: .\ngrok.exe http 5678" -ForegroundColor Gray
Write-Host "  4. Copia la URL que te muestra (https://xxxxx.ngrok.io)" -ForegroundColor Gray
Write-Host "  5. Usa esa URL para acceder a n8n desde cualquier lugar" -ForegroundColor Gray
Write-Host ""

Write-Host "OPCION 2: Cloudflare Tunnel (Alternativa gratuita)" -ForegroundColor Yellow
Write-Host "  - Tunel permanente con dominio propio" -ForegroundColor Gray
Write-Host "  - Mas complejo de configurar" -ForegroundColor Gray
Write-Host ""
Write-Host "  Pasos:" -ForegroundColor White
Write-Host "  1. Instala cloudflared: https://github.com/cloudflare/cloudflared" -ForegroundColor Gray
Write-Host "  2. Ejecuta: cloudflared tunnel --url http://localhost:5678" -ForegroundColor Gray
Write-Host ""

Write-Host "OPCION 3: Abrir puerto en el router (NO recomendado sin HTTPS)" -ForegroundColor Yellow
Write-Host "  - Expone tu IP publica directamente" -ForegroundColor Gray
Write-Host "  - Requiere configurar port forwarding en el router" -ForegroundColor Gray
Write-Host "  - RIESGO: n8n sin autenticacion es inseguro" -ForegroundColor Red
Write-Host ""

Write-Host "OPCION 4: Conectar solo en la red local (LAN)" -ForegroundColor Yellow
Write-Host "  - Acceso desde otros dispositivos en tu misma red WiFi" -ForegroundColor Gray
Write-Host ""
Write-Host "  Tu IP local:" -ForegroundColor White
$ipLocal = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*","Ethernet*" | Where-Object {$_.IPAddress -notlike "169.*"} | Select-Object -First 1).IPAddress
if ($ipLocal) {
    Write-Host "  http://$($ipLocal):5678" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Desde tu movil (conectado a la misma WiFi):" -ForegroundColor Gray
    Write-Host "  - Abre navegador" -ForegroundColor Gray
    Write-Host "  - Ve a: http://$($ipLocal):5678" -ForegroundColor Gray
} else {
    Write-Host "  No se pudo detectar tu IP local" -ForegroundColor Red
    Write-Host "  Ejecuta manualmente: ipconfig" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=== RECOMENDACION ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para pruebas rapidas: usa ngrok (Opcion 1)" -ForegroundColor Green
Write-Host "Para acceso local (mismo WiFi): usa Opcion 4" -ForegroundColor Green
Write-Host ""
Write-Host "¿Que prefieres? Dime y te ayudo a configurarlo." -ForegroundColor Yellow
Write-Host ""
