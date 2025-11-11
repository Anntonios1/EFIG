-- Listar todas las tablas
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Ver estructura de tabla memory si existe
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'memory'
ORDER BY ordinal_position;

-- Ver estructura de tabla chat_history si existe
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'chat_history'
ORDER BY ordinal_position;
