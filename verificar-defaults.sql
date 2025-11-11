-- Verificar que los DEFAULT se aplicaron correctamente
SELECT 
    table_name,
    column_name,
    column_default,
    is_nullable,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('clientes', 'reservas', 'pagos')
AND (column_name LIKE 'id_%' OR column_name = 'id' OR column_name = 'telegram_id')
ORDER BY table_name, ordinal_position;
