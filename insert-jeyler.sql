-- Registrar Jeyler Antonio Martinez Grueso
INSERT INTO clientes (nombre_completo, email, telefono, documento, tipo_cliente)
VALUES ('Jeyler Antonio Martinez Grueso', 'teampiki115@gmail.com', '3218474189', '1002822113', 'admin')
RETURNING id, id_cliente, nombre_completo, email, telefono, documento, tipo_cliente, fecha_registro;
