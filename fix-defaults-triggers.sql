-- =====================================================
-- SCRIPT: Configurar DEFAULT y Triggers para IDs
-- =====================================================

-- 1. Establecer DEFAULT vacío para id_cliente
ALTER TABLE clientes ALTER COLUMN id_cliente SET DEFAULT '';

-- 2. Establecer DEFAULT vacío para id_reserva
ALTER TABLE reservas ALTER COLUMN id_reserva SET DEFAULT '';

-- 3. Establecer DEFAULT vacío para id_pago (si aplica)
ALTER TABLE pagos ALTER COLUMN id_pago SET DEFAULT '';

-- 4. Verificar que el trigger de id_cliente exista
SELECT 'TRIGGER id_cliente:' as info, trigger_name, event_manipulation, event_object_table 
FROM information_schema.triggers 
WHERE event_object_schema = 'public' 
AND event_object_table = 'clientes'
AND trigger_name LIKE '%id_cliente%';

-- 5. Crear función para generar id_reserva
CREATE OR REPLACE FUNCTION generate_id_reserva()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.id_reserva IS NULL OR NEW.id_reserva = '' THEN
    NEW.id_reserva := 'R-' || LPAD(
      (SELECT COALESCE(MAX(CAST(SUBSTRING(id_reserva FROM 3) AS INTEGER)), 0) + 1 
       FROM reservas WHERE id_reserva ~ '^R-[0-9]+$')::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Crear trigger para id_reserva
DROP TRIGGER IF EXISTS trigger_generate_id_reserva ON reservas;
CREATE TRIGGER trigger_generate_id_reserva
BEFORE INSERT ON reservas
FOR EACH ROW
EXECUTE FUNCTION generate_id_reserva();

-- 7. Crear función para generar id_pago
CREATE OR REPLACE FUNCTION generate_id_pago()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.id_pago IS NULL OR NEW.id_pago = '' THEN
    NEW.id_pago := 'P-' || LPAD(
      (SELECT COALESCE(MAX(CAST(SUBSTRING(id_pago FROM 3) AS INTEGER)), 0) + 1 
       FROM pagos WHERE id_pago ~ '^P-[0-9]+$')::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Crear trigger para id_pago
DROP TRIGGER IF EXISTS trigger_generate_id_pago ON pagos;
CREATE TRIGGER trigger_generate_id_pago
BEFORE INSERT ON pagos
FOR EACH ROW
EXECUTE FUNCTION generate_id_pago();

-- 9. Verificar todos los triggers
SELECT 'TODOS LOS TRIGGERS:' as info;
SELECT trigger_name, event_manipulation, event_object_table 
FROM information_schema.triggers 
WHERE event_object_schema = 'public' 
AND event_object_table IN ('clientes', 'reservas', 'pagos')
ORDER BY event_object_table, trigger_name;

-- 10. Verificar estructura de columnas
SELECT 'ESTRUCTURA COLUMNAS:' as info;
SELECT table_name, column_name, column_default, is_nullable, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('clientes', 'reservas', 'pagos')
AND column_name LIKE 'id_%'
ORDER BY table_name, column_name;
