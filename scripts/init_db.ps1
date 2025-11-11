# Script de ayuda para levantar PostgreSQL con Docker y probar conexión

# Levantar el contenedor
Write-Output "Levantando PostgreSQL (docker-compose up -d)..."
docker-compose -f "${PWD}\docker-compose.yml" up -d

Write-Output "Esperando 5 segundos para que el servicio arranque..."
Start-Sleep -Seconds 5

Write-Output "Conectando a la base para mostrar tablas (requiere psql instalado o usar docker exec):"
Write-Output "Con docker exec:"
Write-Output "  docker exec -it n8n_postgres psql -U n8n -d n8n_db -c \"\dt\""

Write-Output "O ejecutar desde PowerShell si tienes psql:" 
Write-Output "  psql -h localhost -U n8n -d n8n_db -c \"SELECT * FROM clients LIMIT 5;\""

Write-Output "Si necesitas que ejecute consultas automáticamente, dímelo y preparo comandos para psql o un pequeño script Node/Python para probar inserciones via HTTP al webhook n8n."
