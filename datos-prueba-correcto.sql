-- Script para llenar la base de datos con datos de prueba
-- EFIG Vuelos & Travel - Estructura Real

-- ============================================
-- CLIENTES DE PRUEBA
-- ============================================

-- Generar IDs automáticamente con la función de trigger
INSERT INTO clientes (id_cliente, nombre_completo, email, telefono, documento, tipo_cliente) VALUES
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'María González Pérez', 'maria.gonzalez@email.com', '+57 310 2345678', 'CC-52123456', 'nuevo'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Carlos Andrés Rodríguez', 'carlos.rodriguez@gmail.com', '+57 312 8765432', 'CC-1023456789', 'frecuente'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Ana Lucía Martínez', 'ana.martinez@hotmail.com', '+57 315 4567890', 'CC-1034567890', 'nuevo'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Juan Pablo Hernández', 'juan.hernandez@outlook.com', '+57 320 1234567', 'CC-79456123', 'VIP'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Laura Catalina López', 'laura.lopez@email.com', '+57 311 9876543', 'CC-52987654', 'frecuente'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Diego Fernando Ruiz', 'diego.ruiz@gmail.com', '+57 313 5678901', 'CC-1045678901', 'nuevo'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Valentina Torres Silva', 'valentina.torres@email.com', '+57 318 2345678', 'CC-1056789012', 'nuevo'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Santiago Ramírez Castro', 'santiago.ramirez@hotmail.com', '+57 314 8765432', 'CC-80123456', 'frecuente'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Camila Daniela Moreno', 'camila.moreno@gmail.com', '+57 316 4567890', 'CC-52456789', 'VIP'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Andrés Felipe Vargas', 'andres.vargas@email.com', '+57 319 1234567', 'CC-1067890123', 'nuevo'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Isabella Gómez Reyes', 'isabella.gomez@outlook.com', '+57 321 9876543', 'CC-52789012', 'frecuente'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Mateo Alejandro Cruz', 'mateo.cruz@gmail.com', '+57 322 5678901', 'CC-1078901234', 'nuevo'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Sofía Victoria Díaz', 'sofia.diaz@email.com', '+57 323 2345678', 'CC-52234567', 'VIP'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Sebastián Pardo Muñoz', 'sebastian.pardo@hotmail.com', '+57 324 8765432', 'CC-80987654', 'frecuente'),
(CONCAT('C-', LPAD(nextval('clientes_id_seq')::TEXT, 4, '0')), 'Mariana Ospina León', 'mariana.ospina@gmail.com', '+57 325 4567890', 'CC-1089012345', 'nuevo');

-- ============================================
-- RESERVAS DE PRUEBA
-- ============================================

-- Reservas Confirmadas
INSERT INTO reservas (id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio) VALUES
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0002', 'vuelo', 'Bogotá', 'Cartagena', '2025-12-15', '2025-12-20', 'confirmada', 380000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0003', 'paquete', 'Bogotá', 'San Andrés', '2025-11-28', '2025-12-05', 'confirmada', 1450000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0004', 'vuelo', 'Bogotá', 'Cancún, México', '2026-01-10', '2026-01-17', 'confirmada', 1850000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0005', 'paquete', 'Bogotá', 'Miami, USA', '2025-12-20', '2026-01-03', 'confirmada', 3200000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0006', 'vuelo', 'Bogotá', 'Madrid, España', '2026-02-14', '2026-02-28', 'confirmada', 2800000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0007', 'vuelo', 'Bogotá', 'Medellín', '2025-11-25', '2025-11-27', 'confirmada', 250000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0008', 'paquete', 'Bogotá', 'Buenos Aires, Argentina', '2026-03-05', '2026-03-15', 'confirmada', 2100000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0009', 'paquete', 'Bogotá', 'París, Francia', '2026-04-10', '2026-04-20', 'confirmada', 3500000);

-- Reservas Pendientes
INSERT INTO reservas (id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio) VALUES
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0010', 'paquete', 'Bogotá', 'Dubai, UAE', '2026-05-01', '2026-05-10', 'pendiente', 4200000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0011', 'vuelo', 'Medellín', 'Santa Marta', '2025-12-01', '2025-12-04', 'pendiente', 320000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0012', 'vuelo', 'Bogotá', 'Lima, Perú', '2025-12-18', '2025-12-22', 'pendiente', 680000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0013', 'paquete', 'Bogotá', 'Punta Cana, Rep. Dominicana', '2026-01-20', '2026-01-27', 'pendiente', 1950000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0014', 'vuelo', 'Cali', 'Eje Cafetero', '2025-11-30', '2025-12-03', 'pendiente', 280000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0015', 'paquete', 'Bogotá', 'Barcelona, España', '2026-06-15', '2026-06-25', 'pendiente', 3100000),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0016', 'paquete', 'Bogotá', 'Río de Janeiro, Brasil', '2026-02-20', '2026-03-02', 'pendiente', 1800000);

-- Reservas Canceladas
INSERT INTO reservas (id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio, notas) VALUES
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0003', 'vuelo', 'Bogotá', 'Cali', '2025-11-10', '2025-11-12', 'cancelada', 180000, 'Cliente canceló por motivos personales'),
(CONCAT('R-', LPAD(nextval('reservas_id_seq')::TEXT, 4, '0')), 'C-0006', 'paquete', 'Bogotá', 'Nueva York, USA', '2025-12-25', '2026-01-05', 'cancelada', 3800000, 'No obtuvo visa a tiempo');

-- ============================================
-- PAGOS DE PRUEBA
-- ============================================

-- Pagos completos para reservas confirmadas
INSERT INTO pagos (id_pago, id_reserva, monto, metodo, estado) VALUES
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0002', 380000, 'tarjeta', 'completado'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0003', 1450000, 'transferencia', 'completado'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0004', 1850000, 'tarjeta', 'completado'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0005', 3200000, 'efectivo', 'completado'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0006', 2800000, 'tarjeta', 'completado'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0007', 250000, 'transferencia', 'completado'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0008', 2100000, 'tarjeta', 'completado'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0009', 3500000, 'tarjeta', 'completado');

-- Pagos parciales (anticipos)
INSERT INTO pagos (id_pago, id_reserva, monto, metodo, estado) VALUES
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0010', 1500000, 'transferencia', 'pendiente'),
(CONCAT('P-', LPAD(nextval('pagos_id_seq')::TEXT, 4, '0')), 'R-0013', 800000, 'tarjeta', 'pendiente');

-- ============================================
-- RESUMEN Y VERIFICACIÓN
-- ============================================

-- Ver totales
SELECT 'CLIENTES' as tabla, COUNT(*) as total FROM clientes
UNION ALL
SELECT 'RESERVAS', COUNT(*) FROM reservas
UNION ALL
SELECT 'PAGOS', COUNT(*) FROM pagos;

-- Ver reservas por estado
SELECT estado, COUNT(*) as cantidad FROM reservas GROUP BY estado ORDER BY estado;

-- Ver clientes con más reservas
SELECT 
    c.id_cliente,
    c.nombre_completo,
    c.tipo_cliente,
    COUNT(r.id_reserva) as total_reservas,
    COALESCE(SUM(r.precio), 0) as valor_total_reservas
FROM clientes c
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.nombre_completo, c.tipo_cliente
HAVING COUNT(r.id_reserva) > 0
ORDER BY total_reservas DESC, valor_total_reservas DESC;

-- Ver próximos viajes confirmados
SELECT 
    c.nombre_completo,
    r.id_reserva,
    r.origen || ' → ' || r.destino as ruta,
    r.fecha_salida,
    r.fecha_regreso,
    r.precio,
    r.tipo
FROM reservas r
JOIN clientes c ON r.id_cliente = c.id_cliente
WHERE r.estado = 'confirmada'
AND r.fecha_salida >= CURRENT_DATE
ORDER BY r.fecha_salida;

-- Ver ingresos totales
SELECT 
    SUM(monto) as total_ingresos,
    COUNT(*) as total_pagos,
    AVG(monto) as promedio_pago
FROM pagos
WHERE estado = 'completado';
