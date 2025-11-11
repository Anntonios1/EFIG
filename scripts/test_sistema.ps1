# Script de prueba completo - Sistema de Agencia de Viajes

Write-Output "=== Script de Prueba del Sistema ==="
Write-Output ""

# Variables de configuración
$n8nUrl = "http://localhost:5678"
$webhookCliente = "$n8nUrl/webhook/nuevo-cliente"
$webhookReserva = "$n8nUrl/webhook/nueva-reserva"

Write-Output "Configuración:"
Write-Output "  n8n URL: $n8nUrl"
Write-Output "  Webhook Cliente: $webhookCliente"
Write-Output "  Webhook Reserva: $webhookReserva"
Write-Output ""

# Test 1: Verificar que n8n está corriendo
Write-Output "Test 1: Verificando que n8n está corriendo..."
try {
    $response = Invoke-WebRequest -Uri $n8nUrl -UseBasicParsing -ErrorAction Stop
    Write-Output "  ✓ n8n está corriendo en $n8nUrl"
} catch {
    Write-Output "  ✗ n8n NO está corriendo en $n8nUrl"
    Write-Output "  Error: $($_.Exception.Message)"
    Write-Output ""
    Write-Output "Solución: levanta n8n antes de ejecutar este script."
    exit 1
}

Write-Output ""

# Test 2: Registrar un nuevo cliente
Write-Output "Test 2: Registrando nuevo cliente (Juan Perez)..."
$bodyCliente = @{
    nombre = 'Juan Perez'
    email = 'juan.perez@example.com'
    telefono = '+34123456780'
    documento = 'Y9876543'
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $webhookCliente -Method Post -Body $bodyCliente -ContentType 'application/json' -ErrorAction Stop
    Write-Output "  ✓ Cliente registrado exitosamente"
    Write-Output "  Respuesta: $response"
} catch {
    Write-Output "  ✗ Error al registrar cliente"
    Write-Output "  Error: $($_.Exception.Message)"
    Write-Output ""
    Write-Output "Posibles causas:"
    Write-Output "  - El workflow 'Registro de Nuevo Cliente - Postgres' no está activo en n8n"
    Write-Output "  - La credencial de Postgres no está configurada"
    Write-Output "  - El webhook no está en el path correcto"
}

Write-Output ""

# Test 3: Verificar inserción en la base de datos
Write-Output "Test 3: Verificando inserción en la base de datos..."
$dbCheck = docker exec n8n_postgres psql -U n8n -d n8n_db -t -c "SELECT id_cliente, nombre_completo, email FROM clientes WHERE email = 'juan.perez@example.com';"
if ($dbCheck) {
    Write-Output "  ✓ Cliente encontrado en la base de datos:"
    Write-Output "  $dbCheck"
} else {
    Write-Output "  ✗ Cliente NO encontrado en la base de datos"
}

Write-Output ""

# Test 4: Registrar una reserva (requiere que el cliente exista)
Write-Output "Test 4: Registrando una reserva para el cliente..."
$bodyReserva = @{
    idcliente = 'C-0001'
    tipo = 'vuelo'
    origen = 'Madrid'
    destino = 'París'
    fecha_salida = '2025-11-20'
    fecha_regreso = '2025-11-25'
    precio = 350.00
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $webhookReserva -Method Post -Body $bodyReserva -ContentType 'application/json' -ErrorAction Stop
    Write-Output "  ✓ Reserva registrada exitosamente"
    Write-Output "  Respuesta: $response"
} catch {
    Write-Output "  ✗ Error al registrar reserva"
    Write-Output "  Error: $($_.Exception.Message)"
    Write-Output ""
    Write-Output "Posibles causas:"
    Write-Output "  - El workflow 'Registro de Reserva - Postgres' no está activo"
    Write-Output "  - El cliente C-0001 no existe en la base de datos"
}

Write-Output ""

# Test 5: Mostrar resumen de datos
Write-Output "Test 5: Resumen de datos en la base de datos"
Write-Output ""
Write-Output "--- Clientes registrados ---"
docker exec n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_cliente, nombre_completo, email, tipo_cliente FROM clientes ORDER BY id DESC LIMIT 5;"

Write-Output ""
Write-Output "--- Reservas registradas ---"
docker exec n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_reserva, id_cliente, tipo, destino, fecha_salida, estado, precio FROM reservas ORDER BY id DESC LIMIT 5;"

Write-Output ""
Write-Output "=== Fin del script de prueba ==="
