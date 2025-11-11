-- Script de prueba rápida de PostgreSQL
-- Ejecutar: docker exec n8n_postgres psql -U n8n -d n8n_db -f /path/to/este/archivo.sql

-- Resumen de tablas
SELECT 'RESUMEN DE BASE DE DATOS' AS info;
SELECT 'Clientes' AS tabla, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'Reservas', COUNT(*) FROM reservas
UNION ALL
SELECT 'Pagos', COUNT(*) FROM pagos;

-- Todos los clientes
SELECT '' AS separador;
SELECT 'CLIENTES REGISTRADOS' AS info;
SELECT id_cliente, nombre_completo, email, telefono, tipo_cliente, fecha_registro
FROM clientes
ORDER BY id_cliente;

-- Todas las reservas con información del cliente
SELECT '' AS separador;
SELECT 'RESERVAS ACTIVAS' AS info;
SELECT 
  r.id_reserva,
  c.nombre_completo AS cliente,
  r.tipo,
  r.origen || ' → ' || r.destino AS ruta,
  r.fecha_salida,
  r.fecha_regreso,
  r.estado,
  r.precio
FROM reservas r
JOIN clientes c ON r.id_cliente = c.id_cliente
ORDER BY r.fecha_salida;

-- Todos los pagos
SELECT '' AS separador;
SELECT 'PAGOS REALIZADOS' AS info;
SELECT 
  p.id_pago,
  r.id_reserva,
  c.nombre_completo AS cliente,
  p.monto,
  p.metodo,
  p.estado,
  p.fecha
FROM pagos p
JOIN reservas r ON p.id_reserva = r.id_reserva
JOIN clientes c ON r.id_cliente = c.id_cliente
ORDER BY p.fecha DESC;

-- Resumen financiero por cliente
SELECT '' AS separador;
SELECT 'RESUMEN FINANCIERO' AS info;
SELECT 
  c.id_cliente,
  c.nombre_completo,
  c.tipo_cliente,
  COUNT(r.id_reserva) AS total_reservas,
  COALESCE(SUM(r.precio), 0) AS total_reservado,
  COALESCE(SUM(p.monto), 0) AS total_pagado,
  COALESCE(SUM(r.precio), 0) - COALESCE(SUM(p.monto), 0) AS saldo_pendiente
FROM clientes c
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
GROUP BY c.id_cliente, c.nombre_completo, c.tipo_cliente
ORDER BY total_reservado DESC;
