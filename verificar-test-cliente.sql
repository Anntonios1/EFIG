-- Verificar cliente de prueba completo
SELECT 
  c.id_cliente, 
  c.nombre_completo, 
  c.email, 
  c.telefono, 
  c.documento, 
  c.tipo_cliente, 
  c.telegram_id,
  c.fecha_registro,
  r.id_reserva, 
  r.destino, 
  r.fecha_salida,
  r.precio AS precio_reserva, 
  r.estado AS estado_reserva, 
  p.id_pago, 
  p.monto AS monto_pago, 
  p.metodo, 
  p.estado AS estado_pago
FROM clientes c 
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente 
LEFT JOIN pagos p ON r.id_reserva = p.id_reserva 
WHERE c.id_cliente = 'C-0038';
