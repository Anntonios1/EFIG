-- Verificar triggers
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE event_object_schema = 'public' 
AND event_object_table IN ('clientes', 'reservas', 'pagos') 
ORDER BY event_object_table;

-- Verificar DEFAULT values
SELECT table_name, column_name, column_default 
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('clientes', 'reservas', 'pagos')
AND column_name LIKE 'id_%'
ORDER BY table_name, column_name;
