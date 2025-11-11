-- Script para llenar la base de datos con datos de prueba
-- EFIG Vuelos & Travel

-- ============================================
-- CLIENTES DE PRUEBA
-- ============================================

INSERT INTO clientes (nombre_completo, email, telefono) VALUES
('María González Pérez', 'maria.gonzalez@email.com', '+57 310 2345678'),
('Carlos Andrés Rodríguez', 'carlos.rodriguez@gmail.com', '+57 312 8765432'),
('Ana Lucía Martínez', 'ana.martinez@hotmail.com', '+57 315 4567890'),
('Juan Pablo Hernández', 'juan.hernandez@outlook.com', '+57 320 1234567'),
('Laura Catalina López', 'laura.lopez@email.com', '+57 311 9876543'),
('Diego Fernando Ruiz', 'diego.ruiz@gmail.com', '+57 313 5678901'),
('Valentina Torres Silva', 'valentina.torres@email.com', '+57 318 2345678'),
('Santiago Ramírez Castro', 'santiago.ramirez@hotmail.com', '+57 314 8765432'),
('Camila Daniela Moreno', 'camila.moreno@gmail.com', '+57 316 4567890'),
('Andrés Felipe Vargas', 'andres.vargas@email.com', '+57 319 1234567'),
('Isabella Gómez Reyes', 'isabella.gomez@outlook.com', '+57 321 9876543'),
('Mateo Alejandro Cruz', 'mateo.cruz@gmail.com', '+57 322 5678901'),
('Sofía Victoria Díaz', 'sofia.diaz@email.com', '+57 323 2345678'),
('Sebastián Pardo Muñoz', 'sebastian.pardo@hotmail.com', '+57 324 8765432'),
('Mariana Ospina León', 'mariana.ospina@gmail.com', '+57 325 4567890');

-- ============================================
-- RESERVAS DE PRUEBA
-- ============================================

-- Reservas Confirmadas (con pago)
INSERT INTO reservas (id_cliente, destino, fecha_salida, fecha_regreso, estado) VALUES
('C-0001', 'Cartagena', '2025-12-15', '2025-12-20', 'confirmada'),
('C-0002', 'San Andrés', '2025-11-28', '2025-12-05', 'confirmada'),
('C-0003', 'Cancún, México', '2026-01-10', '2026-01-17', 'confirmada'),
('C-0004', 'Miami, USA', '2025-12-20', '2026-01-03', 'confirmada'),
('C-0005', 'Madrid, España', '2026-02-14', '2026-02-28', 'confirmada'),
('C-0006', 'Medellín', '2025-11-25', '2025-11-27', 'confirmada'),
('C-0007', 'Buenos Aires, Argentina', '2026-03-05', '2026-03-15', 'confirmada'),
('C-0008', 'París, Francia', '2026-04-10', '2026-04-20', 'confirmada');

-- Reservas Pendientes de Pago
INSERT INTO reservas (id_cliente, destino, fecha_salida, fecha_regreso, estado) VALUES
('C-0009', 'Dubai, UAE', '2026-05-01', '2026-05-10', 'pendiente'),
('C-0010', 'Santa Marta', '2025-12-01', '2025-12-04', 'pendiente'),
('C-0011', 'Lima, Perú', '2025-12-18', '2025-12-22', 'pendiente'),
('C-0012', 'Punta Cana, Rep. Dominicana', '2026-01-20', '2026-01-27', 'pendiente'),
('C-0013', 'Eje Cafetero', '2025-11-30', '2025-12-03', 'pendiente'),
('C-0014', 'Barcelona, España', '2026-06-15', '2026-06-25', 'pendiente'),
('C-0015', 'Río de Janeiro, Brasil', '2026-02-20', '2026-03-02', 'pendiente');

-- Reservas Canceladas
INSERT INTO reservas (id_cliente, destino, fecha_salida, fecha_regreso, estado) VALUES
('C-0002', 'Cali', '2025-11-10', '2025-11-12', 'cancelada'),
('C-0005', 'Nueva York, USA', '2025-12-25', '2026-01-05', 'cancelada');

-- ============================================
-- PAGOS DE PRUEBA
-- ============================================

-- Pagos para reservas confirmadas
INSERT INTO pagos (id_reserva, monto, metodo_pago) VALUES
('R-0001', 450000, 'tarjeta'),
('R-0002', 620000, 'transferencia'),
('R-0003', 1450000, 'tarjeta'),
('R-0004', 1850000, 'efectivo'),
('R-0005', 2200000, 'tarjeta'),
('R-0006', 280000, 'transferencia'),
('R-0007', 1600000, 'tarjeta'),
('R-0008', 2400000, 'tarjeta');

-- Pagos parciales (anticipo)
INSERT INTO pagos (id_reserva, monto, metodo_pago) VALUES
('R-0009', 1000000, 'transferencia'), -- Dubai (anticipo, pendiente saldo)
('R-0012', 500000, 'tarjeta'); -- Punta Cana (anticipo, pendiente saldo)

-- ============================================
-- VERIFICACIÓN DE DATOS
-- ============================================

-- Ver resumen de clientes
SELECT 
    'CLIENTES' as tabla,
    COUNT(*) as total
FROM clientes
UNION ALL
SELECT 
    'RESERVAS' as tabla,
    COUNT(*) as total
FROM reservas
UNION ALL
SELECT 
    'PAGOS' as tabla,
    COUNT(*) as total
FROM pagos;

-- Ver resumen por estado de reservas
SELECT 
    estado,
    COUNT(*) as cantidad,
    STRING_AGG(DISTINCT destino, ', ') as destinos
FROM reservas
GROUP BY estado
ORDER BY estado;

-- Ver top clientes con más reservas
SELECT 
    c.id_cliente,
    c.nombre_completo,
    COUNT(r.id_reserva) as total_reservas,
    SUM(COALESCE(p.monto, 0)) as total_pagado
FROM clientes c
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
GROUP BY c.id_cliente, c.nombre_completo
ORDER BY total_reservas DESC, total_pagado DESC
LIMIT 10;

-- Ver próximos viajes (reservas confirmadas)
SELECT 
    c.nombre_completo,
    r.id_reserva,
    r.destino,
    r.fecha_salida,
    r.fecha_regreso,
    r.estado,
    COALESCE(p.monto, 0) as monto_pagado
FROM reservas r
JOIN clientes c ON r.id_cliente = c.id_cliente
LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
WHERE r.estado = 'confirmada'
AND r.fecha_salida >= CURRENT_DATE
ORDER BY r.fecha_salida;

-- Ver reservas pendientes de pago
SELECT 
    c.nombre_completo,
    c.telefono,
    r.id_reserva,
    r.destino,
    r.fecha_salida,
    COALESCE(p.monto, 0) as anticipo_pagado
FROM reservas r
JOIN clientes c ON r.id_cliente = c.id_cliente
LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
WHERE r.estado = 'pendiente'
ORDER BY r.fecha_salida;

-- Ver estadísticas generales
SELECT 
    'Total Clientes Registrados' as metrica,
    COUNT(*)::TEXT as valor
FROM clientes
UNION ALL
SELECT 
    'Total Reservas Activas' as metrica,
    COUNT(*)::TEXT as valor
FROM reservas
WHERE estado IN ('confirmada', 'pendiente')
UNION ALL
SELECT 
    'Total Ingresos Confirmados' as metrica,
    TO_CHAR(SUM(monto), 'FM$999,999,999') as valor
FROM pagos
UNION ALL
SELECT 
    'Destino Más Popular' as metrica,
    destino as valor
FROM reservas
GROUP BY destino
ORDER BY COUNT(*) DESC
LIMIT 1;
