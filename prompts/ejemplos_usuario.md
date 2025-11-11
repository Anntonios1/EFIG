# Ejemplos de Prompts para el LLM Agent

## 📝 Operaciones con Clientes

### Crear/Registrar
```
"Registra un cliente llamado Ana López, email ana@test.com, teléfono +34123456789"
"Añade un nuevo cliente VIP: nombre Carlos Ruiz, email carlos@vip.com, documento C9876543"
"Crea un cliente frecuente llamado Laura Martín con teléfono +34555666777"
```

### Consultar
```
"Muéstrame todos los clientes"
"¿Cuántos clientes tenemos?"
"Dame la lista de clientes VIP"
"Muéstrame los clientes que se registraron hoy"
"Busca el cliente con email ana@test.com"
"¿Quiénes son los clientes frecuentes?"
```

### Actualizar
```
"Cambia el email del cliente C-0001 a nuevo@email.com"
"Marca al cliente C-0002 como VIP"
"Actualiza el teléfono del cliente con email carlos@test.com a +34999888777"
```

---

## ✈️ Operaciones con Reservas

### Crear
```
"Crea una reserva de vuelo para el cliente C-0001 a París, salida 2025-12-10, regreso 2025-12-15"
"Registra un paquete turístico para C-0002 a Cancún del 20 de diciembre al 5 de enero, precio 2500 euros"
"Añade una reserva de hotel en Barcelona para el cliente C-0001, del 15 al 20 de noviembre, 450 euros"
```

### Consultar
```
"Muéstrame todas las reservas pendientes"
"¿Cuántas reservas confirmadas tenemos?"
"Dame las reservas del cliente C-0001"
"Muéstrame los vuelos que salen esta semana"
"¿Qué reservas hay para París?"
"Lista las reservas más caras"
"Muéstrame las reservas canceladas del último mes"
```

### Actualizar
```
"Cambia el estado de la reserva R-1001 a confirmado"
"Marca la reserva R-1002 como pagado"
"Actualiza el precio de la reserva R-1003 a 350 euros"
"Cancela todas las reservas pendientes del cliente C-0005"
```

---

## 💳 Operaciones con Pagos

### Crear
```
"Registra un pago de 450 euros para la reserva R-1001, método tarjeta"
"Añade un pago parcial de 700 euros para la reserva R-1002, transferencia bancaria"
"Crea un pago en efectivo de 120 euros para R-1003"
```

### Consultar
```
"Muéstrame todos los pagos completados"
"¿Cuánto dinero hemos recibido hoy?"
"Dame los pagos pendientes"
"Muéstrame los pagos de la reserva R-1001"
"¿Qué pagos se hicieron por transferencia?"
```

### Actualizar
```
"Marca el pago P-5001 como completado"
"Cambia el método del pago P-5002 a tarjeta"
```

---

## 📊 Consultas Analíticas y Complejas

### Reportes
```
"Dame un resumen de las ventas de este mes"
"¿Cuál es el destino más popular?"
"Muéstrame los clientes con más reservas"
"¿Cuántos vuelos, hoteles y paquetes hemos vendido?"
"Dame el total de ingresos por método de pago"
```

### Consultas con JOINs
```
"Muéstrame los clientes con sus reservas activas"
"Dame las reservas con sus pagos asociados"
"Lista los clientes que tienen reservas pendientes de pago"
"Muéstrame qué clientes no han hecho ninguna reserva todavía"
```

### Filtros complejos
```
"Muéstrame las reservas de más de 1000 euros que aún están pendientes"
"Dame los clientes VIP que tienen reservas confirmadas para diciembre"
"¿Qué reservas de vuelo a destinos europeos tenemos en las próximas 2 semanas?"
"Muéstrame los pagos completados de las reservas confirmadas"
```

---

## 🔍 Búsquedas y Validaciones

### Verificar existencia
```
"¿Existe el cliente con email ana@test.com?"
"Verifica si hay alguna reserva para el cliente C-0001 en diciembre"
"¿Tiene el cliente C-0002 pagos pendientes?"
```

### Búsquedas por criterio
```
"Busca clientes cuyo nombre contenga 'García'"
"Encuentra reservas con destino a Barcelona"
"Muéstrame pagos mayores a 500 euros"
```

---

## ⚠️ Operaciones Avanzadas (Usar con cuidado)

### Eliminaciones (requieren validación adicional)
```
"Elimina la reserva R-9999 (solo si está cancelada)"
"Borra los clientes que no tienen ninguna reserva asociada"
```

### Actualizaciones masivas
```
"Marca como confirmadas todas las reservas pendientes del cliente C-0001"
"Cambia todos los clientes nuevos a frecuentes si tienen más de 3 reservas"
```

---

## 💡 Tips para mejores resultados

### ✅ BUENAS PRÁCTICAS

1. **Sé específico con los datos**
   - ✅ "Crea una reserva para C-0001 a París del 10 al 15 de diciembre, precio 350 euros"
   - ❌ "Crea una reserva a París"

2. **Usa IDs cuando los conozcas**
   - ✅ "Actualiza el estado de R-1001 a confirmado"
   - ❌ "Actualiza la reserva de Juan a París"

3. **Para fechas, usa formato claro**
   - ✅ "del 15 de noviembre al 20 de noviembre" o "2025-11-15 al 2025-11-20"
   - ❌ "del 15 al 20"

4. **Especifica el tipo cuando crees registros**
   - ✅ "Registra un cliente VIP llamado..."
   - ✅ "Crea una reserva de vuelo para..."

### ❌ EVITAR

1. **Consultas ambiguas**
   - ❌ "Muéstrame todo"
   - ❌ "¿Qué tenemos?"

2. **Operaciones peligrosas sin contexto**
   - ❌ "Elimina todos los clientes"
   - ❌ "Borra las reservas"

3. **Mezclar múltiples operaciones**
   - ❌ "Crea un cliente y una reserva y un pago para ese cliente"
   - ✅ Hazlo en mensajes separados

---

## 🧪 Para Probar el Sistema

Secuencia recomendada:

```powershell
# 1. Crear cliente
$body = @{ mensaje = "Registra un cliente llamado Test User, email test@example.com, teléfono +34111222333" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# 2. Consultar el cliente recién creado
$body = @{ mensaje = "Busca el cliente con email test@example.com" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# 3. Crear reserva para ese cliente (usa el ID que te devolvió)
$body = @{ mensaje = "Crea una reserva de vuelo para el cliente C-XXXX a Madrid del 1 al 5 de diciembre, precio 200 euros" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# 4. Registrar pago
$body = @{ mensaje = "Registra un pago de 200 euros para la reserva R-YYYY, método tarjeta" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# 5. Verificar todo
$body = @{ mensaje = "Muéstrame el cliente C-XXXX con todas sus reservas y pagos" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"
```

---

## 🔐 Notas de Seguridad

El LLM tiene acceso completo a la base de datos. Para producción:

1. **Implementar whitelist de operaciones** (solo SELECT, INSERT en ciertas tablas)
2. **Validar SQL antes de ejecutar** (nodo de validación)
3. **Añadir aprobación manual** para DELETE y UPDATE masivos
4. **Logs de auditoría** de todas las operaciones
5. **Rate limiting** por usuario/IP

---

¿Necesitas más ejemplos o casos de uso específicos para tu agencia?
