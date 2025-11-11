-- Crear pago para la reserva R-0019
INSERT INTO pagos (id_reserva, monto, metodo, estado)
VALUES ('R-0019', 850000, 'tarjeta_credito', 'completado')
RETURNING *;
