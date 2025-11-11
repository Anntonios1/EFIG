-- Función para generar id_cliente automáticamente con formato C-XXXX
CREATE OR REPLACE FUNCTION generate_id_cliente()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_cliente IS NULL OR NEW.id_cliente = '' THEN
        NEW.id_cliente := 'C-' || LPAD(
            (SELECT COALESCE(MAX(CAST(SUBSTRING(id_cliente FROM 3) AS INTEGER)), 0) + 1 
             FROM clientes 
             WHERE id_cliente ~ '^C-[0-9]+$')::TEXT, 
            4, '0'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger que se ejecuta BEFORE INSERT
DROP TRIGGER IF EXISTS trigger_generate_id_cliente ON clientes;
CREATE TRIGGER trigger_generate_id_cliente
    BEFORE INSERT ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION generate_id_cliente();

-- Verificar que funciona
SELECT 'Trigger creado correctamente' as status;
