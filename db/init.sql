-- Inicialización de la base de datos para Sistema de Agencia de Viajes
-- Esquema alineado con la especificación del usuario

-- Tabla: Clientes
CREATE TABLE IF NOT EXISTS clientes (
  id SERIAL PRIMARY KEY,
  id_cliente TEXT UNIQUE NOT NULL,           -- ID Cliente
  nombre_completo TEXT NOT NULL,             -- Nombre completo
  email TEXT,                                 -- Email
  telefono TEXT,                              -- Teléfono
  documento TEXT,                             -- Documento (pasaporte/cédula)
  fecha_registro DATE DEFAULT CURRENT_DATE,  -- Fecha de registro
  tipo_cliente TEXT DEFAULT 'nuevo'          -- Tipo de cliente (nuevo/frecuente/VIP)
);

-- Tabla: Reservas
CREATE TABLE IF NOT EXISTS reservas (
  id SERIAL PRIMARY KEY,
  id_reserva TEXT UNIQUE NOT NULL,           -- ID Reserva
  id_cliente TEXT NOT NULL,                  -- ID Cliente (relación)
  tipo TEXT DEFAULT 'vuelo',                 -- Tipo (vuelo/hotel/paquete)
  origen TEXT,                                -- Origen
  destino TEXT,                               -- Destino
  fecha_salida DATE,                          -- Fecha salida
  fecha_regreso DATE,                         -- Fecha regreso
  estado TEXT DEFAULT 'pendiente',           -- Estado (pendiente/confirmado/pagado/cancelado)
  precio NUMERIC(10,2),                      -- Precio
  notas TEXT,                                 -- Notas
  CONSTRAINT fk_cliente
    FOREIGN KEY(id_cliente)
      REFERENCES clientes(id_cliente)
      ON DELETE CASCADE
);

-- Tabla: Pagos
CREATE TABLE IF NOT EXISTS pagos (
  id SERIAL PRIMARY KEY,
  id_pago TEXT UNIQUE NOT NULL,              -- ID Pago
  id_reserva TEXT NOT NULL,                  -- ID Reserva
  monto NUMERIC(10,2) NOT NULL,              -- Monto
  fecha DATE DEFAULT CURRENT_DATE,           -- Fecha
  metodo TEXT,                                -- Método (efectivo/transferencia/tarjeta)
  estado TEXT DEFAULT 'pendiente',           -- Estado (pendiente/completado)
  CONSTRAINT fk_reserva
    FOREIGN KEY(id_reserva)
      REFERENCES reservas(id_reserva)
      ON DELETE CASCADE
);

-- Índices para mejorar rendimiento en consultas frecuentes
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);
CREATE INDEX IF NOT EXISTS idx_reservas_cliente ON reservas(id_cliente);
CREATE INDEX IF NOT EXISTS idx_reservas_fecha_salida ON reservas(fecha_salida);
CREATE INDEX IF NOT EXISTS idx_pagos_reserva ON pagos(id_reserva);

-- Datos de ejemplo
INSERT INTO clientes (id_cliente, nombre_completo, email, telefono, documento, fecha_registro, tipo_cliente)
VALUES ('C-0001', 'Ana Perez', 'ana@example.com', '+34123456789', 'X1234567', CURRENT_DATE, 'nuevo')
ON CONFLICT (id_cliente) DO NOTHING;
