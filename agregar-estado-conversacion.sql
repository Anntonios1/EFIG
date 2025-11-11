-- =====================================================================
-- ACTUALIZACIÓN: Agregar control de estado de conversación
-- Fecha: 2025-11-06
-- Propósito: Permitir que el chatbot rastree en qué parte del flujo
--            se encuentra cada cliente
-- =====================================================================

-- Verificar si la columna ya existe (opcional, para seguridad)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'clientes' 
        AND column_name = 'estado_conversacion'
    ) THEN
        -- Agregar columna estado_conversacion
        ALTER TABLE clientes
        ADD COLUMN estado_conversacion TEXT DEFAULT 'nuevo_usuario';
        
        RAISE NOTICE 'Columna estado_conversacion agregada exitosamente';
    ELSE
        RAISE NOTICE 'La columna estado_conversacion ya existe';
    END IF;
END $$;

-- Crear índice para mejorar rendimiento en consultas por estado
CREATE INDEX IF NOT EXISTS idx_clientes_estado_conversacion 
ON clientes(estado_conversacion);

-- Comentario descriptivo de la columna
COMMENT ON COLUMN clientes.estado_conversacion IS 
'Estado actual del flujo de conversación: nuevo_usuario, menu_mostrado, viendo_reservas, viendo_perfil, buscando_vuelos, explorando_destinos, esperando_confirmacion';

-- =====================================================================
-- VALORES POSIBLES PARA estado_conversacion:
-- =====================================================================
-- 'nuevo_usuario'            - Primera interacción, mostrar bienvenida
-- 'menu_mostrado'            - Menú principal desplegado, esperando selección
-- 'viendo_reservas'          - Usuario consultando sus reservas
-- 'viendo_perfil'            - Usuario revisando su información personal
-- 'buscando_vuelos'          - Proceso de búsqueda de vuelos activo
-- 'explorando_destinos'      - Navegando catálogo de destinos
-- 'esperando_confirmacion'   - Esperando confirmación para proceder con reserva
-- =====================================================================

-- Verificación final
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes' 
AND column_name = 'estado_conversacion';
