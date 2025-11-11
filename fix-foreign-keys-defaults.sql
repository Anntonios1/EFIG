-- Configurar DEFAULT para campos foráneos que también son NOT NULL
ALTER TABLE reservas ALTER COLUMN id_cliente SET DEFAULT '';
ALTER TABLE pagos ALTER COLUMN id_reserva SET DEFAULT '';

-- Verificar que se aplicaron
SELECT 
    table_name,
    column_name,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('clientes', 'reservas', 'pagos')
AND (column_name LIKE 'id_%' OR column_name = 'id' OR column_name = 'telegram_id')
ORDER BY table_name, ordinal_position;
