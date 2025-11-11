-- Función para generar id_reserva
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

-- Trigger para id_reserva
DROP TRIGGER IF EXISTS trigger_generate_id_reserva ON reservas;
CREATE TRIGGER trigger_generate_id_reserva
BEFORE INSERT ON reservas
FOR EACH ROW
EXECUTE FUNCTION generate_id_reserva();

-- Función para generar id_pago
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

-- Trigger para id_pago
DROP TRIGGER IF EXISTS trigger_generate_id_pago ON pagos;
CREATE TRIGGER trigger_generate_id_pago
BEFORE INSERT ON pagos
FOR EACH ROW
EXECUTE FUNCTION generate_id_pago();
