# Estructura de Base de Datos - Sistema de Gestión para Agencia de Viajes

Este documento describe el esquema completo de la base de datos PostgreSQL.

---

## Tabla: **clientes**

Almacena información de los clientes de la agencia.

| Columna           | Tipo       | Descripción                                    | Ejemplo          |
|-------------------|------------|------------------------------------------------|------------------|
| `id`              | SERIAL     | ID interno autoincremental (PK)                | 1                |
| `id_cliente`      | TEXT       | ID Cliente único (C-XXXX)                      | C-0001           |
| `nombre_completo` | TEXT       | Nombre completo                                | Ana Perez        |
| `email`           | TEXT       | Email                                          | ana@example.com  |
| `telefono`        | TEXT       | Teléfono                                       | +34123456789     |
| `documento`       | TEXT       | Documento (pasaporte/cédula)                   | X1234567         |
| `fecha_registro`  | DATE       | Fecha de registro                              | 2025-11-02       |
| `tipo_cliente`    | TEXT       | Tipo de cliente (nuevo/frecuente/VIP)          | nuevo            |

**Restricciones:**
- `id_cliente` es UNIQUE y NOT NULL.
- `nombre_completo` es NOT NULL.

---

## Tabla: **reservas**

Almacena las reservas de vuelos, hoteles o paquetes turísticos.

| Columna          | Tipo         | Descripción                                         | Ejemplo       |
|------------------|--------------|-----------------------------------------------------|---------------|
| `id`             | SERIAL       | ID interno autoincremental (PK)                     | 1             |
| `id_reserva`     | TEXT         | ID Reserva único (R-XXXX)                           | R-1001        |
| `id_cliente`     | TEXT         | ID Cliente (FK → clientes.id_cliente)               | C-0001        |
| `tipo`           | TEXT         | Tipo (vuelo/hotel/paquete)                          | vuelo         |
| `origen`         | TEXT         | Origen                                              | Madrid        |
| `destino`        | TEXT         | Destino                                             | Barcelona     |
| `fecha_salida`   | DATE         | Fecha salida                                        | 2025-11-10    |
| `fecha_regreso`  | DATE         | Fecha regreso                                       | 2025-11-15    |
| `estado`         | TEXT         | Estado (pendiente/confirmado/pagado/cancelado)      | confirmado    |
| `precio`         | NUMERIC(10,2)| Precio                                              | 450.00        |
| `notas`          | TEXT         | Notas adicionales                                   | Vuelo directo |

**Restricciones:**
- `id_reserva` es UNIQUE y NOT NULL.
- `id_cliente` es NOT NULL (FK a `clientes`).
- `estado` por defecto es `'pendiente'`.

---

## Tabla: **pagos**

Registra los pagos asociados a cada reserva.

| Columna      | Tipo         | Descripción                                      | Ejemplo      |
|--------------|--------------|--------------------------------------------------|--------------|
| `id`         | SERIAL       | ID interno autoincremental (PK)                  | 1            |
| `id_pago`    | TEXT         | ID Pago único (P-XXXX)                           | P-5001       |
| `id_reserva` | TEXT         | ID Reserva (FK → reservas.id_reserva)            | R-1001       |
| `monto`      | NUMERIC(10,2)| Monto                                            | 450.00       |
| `fecha`      | DATE         | Fecha del pago                                   | 2025-11-02   |
| `metodo`     | TEXT         | Método (efectivo/transferencia/tarjeta)          | tarjeta      |
| `estado`     | TEXT         | Estado (pendiente/completado)                    | completado   |

**Restricciones:**
- `id_pago` es UNIQUE y NOT NULL.
- `id_reserva` y `monto` son NOT NULL (FK a `reservas`).
- `estado` por defecto es `'pendiente'`.

---

## Relaciones

- **clientes → reservas**: Un cliente puede tener múltiples reservas (1:N).  
  - `reservas.id_cliente` → `clientes.id_cliente` (FK con CASCADE en DELETE)
- **reservas → pagos**: Una reserva puede tener múltiples pagos (1:N).  
  - `pagos.id_reserva` → `reservas.id_reserva` (FK con CASCADE en DELETE)

---

## Índices

Para mejorar el rendimiento de consultas frecuentes:
- `idx_clientes_email` en `clientes(email)`
- `idx_reservas_cliente` en `reservas(id_cliente)`
- `idx_reservas_fecha_salida` en `reservas(fecha_salida)` (útil para recordatorios)
- `idx_pagos_reserva` en `pagos(id_reserva)`

---

## Consultas de ejemplo

### Listar todos los clientes
```sql
SELECT id_cliente, nombre_completo, email, tipo_cliente
FROM clientes
ORDER BY fecha_registro DESC;
```

### Ver reservas de un cliente específico
```sql
SELECT r.id_reserva, r.tipo, r.origen, r.destino, r.fecha_salida, r.estado, r.precio
FROM reservas r
WHERE r.id_cliente = 'C-0001'
ORDER BY r.fecha_salida;
```

### Ver pagos de una reserva
```sql
SELECT p.id_pago, p.monto, p.fecha, p.metodo, p.estado
FROM pagos p
WHERE p.id_reserva = 'R-1001';
```

### Reservas próximas (en los próximos 2 días)
```sql
SELECT r.id_reserva, r.id_cliente, c.nombre_completo, c.email, r.destino, r.fecha_salida
FROM reservas r
JOIN clientes c ON r.id_cliente = c.id_cliente
WHERE r.fecha_salida BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '2 days'
  AND r.estado IN ('confirmado', 'pagado')
ORDER BY r.fecha_salida;
```

---

## Notas de implementación

- Las columnas con guiones bajos (`id_cliente`, `fecha_registro`) son el estándar en PostgreSQL.
- El archivo `db/init.sql` crea estas tablas automáticamente al levantar el contenedor por primera vez.
- Si necesitas re-inicializar la base, detén el contenedor y borra la carpeta `db/data` antes de ejecutar `docker-compose up -d`.
