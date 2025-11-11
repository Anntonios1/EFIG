-- Test de INSERT directo
INSERT INTO clientes (nombre_completo, email, telefono, tipo_cliente)
VALUES ('Test Directo PostgreSQL', 'test@directo.com', '300-0000000', 'nuevo')
RETURNING id_cliente, nombre_completo, email;
