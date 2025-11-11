-- Agregar columnas necesarias para el sistema role-based

-- 1. Agregar columna telegram_id a clientes (para identificación de usuarios de Telegram)
ALTER TABLE clientes 
ADD COLUMN IF NOT EXISTS telegram_id BIGINT UNIQUE;

-- 2. Crear índice para búsquedas rápidas por telegram_id
CREATE INDEX IF NOT EXISTS idx_clientes_telegram_id ON clientes(telegram_id);

-- 3. Crear tabla chat_history para memoria del AI Agent
CREATE TABLE IF NOT EXISTS chat_history (
    id SERIAL PRIMARY KEY,
    session_id TEXT NOT NULL,
    type TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Crear índice para búsquedas por session_id
CREATE INDEX IF NOT EXISTS idx_chat_history_session ON chat_history(session_id);

-- 5. Actualizar un cliente existente como admin para pruebas (opcional)
-- Reemplaza 'C-0001' con el id_cliente que quieras hacer admin
UPDATE clientes 
SET tipo_cliente = 'admin' 
WHERE id_cliente = 'C-0001';

-- Verificar cambios
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'clientes' 
ORDER BY ordinal_position;

SELECT * FROM clientes LIMIT 3;
