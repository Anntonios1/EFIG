-- ================================================================
-- EFIG TRAVEL AGENCY - DATABASE UPGRADE SCRIPT
-- Versión: 2.0
-- Fecha: 2025-11-06
-- Descripción: Mejoras empresariales para sistema de gestión de viajes
-- ================================================================

-- ================================================================
-- PASO 1: CREAR TABLA DE AUDITORÍA
-- ================================================================

CREATE TABLE IF NOT EXISTS auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    tabla VARCHAR(50) NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    id_registro VARCHAR(20) NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    fecha_hora TIMESTAMP DEFAULT NOW(),
    razon TEXT
);

CREATE INDEX IF NOT EXISTS idx_auditoria_tabla ON auditoria(tabla);
CREATE INDEX IF NOT EXISTS idx_auditoria_fecha ON auditoria(fecha_hora DESC);
CREATE INDEX IF NOT EXISTS idx_auditoria_usuario ON auditoria(usuario);

-- ================================================================
-- PASO 2: MEJORAR TABLA CLIENTES (Agregar campos)
-- ================================================================

ALTER TABLE clientes ADD COLUMN IF NOT EXISTS ultimo_contacto TIMESTAMP;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS canal_preferido VARCHAR(20);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS telegram_id VARCHAR(50);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS whatsapp VARCHAR(20);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS idioma VARCHAR(5) DEFAULT 'es';
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS pais VARCHAR(50);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS ciudad VARCHAR(100);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS fecha_nacimiento DATE;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS genero VARCHAR(20);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS preferencias JSONB;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS nps_score INT;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS total_gastado DECIMAL(12,2) DEFAULT 0;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS num_viajes INT DEFAULT 0;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT true;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS notas TEXT;

-- ================================================================
-- PASO 3: MEJORAR TABLA RESERVAS (Agregar campos)
-- ================================================================

ALTER TABLE reservas ADD COLUMN IF NOT EXISTS aerolinea VARCHAR(100);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS numero_vuelo VARCHAR(20);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS hotel_nombre VARCHAR(200);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS hotel_direccion TEXT;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS num_adultos INT DEFAULT 1;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS num_ninos INT DEFAULT 0;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS num_bebes INT DEFAULT 0;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS clase VARCHAR(20);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS equipaje VARCHAR(50);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS seguro_viaje BOOLEAN DEFAULT false;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS monto_seguro DECIMAL(10,2);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS codigo_reserva_externo VARCHAR(50);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS fecha_limite_pago TIMESTAMP;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS cancelable BOOLEAN DEFAULT true;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS penalidad_cancelacion DECIMAL(10,2);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT NOW();
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS fecha_actualizacion TIMESTAMP DEFAULT NOW();
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS creado_por VARCHAR(100);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS metadata JSONB;

-- ================================================================
-- PASO 4: MEJORAR TABLA PAGOS (Agregar campos)
-- ================================================================

ALTER TABLE pagos ADD COLUMN IF NOT EXISTS referencia_transaccion VARCHAR(100);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS banco VARCHAR(100);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS ultimos_4_digitos VARCHAR(4);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS tipo_tarjeta VARCHAR(20);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS cuotas INT DEFAULT 1;
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS moneda VARCHAR(3) DEFAULT 'USD';
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS tasa_cambio DECIMAL(10,4);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS comision DECIMAL(10,2) DEFAULT 0;
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS neto DECIMAL(10,2);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS comprobante_url TEXT;
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS ip_address INET;
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS metadata JSONB;

-- ================================================================
-- PASO 5: CREAR TABLA CONVERSACIONES
-- ================================================================

CREATE TABLE IF NOT EXISTS conversaciones (
    id_conversacion SERIAL PRIMARY KEY,
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    canal VARCHAR(20) NOT NULL,
    chat_id VARCHAR(100),
    mensaje TEXT NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    metadata JSONB,
    sentimiento VARCHAR(20),
    intencion VARCHAR(50),
    agente VARCHAR(100),
    es_bot BOOLEAN DEFAULT true,
    fecha_hora TIMESTAMP DEFAULT NOW(),
    leido BOOLEAN DEFAULT false,
    respondido BOOLEAN DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_conversaciones_cliente ON conversaciones(id_cliente);
CREATE INDEX IF NOT EXISTS idx_conversaciones_canal ON conversaciones(canal);
CREATE INDEX IF NOT EXISTS idx_conversaciones_fecha ON conversaciones(fecha_hora DESC);
CREATE INDEX IF NOT EXISTS idx_conversaciones_no_respondido ON conversaciones(respondido) WHERE respondido = false;

-- ================================================================
-- PASO 6: CREAR TABLA LEADS
-- ================================================================

CREATE TABLE IF NOT EXISTS leads (
    id_lead SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    destino_interes VARCHAR(100),
    fecha_viaje_estimada DATE,
    presupuesto DECIMAL(10,2),
    tipo_viaje VARCHAR(50),
    num_personas INT DEFAULT 1,
    fuente VARCHAR(50),
    utm_source VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_medium VARCHAR(100),
    score INT DEFAULT 0,
    clasificacion VARCHAR(10),
    estado VARCHAR(20) DEFAULT 'nuevo',
    contactado BOOLEAN DEFAULT false,
    fecha_primer_contacto TIMESTAMP,
    fecha_ultimo_seguimiento TIMESTAMP,
    num_seguimientos INT DEFAULT 0,
    agente_asignado VARCHAR(100),
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    id_reserva VARCHAR(20),
    fecha_conversion TIMESTAMP,
    motivo_perdida TEXT,
    notas TEXT,
    metadata JSONB,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_telefono ON leads(telefono);
CREATE INDEX IF NOT EXISTS idx_leads_estado ON leads(estado);
CREATE INDEX IF NOT EXISTS idx_leads_clasificacion ON leads(clasificacion);
CREATE INDEX IF NOT EXISTS idx_leads_score ON leads(score DESC);
CREATE INDEX IF NOT EXISTS idx_leads_agente ON leads(agente_asignado);
CREATE INDEX IF NOT EXISTS idx_leads_no_contactado ON leads(contactado) WHERE contactado = false;

-- ================================================================
-- PASO 7: CREAR TABLA NOTIFICACIONES
-- ================================================================

CREATE TABLE IF NOT EXISTS notificaciones (
    id_notificacion SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    id_reserva VARCHAR(20),
    id_lead INT REFERENCES leads(id_lead),
    canal VARCHAR(20) NOT NULL,
    destinatario VARCHAR(200) NOT NULL,
    asunto VARCHAR(200),
    mensaje TEXT NOT NULL,
    programada_para TIMESTAMP NOT NULL,
    enviada BOOLEAN DEFAULT false,
    fecha_envio TIMESTAMP,
    entregada BOOLEAN DEFAULT false,
    leida BOOLEAN DEFAULT false,
    respuesta_recibida BOOLEAN DEFAULT false,
    error TEXT,
    intentos INT DEFAULT 0,
    max_intentos INT DEFAULT 3,
    prioridad INT DEFAULT 1,
    metadata JSONB,
    fecha_creacion TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notificaciones_programadas ON notificaciones(programada_para) WHERE enviada = false;
CREATE INDEX IF NOT EXISTS idx_notificaciones_cliente ON notificaciones(id_cliente);
CREATE INDEX IF NOT EXISTS idx_notificaciones_tipo ON notificaciones(tipo);
CREATE INDEX IF NOT EXISTS idx_notificaciones_prioridad ON notificaciones(prioridad DESC);

-- ================================================================
-- PASO 8: CREAR TABLA PROMOCIONES
-- ================================================================

CREATE TABLE IF NOT EXISTS promociones (
    id_promocion SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(20) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    usos_maximos INT,
    usos_actuales INT DEFAULT 0,
    usos_por_cliente INT DEFAULT 1,
    monto_minimo DECIMAL(10,2),
    destinos_aplicables TEXT[],
    clientes_aplicables VARCHAR(20)[],
    tipos_cliente VARCHAR(20)[],
    activo BOOLEAN DEFAULT true,
    metadata JSONB,
    fecha_creacion TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promociones_codigo ON promociones(codigo);
CREATE INDEX IF NOT EXISTS idx_promociones_fechas ON promociones(fecha_inicio, fecha_fin);

-- ================================================================
-- PASO 9: CREAR TABLA USO PROMOCIONES
-- ================================================================

CREATE TABLE IF NOT EXISTS uso_promociones (
    id_uso SERIAL PRIMARY KEY,
    id_promocion INT REFERENCES promociones(id_promocion),
    codigo VARCHAR(20) NOT NULL,
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    id_reserva VARCHAR(20),
    descuento_aplicado DECIMAL(10,2),
    fecha_uso TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_uso_promociones_cliente ON uso_promociones(id_cliente);
CREATE INDEX IF NOT EXISTS idx_uso_promociones_codigo ON uso_promociones(codigo);

-- ================================================================
-- PASO 10: CREAR TABLA DOCUMENTOS
-- ================================================================

CREATE TABLE IF NOT EXISTS documentos (
    id_documento SERIAL PRIMARY KEY,
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    id_reserva VARCHAR(20),
    tipo_documento VARCHAR(50) NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    url_archivo TEXT NOT NULL,
    tamano_bytes BIGINT,
    mime_type VARCHAR(100),
    hash_md5 VARCHAR(32),
    estado VARCHAR(20) DEFAULT 'activo',
    valido_hasta DATE,
    verificado BOOLEAN DEFAULT false,
    verificado_por VARCHAR(100),
    fecha_verificacion TIMESTAMP,
    metadata JSONB,
    fecha_subida TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_documentos_cliente ON documentos(id_cliente);
CREATE INDEX IF NOT EXISTS idx_documentos_reserva ON documentos(id_reserva);
CREATE INDEX IF NOT EXISTS idx_documentos_tipo ON documentos(tipo_documento);
CREATE INDEX IF NOT EXISTS idx_documentos_hash ON documentos(hash_md5);

-- ================================================================
-- PASO 11: CREAR TABLA MÉTRICAS DIARIAS
-- ================================================================

CREATE TABLE IF NOT EXISTS metricas_diarias (
    id_metrica SERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    num_reservas INT DEFAULT 0,
    ingresos_total DECIMAL(12,2) DEFAULT 0,
    ticket_promedio DECIMAL(10,2) DEFAULT 0,
    num_clientes_nuevos INT DEFAULT 0,
    leads_nuevos INT DEFAULT 0,
    leads_contactados INT DEFAULT 0,
    leads_convertidos INT DEFAULT 0,
    tasa_conversion DECIMAL(5,2) DEFAULT 0,
    pagos_completados INT DEFAULT 0,
    pagos_pendientes INT DEFAULT 0,
    monto_pagos_completados DECIMAL(12,2) DEFAULT 0,
    conversaciones_totales INT DEFAULT 0,
    conversaciones_bot INT DEFAULT 0,
    conversaciones_humano INT DEFAULT 0,
    tiempo_respuesta_promedio INT,
    nps_score DECIMAL(5,2),
    promotores INT DEFAULT 0,
    pasivos INT DEFAULT 0,
    detractores INT DEFAULT 0,
    fecha_calculo TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_metricas_fecha ON metricas_diarias(fecha DESC);

-- ================================================================
-- PASO 12: CREAR TABLA INTEGRACIONES
-- ================================================================

CREATE TABLE IF NOT EXISTS integraciones (
    id_integracion SERIAL PRIMARY KEY,
    servicio VARCHAR(50) NOT NULL,
    endpoint VARCHAR(200),
    tipo_operacion VARCHAR(50),
    request_data JSONB,
    response_data JSONB,
    status_code INT,
    tiempo_respuesta_ms INT,
    exitoso BOOLEAN,
    error TEXT,
    id_cliente VARCHAR(20),
    id_reserva VARCHAR(20),
    metadata JSONB,
    fecha_hora TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_integraciones_servicio ON integraciones(servicio);
CREATE INDEX IF NOT EXISTS idx_integraciones_fecha ON integraciones(fecha_hora DESC);
CREATE INDEX IF NOT EXISTS idx_integraciones_exitoso ON integraciones(exitoso);

-- ================================================================
-- PASO 13: CREAR FUNCIONES Y TRIGGERS
-- ================================================================

-- Función genérica para auditoría
CREATE OR REPLACE FUNCTION auditar_cambios()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
        VALUES (TG_TABLE_NAME, 'UPDATE', 
                CASE TG_TABLE_NAME
                    WHEN 'clientes' THEN OLD.id_cliente
                    WHEN 'reservas' THEN OLD.id_reserva
                    WHEN 'pagos' THEN OLD.id_pago::VARCHAR
                    ELSE 'UNKNOWN'
                END,
                row_to_json(OLD)::jsonb, 
                row_to_json(NEW)::jsonb,
                current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
        VALUES (TG_TABLE_NAME, 'DELETE',
                CASE TG_TABLE_NAME
                    WHEN 'clientes' THEN OLD.id_cliente
                    WHEN 'reservas' THEN OLD.id_reserva
                    WHEN 'pagos' THEN OLD.id_pago::VARCHAR
                    ELSE 'UNKNOWN'
                END,
                row_to_json(OLD)::jsonb,
                current_user);
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
        VALUES (TG_TABLE_NAME, 'INSERT',
                CASE TG_TABLE_NAME
                    WHEN 'clientes' THEN NEW.id_cliente
                    WHEN 'reservas' THEN NEW.id_reserva
                    WHEN 'pagos' THEN NEW.id_pago::VARCHAR
                    ELSE 'UNKNOWN'
                END,
                row_to_json(NEW)::jsonb,
                current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de auditoría
DROP TRIGGER IF EXISTS trigger_auditar_clientes ON clientes;
CREATE TRIGGER trigger_auditar_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION auditar_cambios();

DROP TRIGGER IF EXISTS trigger_auditar_reservas ON reservas;
CREATE TRIGGER trigger_auditar_reservas
AFTER INSERT OR UPDATE OR DELETE ON reservas
FOR EACH ROW EXECUTE FUNCTION auditar_cambios();

DROP TRIGGER IF EXISTS trigger_auditar_pagos ON pagos;
CREATE TRIGGER trigger_auditar_pagos
AFTER INSERT OR UPDATE OR DELETE ON pagos
FOR EACH ROW EXECUTE FUNCTION auditar_cambios();

-- Función para actualizar último contacto del cliente
CREATE OR REPLACE FUNCTION actualizar_ultimo_contacto()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clientes 
    SET ultimo_contacto = NEW.fecha_hora,
        canal_preferido = NEW.canal
    WHERE id_cliente = NEW.id_cliente;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_ultimo_contacto ON conversaciones;
CREATE TRIGGER trigger_ultimo_contacto
AFTER INSERT ON conversaciones
FOR EACH ROW EXECUTE FUNCTION actualizar_ultimo_contacto();

-- Función para actualizar estadísticas del cliente
CREATE OR REPLACE FUNCTION actualizar_estadisticas_cliente()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clientes SET
        total_gastado = (SELECT COALESCE(SUM(precio), 0) FROM reservas WHERE id_cliente = NEW.id_cliente AND estado = 'confirmado'),
        num_viajes = (SELECT COUNT(*) FROM reservas WHERE id_cliente = NEW.id_cliente AND estado = 'confirmado')
    WHERE id_cliente = NEW.id_cliente;
    
    -- Auto-promover a VIP si gastó más de $5000 USD
    UPDATE clientes SET tipo_cliente = 'VIP' 
    WHERE id_cliente = NEW.id_cliente 
      AND total_gastado >= 5000 
      AND tipo_cliente != 'VIP';
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_estadisticas_cliente ON reservas;
CREATE TRIGGER trigger_estadisticas_cliente
AFTER INSERT OR UPDATE ON reservas
FOR EACH ROW EXECUTE FUNCTION actualizar_estadisticas_cliente();

-- Función para establecer fecha límite de pago
CREATE OR REPLACE FUNCTION set_fecha_limite_pago()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_limite_pago IS NULL THEN
        NEW.fecha_limite_pago = NOW() + INTERVAL '7 days';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_fecha_limite ON reservas;
CREATE TRIGGER trigger_fecha_limite
BEFORE INSERT ON reservas
FOR EACH ROW EXECUTE FUNCTION set_fecha_limite_pago();

-- Función para calcular neto en pagos
CREATE OR REPLACE FUNCTION calcular_neto_pago()
RETURNS TRIGGER AS $$
BEGIN
    NEW.neto = NEW.monto - COALESCE(NEW.comision, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_calcular_neto ON pagos;
CREATE TRIGGER trigger_calcular_neto
BEFORE INSERT OR UPDATE ON pagos
FOR EACH ROW EXECUTE FUNCTION calcular_neto_pago();

-- Función para actualizar fecha_actualizacion en leads
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_leads_fecha_actualizacion ON leads;
CREATE TRIGGER trigger_leads_fecha_actualizacion
BEFORE UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Función para incrementar contador de seguimientos
CREATE OR REPLACE FUNCTION incrementar_seguimientos()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_ultimo_seguimiento IS NOT NULL AND 
       (OLD.fecha_ultimo_seguimiento IS NULL OR NEW.fecha_ultimo_seguimiento > OLD.fecha_ultimo_seguimiento) THEN
        NEW.num_seguimientos = OLD.num_seguimientos + 1;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_incrementar_seguimientos ON leads;
CREATE TRIGGER trigger_incrementar_seguimientos
BEFORE UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION incrementar_seguimientos();

-- Función para incrementar uso de promociones
CREATE OR REPLACE FUNCTION incrementar_uso_promocion()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE promociones 
    SET usos_actuales = usos_actuales + 1
    WHERE id_promocion = NEW.id_promocion;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_uso_promocion ON uso_promociones;
CREATE TRIGGER trigger_uso_promocion
AFTER INSERT ON uso_promociones
FOR EACH ROW EXECUTE FUNCTION incrementar_uso_promocion();

-- ================================================================
-- PASO 14: CREAR VISTAS ÚTILES
-- ================================================================

-- Vista: Dashboard ejecutivo
CREATE OR REPLACE VIEW vista_dashboard_ejecutivo AS
SELECT 
    (SELECT COUNT(*) FROM reservas WHERE DATE(fecha_creacion) = CURRENT_DATE) as reservas_hoy,
    (SELECT COALESCE(SUM(precio), 0) FROM reservas WHERE DATE(fecha_creacion) = CURRENT_DATE) as ingresos_hoy,
    (SELECT COUNT(*) FROM clientes WHERE DATE(fecha_registro) = CURRENT_DATE) as clientes_nuevos_hoy,
    (SELECT COUNT(*) FROM leads WHERE DATE(fecha_creacion) = CURRENT_DATE) as leads_hoy,
    (SELECT COUNT(*) FROM pagos WHERE estado = 'pendiente') as pagos_pendientes,
    (SELECT COUNT(*) FROM reservas WHERE estado = 'pendiente' AND fecha_limite_pago < NOW()) as reservas_vencidas,
    (SELECT COUNT(*) FROM conversaciones WHERE respondido = false) as mensajes_sin_responder;

-- Vista: Top clientes
CREATE OR REPLACE VIEW vista_top_clientes AS
SELECT 
    c.id_cliente,
    c.nombre_completo,
    c.tipo_cliente,
    c.email,
    c.telefono,
    c.total_gastado,
    c.num_viajes,
    MAX(r.fecha_creacion) as ultimo_viaje
FROM clientes c
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.nombre_completo, c.tipo_cliente, c.email, c.telefono, c.total_gastado, c.num_viajes
ORDER BY c.total_gastado DESC;

-- Vista: Top destinos
CREATE OR REPLACE VIEW vista_top_destinos AS
SELECT 
    destino,
    COUNT(*) as num_reservas,
    SUM(precio) as revenue_total,
    AVG(precio) as precio_promedio,
    COUNT(DISTINCT id_cliente) as clientes_unicos
FROM reservas
WHERE estado != 'cancelado'
GROUP BY destino
ORDER BY revenue_total DESC;

-- Vista: Embudo de conversión
CREATE OR REPLACE VIEW vista_embudo_conversion AS
SELECT 
    DATE(fecha_creacion) as fecha,
    COUNT(*) as leads_totales,
    COUNT(*) FILTER (WHERE contactado = true) as contactados,
    COUNT(*) FILTER (WHERE estado = 'convertido') as convertidos,
    ROUND(COUNT(*) FILTER (WHERE contactado = true)::DECIMAL / NULLIF(COUNT(*), 0) * 100, 2) as tasa_contacto,
    ROUND(COUNT(*) FILTER (WHERE estado = 'convertido')::DECIMAL / NULLIF(COUNT(*) FILTER (WHERE contactado = true), 0) * 100, 2) as tasa_conversion
FROM leads
GROUP BY DATE(fecha_creacion)
ORDER BY fecha DESC;

-- ================================================================
-- PASO 15: INSERTAR DATOS DE PRUEBA (Promociones)
-- ================================================================

INSERT INTO promociones (codigo, descripcion, tipo, valor, fecha_inicio, fecha_fin, usos_maximos, tipos_cliente)
VALUES 
    ('BIENVENIDA10', 'Descuento de bienvenida para nuevos clientes', 'porcentaje', 10, '2025-01-01', '2025-12-31', 1000, ARRAY['nuevo']),
    ('VIP20', 'Descuento exclusivo para clientes VIP', 'porcentaje', 20, '2025-01-01', '2025-12-31', NULL, ARRAY['VIP']),
    ('NAVIDAD50', 'Descuento navideño $50 USD', 'monto_fijo', 50, '2025-12-01', '2025-12-31', 500, NULL)
ON CONFLICT (codigo) DO NOTHING;

-- ================================================================
-- FIN DEL SCRIPT
-- ================================================================

-- Mostrar resumen de tablas creadas
SELECT 
    'Tablas creadas/actualizadas' as resultado,
    COUNT(*) as total
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('auditoria', 'conversaciones', 'leads', 'notificaciones', 
                     'promociones', 'uso_promociones', 'documentos', 
                     'metricas_diarias', 'integraciones');
