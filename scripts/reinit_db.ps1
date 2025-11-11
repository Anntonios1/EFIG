# Script para re-inicializar PostgreSQL con el esquema actualizado

Write-Host "=== Re-inicializando PostgreSQL con esquema actualizado ===" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Detener y eliminar el contenedor existente
Write-Host "1) Deteniendo contenedor n8n_postgres (si existe)..." -ForegroundColor Yellow
docker stop n8n_postgres 2>$null
docker rm n8n_postgres 2>$null

# Paso 2: Eliminar el volumen de datos antiguo
Write-Host "2) Eliminando volumen de datos antiguo (db/data)..." -ForegroundColor Yellow
if (Test-Path ".\db\data") {
    Remove-Item -Recurse -Force ".\db\data"
    Write-Host "   OK db/data eliminado" -ForegroundColor Green
} else {
    Write-Host "   INFO db/data no existe, continuando..." -ForegroundColor Gray
}

# Paso 3: Levantar el contenedor con el nuevo esquema
Write-Host ""
Write-Host "3) Levantando PostgreSQL con docker-compose..." -ForegroundColor Yellow
docker-compose up -d

# Esperar a que el servicio arranque
Write-Host ""
Write-Host "4) Esperando 8 segundos para que PostgreSQL inicialice..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Paso 4: Verificar tablas
Write-Host ""
Write-Host "5) Verificando tablas creadas:" -ForegroundColor Yellow
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "\dt"

Write-Host ""
Write-Host "6) Verificando datos de ejemplo en tabla 'clientes':" -ForegroundColor Yellow
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_cliente, nombre_completo, email, tipo_cliente FROM clientes;"

Write-Host ""
Write-Host "=== Proceso completado ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Siguiente paso: configurar credencial Postgres en n8n" -ForegroundColor Green
Write-Host "  Host: host.docker.internal"
Write-Host "  Port: 5432"
Write-Host "  Database: n8n_db"
Write-Host "  User: n8n"
Write-Host "  Password: n8npass"
Write-Host ""
Write-Host "Luego importa el workflow 'register_cliente_postgres_n8n.json' y activalo." -ForegroundColor Green
