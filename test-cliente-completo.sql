-- Crear cliente de prueba completo con todos los datos
INSERT INTO clientes (nombre_completo, email, telefono, documento, tipo_cliente, telegram_id)
VALUES ('María Fernanda López García', 'maria.lopez.test@gmail.com', '315-8765432', '52789456', 'VIP', 987654321)
RETURNING *;

-- Crear una reserva para este cliente (usará el id_cliente generado)
INSERT INTO reservas (id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, precio, estado, notas)
VALUES ('C-0038', 'vuelo', 'Bogotá', 'Cartagena', '2025-12-15', '2025-12-20', 850000, 'confirmada', 'Vuelo redondo todo incluido, cliente VIP con descuento 10%')
RETURNING *;

-- Crear un pago para la reserva (R-0019 que acabamos de crear)
INSERT INTO pagos (id_reserva, monto, metodo, estado)
VALUES ('R-0019', 850000, 'tarjeta_credito', 'completado')
RETURNING *;
