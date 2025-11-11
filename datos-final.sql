-- Script con IDs correctos basado en los clientes existentes
-- EFIG Vuelos & Travel

-- ============================================
-- RESERVAS con IDs de clientes reales
-- ============================================

-- Reservas Confirmadas
INSERT INTO reservas (id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio) VALUES
('R-0002', 'C-0003', 'vuelo', 'Bogotá', 'Cartagena', '2025-12-15', '2025-12-20', 'confirmada', 380000),
('R-0003', 'C-0005', 'paquete', 'Bogotá', 'San Andrés', '2025-11-28', '2025-12-05', 'confirmada', 1450000),
('R-0004', 'C-0007', 'vuelo', 'Bogotá', 'Cancún, México', '2026-01-10', '2026-01-17', 'confirmada', 1850000),
('R-0005', 'C-0009', 'paquete', 'Bogotá', 'Miami, USA', '2025-12-20', '2026-01-03', 'confirmada', 3200000),
('R-0006', 'C-0011', 'vuelo', 'Bogotá', 'Madrid, España', '2026-02-14', '2026-02-28', 'confirmada', 2800000),
('R-0007', 'C-0013', 'vuelo', 'Bogotá', 'Medellín', '2025-11-25', '2025-11-27', 'confirmada', 250000),
('R-0008', 'C-0015', 'paquete', 'Bogotá', 'Buenos Aires, Argentina', '2026-03-05', '2026-03-15', 'confirmada', 2100000),
('R-0009', 'C-0017', 'paquete', 'Bogotá', 'París, Francia', '2026-04-10', '2026-04-20', 'confirmada', 3500000);

-- Reservas Pendientes
INSERT INTO reservas (id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio) VALUES
('R-0010', 'C-0019', 'paquete', 'Bogotá', 'Dubai, UAE', '2026-05-01', '2026-05-10', 'pendiente', 4200000),
('R-0011', 'C-0021', 'vuelo', 'Medellín', 'Santa Marta', '2025-12-01', '2025-12-04', 'pendiente', 320000),
('R-0012', 'C-0023', 'vuelo', 'Bogotá', 'Lima, Perú', '2025-12-18', '2025-12-22', 'pendiente', 680000),
('R-0013', 'C-0025', 'paquete', 'Bogotá', 'Punta Cana, Rep. Dominicana', '2026-01-20', '2026-01-27', 'pendiente', 1950000),
('R-0014', 'C-0027', 'vuelo', 'Cali', 'Eje Cafetero', '2025-11-30', '2025-12-03', 'pendiente', 280000),
('R-0015', 'C-0029', 'paquete', 'Bogotá', 'Barcelona, España', '2026-06-15', '2026-06-25', 'pendiente', 3100000),
('R-0016', 'C-0031', 'paquete', 'Bogotá', 'Río de Janeiro, Brasil', '2026-02-20', '2026-03-02', 'pendiente', 1800000);

-- Reservas Canceladas
INSERT INTO reservas (id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio, notas) VALUES
('R-0017', 'C-0005', 'vuelo', 'Bogotá', 'Cali', '2025-11-10', '2025-11-12', 'cancelada', 180000, 'Cliente canceló por motivos personales'),
('R-0018', 'C-0011', 'paquete', 'Bogotá', 'Nueva York, USA', '2025-12-25', '2026-01-05', 'cancelada', 3800000, 'No obtuvo visa a tiempo');

-- ============================================
-- PAGOS para reservas confirmadas
-- ============================================

INSERT INTO pagos (id_pago, id_reserva, monto, metodo, estado) VALUES
('P-0002', 'R-0002', 380000, 'tarjeta', 'completado'),
('P-0003', 'R-0003', 1450000, 'transferencia', 'completado'),
('P-0004', 'R-0004', 1850000, 'tarjeta', 'completado'),
('P-0005', 'R-0005', 3200000, 'efectivo', 'completado'),
('P-0006', 'R-0006', 2800000, 'tarjeta', 'completado'),
('P-0007', 'R-0007', 250000, 'transferencia', 'completado'),
('P-0008', 'R-0008', 2100000, 'tarjeta', 'completado'),
('P-0009', 'R-0009', 3500000, 'tarjeta', 'completado');

-- Pagos parciales (anticipos)
INSERT INTO pagos (id_pago, id_reserva, monto, metodo, estado) VALUES
('P-0010', 'R-0010', 1500000, 'transferencia', 'pendiente'),
('P-0011', 'R-0013', 800000, 'tarjeta', 'pendiente');

-- ============================================
-- VERIFICACIÓN Y ESTADÍSTICAS
-- ============================================

SELECT '📊 RESUMEN GENERAL' as seccion;
SELECT 'Total Clientes' as metrica, COUNT(*)::TEXT as valor FROM clientes
UNION ALL
SELECT 'Total Reservas', COUNT(*)::TEXT FROM reservas
UNION ALL
SELECT 'Total Pagos', COUNT(*)::TEXT FROM pagos;

SELECT '✈️ RESERVAS POR ESTADO' as seccion;
SELECT estado, COUNT(*) as cantidad, TO_CHAR(SUM(precio), 'FM$999,999,999') as valor_total
FROM reservas
GROUP BY estado
ORDER BY estado;

SELECT '🏆 TOP CLIENTES' as seccion;
SELECT 
    c.id_cliente,
    c.nombre_completo,
    c.tipo_cliente,
    COUNT(r.id_reserva) as reservas,
    TO_CHAR(COALESCE(SUM(r.precio), 0), 'FM$999,999,999') as valor_total
FROM clientes c
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.nombre_completo, c.tipo_cliente
HAVING COUNT(r.id_reserva) > 0
ORDER BY COUNT(r.id_reserva) DESC, SUM(r.precio) DESC
LIMIT 5;

SELECT '📅 PRÓXIMOS VIAJES' as seccion;
SELECT 
    c.nombre_completo as cliente,
    r.id_reserva,
    r.destino,
    TO_CHAR(r.fecha_salida, 'DD/MM/YYYY') as salida,
    TO_CHAR(r.fecha_regreso, 'DD/MM/YYYY') as regreso,
    TO_CHAR(r.precio, 'FM$999,999,999') as precio
FROM reservas r
JOIN clientes c ON r.id_cliente = c.id_cliente
WHERE r.estado = 'confirmada'
AND r.fecha_salida >= CURRENT_DATE
ORDER BY r.fecha_salida
LIMIT 5;

SELECT '💰 INGRESOS' as seccion;
SELECT 
    TO_CHAR(SUM(monto), 'FM$999,999,999') as total_ingresos,
    COUNT(*) as total_pagos,
    TO_CHAR(AVG(monto), 'FM$999,999,999') as promedio_pago
FROM pagos
WHERE estado = 'completado';

SELECT '🌎 DESTINOS MÁS POPULARES' as seccion;
SELECT destino, COUNT(*) as cantidad_reservas
FROM reservas
WHERE estado IN ('confirmada', 'pendiente')
GROUP BY destino
ORDER BY COUNT(*) DESC
LIMIT 5;
