# Guía paso a paso para activar el workflow en n8n

Write-Host "=== Verificación del Sistema ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar que n8n está corriendo
Write-Host "1. Verificando que n8n está accesible..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5678" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   OK n8n está corriendo en http://localhost:5678" -ForegroundColor Green
} catch {
    Write-Host "   ERROR n8n NO está corriendo" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Solución: Levanta n8n primero con uno de estos comandos:" -ForegroundColor Yellow
    Write-Host "   Opción A (Docker):" -ForegroundColor Gray
    Write-Host "   docker run -it --rm -p 5678:5678 -e N8N_BASIC_AUTH_ACTIVE=false --name n8n-temp n8nio/n8n:latest" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Opción B (local):" -ForegroundColor Gray
    Write-Host "   n8n start" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# 2. Verificar que PostgreSQL está corriendo
Write-Host "2. Verificando que PostgreSQL está corriendo..." -ForegroundColor Yellow
$pgStatus = docker ps --filter name=n8n_postgres --format "{{.Status}}"
if ($pgStatus) {
    Write-Host "   OK PostgreSQL está corriendo: $pgStatus" -ForegroundColor Green
} else {
    Write-Host "   ERROR PostgreSQL NO está corriendo" -ForegroundColor Red
    Write-Host "   Ejecuta: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 3. Mostrar instrucciones para importar el workflow
Write-Host "3. SIGUIENTE PASO: Importar y activar el workflow en n8n" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Sigue estos pasos en tu navegador:" -ForegroundColor White
Write-Host ""
Write-Host "   A) Abre n8n en tu navegador:" -ForegroundColor Yellow
Write-Host "      http://localhost:5678" -ForegroundColor White
Write-Host ""
Write-Host "   B) Crear credencial de PostgreSQL:" -ForegroundColor Yellow
Write-Host "      1. Haz clic en tu usuario (esquina superior derecha)" -ForegroundColor Gray
Write-Host "      2. Settings → Credentials" -ForegroundColor Gray
Write-Host "      3. Clic en 'Add Credential'" -ForegroundColor Gray
Write-Host "      4. Busca 'Postgres' y selecciónalo" -ForegroundColor Gray
Write-Host "      5. Completa los datos:" -ForegroundColor Gray
Write-Host "         - Host: host.docker.internal" -ForegroundColor White
Write-Host "         - Port: 5432" -ForegroundColor White
Write-Host "         - Database: n8n_db" -ForegroundColor White
Write-Host "         - User: n8n" -ForegroundColor White
Write-Host "         - Password: n8npass" -ForegroundColor White
Write-Host "      6. Haz clic en 'Test' y luego 'Save'" -ForegroundColor Gray
Write-Host ""
Write-Host "   C) Importar el workflow:" -ForegroundColor Yellow
Write-Host "      1. Vuelve a Workflows (menú lateral izquierdo)" -ForegroundColor Gray
Write-Host "      2. Clic en el botón '+ Add workflow'" -ForegroundColor Gray
Write-Host "      3. Clic en el icono de tres puntos (...) arriba a la derecha" -ForegroundColor Gray
Write-Host "      4. Selecciona 'Import from File'" -ForegroundColor Gray
Write-Host "      5. Navega y selecciona:" -ForegroundColor Gray
Write-Host "         C:\Users\teamp\Documents\N8N FINAL\workflows\register_cliente_postgres_n8n.json" -ForegroundColor White
Write-Host "      6. Se abrirá el workflow importado" -ForegroundColor Gray
Write-Host ""
Write-Host "   D) Configurar el nodo Postgres:" -ForegroundColor Yellow
Write-Host "      1. Haz clic en el nodo 'Postgres' (el rectángulo gris en el canvas)" -ForegroundColor Gray
Write-Host "      2. En el panel derecho, busca 'Credential to connect with'" -ForegroundColor Gray
Write-Host "      3. Selecciona la credencial de Postgres que creaste" -ForegroundColor Gray
Write-Host "      4. Haz clic en 'Execute node' para probar (opcional)" -ForegroundColor Gray
Write-Host ""
Write-Host "   E) IMPORTANTE - Activar el workflow:" -ForegroundColor Yellow
Write-Host "      1. Busca el toggle 'Inactive' en la esquina superior derecha" -ForegroundColor Gray
Write-Host "      2. Haz clic para cambiar a 'Active'" -ForegroundColor Gray
Write-Host "      3. El toggle debe volverse verde y mostrar 'Active'" -ForegroundColor Gray
Write-Host ""
Write-Host "   F) OPCIONAL - Desactivar Gmail y Telegram si solo quieres probar la DB:" -ForegroundColor Yellow
Write-Host "      1. Haz clic derecho en los nodos 'Gmail Send' y 'Telegram'" -ForegroundColor Gray
Write-Host "      2. Selecciona 'Disable' o elimínalos" -ForegroundColor Gray
Write-Host "      3. Guarda el workflow (Ctrl+S)" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Una vez activado el workflow, ejecuta este comando para probar ===" -ForegroundColor Cyan
Write-Host ""
Write-Host '$body = @{ nombre = "Juan Perez"; email = "juan@example.com"; telefono = "+34123456780"; documento = "Y9876543" } | ConvertTo-Json' -ForegroundColor White
Write-Host 'Invoke-RestMethod -Uri "http://localhost:5678/webhook/nuevo-cliente" -Method Post -Body $body -ContentType "application/json"' -ForegroundColor White
Write-Host ""
Write-Host "Y luego verifica la inserción:" -ForegroundColor Yellow
Write-Host 'docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_cliente, nombre_completo, email FROM clientes ORDER BY id DESC LIMIT 5;"' -ForegroundColor White
Write-Host ""
