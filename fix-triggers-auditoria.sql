-- =====================================================================
-- CORRECCIÓN DE TRIGGERS DE AUDITORÍA
-- Fecha: 2025-11-08
-- Problema: La función auditar_cambios() usa CASE con campos que no
--           existen en todas las tablas, causando errores en cascada
-- Solución: Crear funciones específicas por tabla
-- =====================================================================

-- 1. ELIMINAR FUNCIÓN PROBLEMÁTICA Y TRIGGERS EXISTENTES
-- =====================================================================

DROP TRIGGER IF EXISTS trigger_auditar_clientes ON clientes;
DROP TRIGGER IF EXISTS trigger_auditar_reservas ON reservas;
DROP TRIGGER IF EXISTS trigger_auditar_pagos ON pagos;
DROP FUNCTION IF EXISTS auditar_cambios();

RAISE NOTICE '✅ Triggers y función antigua eliminados';

-- 2. CREAR FUNCIONES ESPECÍFICAS POR TABLA
-- =====================================================================

-- Función para auditar CLIENTES
CREATE OR REPLACE FUNCTION auditar_clientes_cambios() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
        VALUES ('clientes', 'INSERT', NEW.id_cliente, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
        VALUES ('clientes', 'UPDATE', NEW.id_cliente, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
        VALUES ('clientes', 'DELETE', OLD.id_cliente, row_to_json(OLD)::jsonb, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

RAISE NOTICE '✅ Función auditar_clientes_cambios() creada';

-- Función para auditar RESERVAS
CREATE OR REPLACE FUNCTION auditar_reservas_cambios() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
        VALUES ('reservas', 'INSERT', NEW.id_reserva, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
        VALUES ('reservas', 'UPDATE', NEW.id_reserva, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
        VALUES ('reservas', 'DELETE', OLD.id_reserva, row_to_json(OLD)::jsonb, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

RAISE NOTICE '✅ Función auditar_reservas_cambios() creada';

-- Función para auditar PAGOS
CREATE OR REPLACE FUNCTION auditar_pagos_cambios() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
        VALUES ('pagos', 'INSERT', NEW.id_pago::VARCHAR, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
        VALUES ('pagos', 'UPDATE', NEW.id_pago::VARCHAR, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
        VALUES ('pagos', 'DELETE', OLD.id_pago::VARCHAR, row_to_json(OLD)::jsonb, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

RAISE NOTICE '✅ Función auditar_pagos_cambios() creada';

-- Función para auditar LEADS
CREATE OR REPLACE FUNCTION auditar_leads_cambios() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
        VALUES ('leads', 'INSERT', NEW.id_lead::VARCHAR, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
        VALUES ('leads', 'UPDATE', NEW.id_lead::VARCHAR, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
        RETURN NEW;
    
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
        VALUES ('leads', 'DELETE', OLD.id_lead::VARCHAR, row_to_json(OLD)::jsonb, current_user);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

RAISE NOTICE '✅ Función auditar_leads_cambios() creada';

-- 3. CREAR TRIGGERS ESPECÍFICOS
-- =====================================================================

-- Trigger para CLIENTES
CREATE TRIGGER trigger_auditar_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION auditar_clientes_cambios();

RAISE NOTICE '✅ Trigger para clientes creado';

-- Trigger para RESERVAS
CREATE TRIGGER trigger_auditar_reservas
AFTER INSERT OR UPDATE OR DELETE ON reservas
FOR EACH ROW EXECUTE FUNCTION auditar_reservas_cambios();

RAISE NOTICE '✅ Trigger para reservas creado';

-- Trigger para PAGOS
CREATE TRIGGER trigger_auditar_pagos
AFTER INSERT OR UPDATE OR DELETE ON pagos
FOR EACH ROW EXECUTE FUNCTION auditar_pagos_cambios();

RAISE NOTICE '✅ Trigger para pagos creado';

-- Trigger para LEADS
CREATE TRIGGER trigger_auditar_leads
AFTER INSERT OR UPDATE OR DELETE ON leads
FOR EACH ROW EXECUTE FUNCTION auditar_leads_cambios();

RAISE NOTICE '✅ Trigger para leads creado';

-- 4. VERIFICAR TRIGGERS CREADOS
-- =====================================================================

SELECT 
    trigger_name,
    event_object_table as tabla,
    action_timing as timing,
    event_manipulation as evento
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND trigger_name LIKE 'trigger_auditar%'
ORDER BY event_object_table, trigger_name;

RAISE NOTICE '✅ Triggers de auditoría corregidos exitosamente!';
