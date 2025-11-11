# 🗄️ Mejoras para PostgreSQL Database - EFIG Travel Agency

## 📊 Estado Actual de la Base de Datos

### Tablas Existentes:
```sql
1. clientes (19 registros)
   - id_cliente (PK, auto C-XXXX)
   - nombre_completo
   - email
   - telefono
   - documento
   - tipo_cliente (nuevo/frecuente/VIP)
   - fecha_registro

2. reservas
   - id_reserva (PK, auto R-XXXX)
   - id_cliente (FK)
   - tipo (vuelo/hotel/paquete)
   - origen
   - destino
   - fecha_salida
   - fecha_regreso
   - precio
   - estado (pendiente/confirmado/cancelado)
   - notas

3. pagos
   - id_pago (PK, auto P-XXXX)
   - id_reserva (FK)
   - monto
   - metodo (efectivo/tarjeta/transferencia/PSE)
   - estado (completado/pendiente)
   - fecha_pago
```

---

## 🚀 MEJORAS CRÍTICAS EMPRESARIALES

### 1. Tabla de AUDITORÍA (Logging de Cambios)

```sql
-- Tabla para rastrear TODOS los cambios en el sistema
CREATE TABLE auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    tabla VARCHAR(50) NOT NULL,
    operacion VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    id_registro VARCHAR(20) NOT NULL,
    datos_anteriores JSONB, -- Estado antes del cambio
    datos_nuevos JSONB, -- Estado después del cambio
    usuario VARCHAR(100), -- Quién hizo el cambio (agente, sistema, cliente)
    ip_address INET,
    user_agent TEXT,
    fecha_hora TIMESTAMP DEFAULT NOW(),
    razon TEXT -- Motivo del cambio
);

CREATE INDEX idx_auditoria_tabla ON auditoria(tabla);
CREATE INDEX idx_auditoria_fecha ON auditoria(fecha_hora DESC);
CREATE INDEX idx_auditoria_usuario ON auditoria(usuario);

-- Trigger para clientes
CREATE OR REPLACE FUNCTION auditar_clientes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
        VALUES ('clientes', 'UPDATE', OLD.id_cliente, 
                row_to_json(OLD)::jsonb, 
                row_to_json(NEW)::jsonb,
                current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
        VALUES ('clientes', 'DELETE', OLD.id_cliente, 
                row_to_json(OLD)::jsonb,
                current_user);
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
        VALUES ('clientes', 'INSERT', NEW.id_cliente,
                row_to_json(NEW)::jsonb,
                current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auditar_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION auditar_clientes();

-- Aplicar triggers similares a reservas y pagos
CREATE TRIGGER trigger_auditar_reservas
AFTER INSERT OR UPDATE OR DELETE ON reservas
FOR EACH ROW EXECUTE FUNCTION auditar_clientes(); -- Reutilizar función

CREATE TRIGGER trigger_auditar_pagos
AFTER INSERT OR UPDATE OR DELETE ON pagos
FOR EACH ROW EXECUTE FUNCTION auditar_clientes();
```

**Beneficios:**
- ✅ Trazabilidad completa de cambios
- ✅ Cumplimiento con GDPR/protección de datos
- ✅ Debugging de errores
- ✅ Detección de fraudes

---

### 2. Tabla de CONVERSACIONES (Historial de Chat)

```sql
CREATE TABLE conversaciones (
    id_conversacion SERIAL PRIMARY KEY,
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    canal VARCHAR(20) NOT NULL, -- telegram, whatsapp, email, webchat
    chat_id VARCHAR(100), -- ID del chat en la plataforma
    mensaje TEXT NOT NULL,
    tipo VARCHAR(10) NOT NULL, -- 'enviado' o 'recibido'
    metadata JSONB, -- Contexto adicional (attachments, location, etc)
    sentimiento VARCHAR(20), -- positivo, neutral, negativo (análisis IA)
    intención VARCHAR(50), -- consulta, queja, venta, soporte (análisis IA)
    agente VARCHAR(100), -- Nombre del agente humano (si aplica)
    es_bot BOOLEAN DEFAULT true,
    fecha_hora TIMESTAMP DEFAULT NOW(),
    leido BOOLEAN DEFAULT false,
    respondido BOOLEAN DEFAULT false
);

CREATE INDEX idx_conversaciones_cliente ON conversaciones(id_cliente);
CREATE INDEX idx_conversaciones_canal ON conversaciones(canal);
CREATE INDEX idx_conversaciones_fecha ON conversaciones(fecha_hora DESC);
CREATE INDEX idx_conversaciones_no_respondido ON conversaciones(respondido) WHERE respondido = false;

-- Trigger para marcar cliente como activo
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

CREATE TRIGGER trigger_ultimo_contacto
AFTER INSERT ON conversaciones
FOR EACH ROW EXECUTE FUNCTION actualizar_ultimo_contacto();
```

**Agregar campos a tabla clientes:**
```sql
ALTER TABLE clientes ADD COLUMN ultimo_contacto TIMESTAMP;
ALTER TABLE clientes ADD COLUMN canal_preferido VARCHAR(20);
ALTER TABLE clientes ADD COLUMN telegram_id VARCHAR(50);
ALTER TABLE clientes ADD COLUMN whatsapp VARCHAR(20);
```

---

### 3. Tabla de LEADS (Embudo de Ventas)

```sql
CREATE TABLE leads (
    id_lead SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    destino_interes VARCHAR(100),
    fecha_viaje_estimada DATE,
    presupuesto DECIMAL(10,2),
    tipo_viaje VARCHAR(50), -- luna_miel, vacaciones, negocios, grupo
    num_personas INT DEFAULT 1,
    fuente VARCHAR(50), -- google_ads, facebook, instagram, referido, organico
    utm_source VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_medium VARCHAR(100),
    -- SCORING
    score INT DEFAULT 0, -- 0-100
    clasificacion VARCHAR(10), -- HOT, WARM, COLD
    -- SEGUIMIENTO
    estado VARCHAR(20) DEFAULT 'nuevo', -- nuevo, contactado, calificado, convertido, perdido
    contactado BOOLEAN DEFAULT false,
    fecha_primer_contacto TIMESTAMP,
    fecha_ultimo_seguimiento TIMESTAMP,
    num_seguimientos INT DEFAULT 0,
    agente_asignado VARCHAR(100),
    -- CONVERSIÓN
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente), -- Si convierte
    id_reserva VARCHAR(20), -- Si reserva
    fecha_conversion TIMESTAMP,
    motivo_perdida TEXT,
    -- METADATA
    notas TEXT,
    metadata JSONB, -- Datos adicionales del formulario
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_telefono ON leads(telefono);
CREATE INDEX idx_leads_estado ON leads(estado);
CREATE INDEX idx_leads_clasificacion ON leads(clasificacion);
CREATE INDEX idx_leads_score ON leads(score DESC);
CREATE INDEX idx_leads_agente ON leads(agente_asignado);
CREATE INDEX idx_leads_no_contactado ON leads(contactado) WHERE contactado = false;

-- Trigger: Auto-actualizar fecha_actualizacion
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_leads_fecha_actualizacion
BEFORE UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Trigger: Incrementar contador de seguimientos
CREATE OR REPLACE FUNCTION incrementar_seguimientos()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_ultimo_seguimiento > OLD.fecha_ultimo_seguimiento THEN
        NEW.num_seguimientos = OLD.num_seguimientos + 1;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_incrementar_seguimientos
BEFORE UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION incrementar_seguimientos();
```

---

### 4. Tabla de NOTIFICACIONES (Alertas Programadas)

```sql
CREATE TABLE notificaciones (
    id_notificacion SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL, -- recordatorio_pago, pre_viaje, post_viaje, seguimiento_lead
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    id_reserva VARCHAR(20),
    id_lead INT REFERENCES leads(id_lead),
    canal VARCHAR(20) NOT NULL, -- telegram, whatsapp, email, sms
    destinatario VARCHAR(200) NOT NULL, -- Número o email
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
    prioridad INT DEFAULT 1, -- 1=baja, 2=normal, 3=alta, 4=urgente
    metadata JSONB,
    fecha_creacion TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notificaciones_programadas ON notificaciones(programada_para) WHERE enviada = false;
CREATE INDEX idx_notificaciones_cliente ON notificaciones(id_cliente);
CREATE INDEX idx_notificaciones_tipo ON notificaciones(tipo);
CREATE INDEX idx_notificaciones_prioridad ON notificaciones(prioridad DESC);

-- Trigger: Crear notificación automática cuando se crea una reserva
CREATE OR REPLACE FUNCTION programar_notificaciones_reserva()
RETURNS TRIGGER AS $$
BEGIN
    -- Notificación inmediata de confirmación
    INSERT INTO notificaciones (tipo, id_cliente, id_reserva, canal, destinatario, mensaje, programada_para, prioridad)
    SELECT 
        'confirmacion_reserva',
        NEW.id_cliente,
        NEW.id_reserva,
        'whatsapp',
        c.telefono,
        'Tu reserva ' || NEW.id_reserva || ' ha sido confirmada. Destino: ' || NEW.destino,
        NOW() + INTERVAL '5 minutes',
        3
    FROM clientes c WHERE c.id_cliente = NEW.id_cliente;
    
    -- Notificación pre-viaje (7 días antes)
    INSERT INTO notificaciones (tipo, id_cliente, id_reserva, canal, destinatario, mensaje, programada_para, prioridad)
    SELECT 
        'pre_viaje',
        NEW.id_cliente,
        NEW.id_reserva,
        'whatsapp',
        c.telefono,
        'Tu viaje a ' || NEW.destino || ' está en 7 días. Prepara tus documentos.',
        NEW.fecha_salida - INTERVAL '7 days',
        2
    FROM clientes c WHERE c.id_cliente = NEW.id_cliente;
    
    -- Notificación 1 día antes
    INSERT INTO notificaciones (tipo, id_cliente, id_reserva, canal, destinatario, mensaje, programada_para, prioridad)
    SELECT 
        'dia_del_viaje',
        NEW.id_cliente,
        NEW.id_reserva,
        'whatsapp',
        c.telefono,
        'Mañana es tu viaje a ' || NEW.destino || '. ¡Que tengas un excelente viaje!',
        NEW.fecha_salida - INTERVAL '1 day',
        3
    FROM clientes c WHERE c.id_cliente = NEW.id_cliente;
    
    -- Notificación post-viaje (1 día después del regreso)
    IF NEW.fecha_regreso IS NOT NULL THEN
        INSERT INTO notificaciones (tipo, id_cliente, id_reserva, canal, destinatario, mensaje, programada_para, prioridad)
        SELECT 
            'post_viaje',
            NEW.id_cliente,
            NEW.id_reserva,
            'whatsapp',
            c.telefono,
            '¡Bienvenido de vuelta! ¿Cómo estuvo tu viaje a ' || NEW.destino || '?',
            NEW.fecha_regreso + INTERVAL '1 day',
            2
        FROM clientes c WHERE c.id_cliente = NEW.id_cliente;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notificaciones_reserva
AFTER INSERT ON reservas
FOR EACH ROW EXECUTE FUNCTION programar_notificaciones_reserva();
```

---

### 5. Tabla de MÉTRICAS y KPIs (Business Intelligence)

```sql
CREATE TABLE metricas_diarias (
    id_metrica SERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    -- VENTAS
    num_reservas INT DEFAULT 0,
    ingresos_total DECIMAL(12,2) DEFAULT 0,
    ticket_promedio DECIMAL(10,2) DEFAULT 0,
    num_clientes_nuevos INT DEFAULT 0,
    -- CONVERSIÓN
    leads_nuevos INT DEFAULT 0,
    leads_contactados INT DEFAULT 0,
    leads_convertidos INT DEFAULT 0,
    tasa_conversion DECIMAL(5,2) DEFAULT 0,
    -- PAGOS
    pagos_completados INT DEFAULT 0,
    pagos_pendientes INT DEFAULT 0,
    monto_pagos_completados DECIMAL(12,2) DEFAULT 0,
    -- SOPORTE
    conversaciones_totales INT DEFAULT 0,
    conversaciones_bot INT DEFAULT 0,
    conversaciones_humano INT DEFAULT 0,
    tiempo_respuesta_promedio INT, -- en minutos
    -- NPS
    nps_score DECIMAL(5,2),
    promotores INT DEFAULT 0,
    pasivos INT DEFAULT 0,
    detractores INT DEFAULT 0,
    fecha_calculo TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_metricas_fecha ON metricas_diarias(fecha DESC);

-- Function para actualizar métricas del día
CREATE OR REPLACE FUNCTION actualizar_metricas_diarias()
RETURNS void AS $$
BEGIN
    INSERT INTO metricas_diarias (fecha)
    VALUES (CURRENT_DATE)
    ON CONFLICT (fecha) DO NOTHING;
    
    UPDATE metricas_diarias SET
        num_reservas = (SELECT COUNT(*) FROM reservas WHERE DATE(fecha_creacion) = CURRENT_DATE),
        ingresos_total = (SELECT COALESCE(SUM(precio), 0) FROM reservas WHERE DATE(fecha_creacion) = CURRENT_DATE),
        ticket_promedio = (SELECT COALESCE(AVG(precio), 0) FROM reservas WHERE DATE(fecha_creacion) = CURRENT_DATE),
        num_clientes_nuevos = (SELECT COUNT(*) FROM clientes WHERE DATE(fecha_registro) = CURRENT_DATE),
        leads_nuevos = (SELECT COUNT(*) FROM leads WHERE DATE(fecha_creacion) = CURRENT_DATE),
        leads_contactados = (SELECT COUNT(*) FROM leads WHERE DATE(fecha_primer_contacto) = CURRENT_DATE),
        leads_convertidos = (SELECT COUNT(*) FROM leads WHERE DATE(fecha_conversion) = CURRENT_DATE AND estado = 'convertido'),
        pagos_completados = (SELECT COUNT(*) FROM pagos WHERE DATE(fecha_pago) = CURRENT_DATE AND estado = 'completado'),
        pagos_pendientes = (SELECT COUNT(*) FROM pagos WHERE DATE(fecha_pago) = CURRENT_DATE AND estado = 'pendiente'),
        conversaciones_totales = (SELECT COUNT(*) FROM conversaciones WHERE DATE(fecha_hora) = CURRENT_DATE),
        conversaciones_bot = (SELECT COUNT(*) FROM conversaciones WHERE DATE(fecha_hora) = CURRENT_DATE AND es_bot = true)
    WHERE fecha = CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar esto desde n8n cada hora o al final del día
```

---

### 6. Tabla de DOCUMENTOS (Gestión de Archivos)

```sql
CREATE TABLE documentos (
    id_documento SERIAL PRIMARY KEY,
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    id_reserva VARCHAR(20),
    tipo_documento VARCHAR(50) NOT NULL, -- pasaporte, visa, voucher, ticket, factura, contrato
    nombre_archivo VARCHAR(255) NOT NULL,
    url_archivo TEXT NOT NULL, -- URL en Google Cloud Storage
    tamaño_bytes BIGINT,
    mime_type VARCHAR(100),
    hash_md5 VARCHAR(32), -- Para detectar duplicados
    estado VARCHAR(20) DEFAULT 'activo', -- activo, archivado, eliminado
    valido_hasta DATE, -- Para documentos con vencimiento
    verificado BOOLEAN DEFAULT false,
    verificado_por VARCHAR(100),
    fecha_verificacion TIMESTAMP,
    metadata JSONB,
    fecha_subida TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_documentos_cliente ON documentos(id_cliente);
CREATE INDEX idx_documentos_reserva ON documentos(id_reserva);
CREATE INDEX idx_documentos_tipo ON documentos(tipo_documento);
CREATE INDEX idx_documentos_hash ON documentos(hash_md5);

-- Trigger: Alertar si documento está por vencer
CREATE OR REPLACE FUNCTION alertar_documento_vencimiento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.valido_hasta IS NOT NULL AND NEW.valido_hasta <= CURRENT_DATE + INTERVAL '30 days' THEN
        INSERT INTO notificaciones (tipo, id_cliente, canal, destinatario, mensaje, programada_para, prioridad)
        SELECT 
            'documento_por_vencer',
            NEW.id_cliente,
            'email',
            c.email,
            'Tu ' || NEW.tipo_documento || ' vence el ' || NEW.valido_hasta,
            NOW(),
            2
        FROM clientes c WHERE c.id_cliente = NEW.id_cliente;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_documento_vencimiento
AFTER INSERT OR UPDATE ON documentos
FOR EACH ROW EXECUTE FUNCTION alertar_documento_vencimiento();
```

---

### 7. Tabla de DESCUENTOS y PROMOCIONES

```sql
CREATE TABLE promociones (
    id_promocion SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(20) NOT NULL, -- porcentaje, monto_fijo, upgrade
    valor DECIMAL(10,2) NOT NULL, -- 10 (para 10%), 50 (para $50 USD)
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    usos_maximos INT,
    usos_actuales INT DEFAULT 0,
    usos_por_cliente INT DEFAULT 1,
    monto_minimo DECIMAL(10,2), -- Compra mínima requerida
    destinos_aplicables TEXT[], -- Array de destinos
    clientes_aplicables VARCHAR(20)[], -- Clientes específicos o NULL para todos
    tipos_cliente VARCHAR(20)[], -- nuevo, frecuente, VIP
    activo BOOLEAN DEFAULT true,
    metadata JSONB,
    fecha_creacion TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_promociones_codigo ON promociones(codigo);
CREATE INDEX idx_promociones_fechas ON promociones(fecha_inicio, fecha_fin);

-- Tabla de uso de promociones
CREATE TABLE uso_promociones (
    id_uso SERIAL PRIMARY KEY,
    id_promocion INT REFERENCES promociones(id_promocion),
    codigo VARCHAR(20) NOT NULL,
    id_cliente VARCHAR(20) REFERENCES clientes(id_cliente),
    id_reserva VARCHAR(20),
    descuento_aplicado DECIMAL(10,2),
    fecha_uso TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_uso_promociones_cliente ON uso_promociones(id_cliente);
CREATE INDEX idx_uso_promociones_codigo ON uso_promociones(codigo);

-- Trigger: Incrementar contador de usos
CREATE OR REPLACE FUNCTION incrementar_uso_promocion()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE promociones 
    SET usos_actuales = usos_actuales + 1
    WHERE id_promocion = NEW.id_promocion;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_uso_promocion
AFTER INSERT ON uso_promociones
FOR EACH ROW EXECUTE FUNCTION incrementar_uso_promocion();

-- Function: Validar promoción
CREATE OR REPLACE FUNCTION validar_promocion(
    p_codigo VARCHAR(20),
    p_cliente VARCHAR(20),
    p_monto DECIMAL(10,2),
    p_destino VARCHAR(100)
)
RETURNS TABLE(valido BOOLEAN, mensaje TEXT, descuento DECIMAL(10,2)) AS $$
DECLARE
    v_promo promociones%ROWTYPE;
    v_usos_cliente INT;
BEGIN
    -- Obtener promoción
    SELECT * INTO v_promo FROM promociones WHERE codigo = p_codigo AND activo = true;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Código inválido o expirado', 0::DECIMAL(10,2);
        RETURN;
    END IF;
    
    -- Validar fechas
    IF CURRENT_DATE < v_promo.fecha_inicio OR CURRENT_DATE > v_promo.fecha_fin THEN
        RETURN QUERY SELECT false, 'Promoción no vigente', 0::DECIMAL(10,2);
        RETURN;
    END IF;
    
    -- Validar usos máximos
    IF v_promo.usos_maximos IS NOT NULL AND v_promo.usos_actuales >= v_promo.usos_maximos THEN
        RETURN QUERY SELECT false, 'Promoción agotada', 0::DECIMAL(10,2);
        RETURN;
    END IF;
    
    -- Validar usos por cliente
    SELECT COUNT(*) INTO v_usos_cliente 
    FROM uso_promociones 
    WHERE codigo = p_codigo AND id_cliente = p_cliente;
    
    IF v_usos_cliente >= v_promo.usos_por_cliente THEN
        RETURN QUERY SELECT false, 'Ya usaste esta promoción', 0::DECIMAL(10,2);
        RETURN;
    END IF;
    
    -- Validar monto mínimo
    IF v_promo.monto_minimo IS NOT NULL AND p_monto < v_promo.monto_minimo THEN
        RETURN QUERY SELECT false, 'Monto mínimo no alcanzado: $' || v_promo.monto_minimo, 0::DECIMAL(10,2);
        RETURN;
    END IF;
    
    -- Calcular descuento
    IF v_promo.tipo = 'porcentaje' THEN
        RETURN QUERY SELECT true, 'Descuento aplicado', (p_monto * v_promo.valor / 100)::DECIMAL(10,2);
    ELSIF v_promo.tipo = 'monto_fijo' THEN
        RETURN QUERY SELECT true, 'Descuento aplicado', v_promo.valor;
    ELSE
        RETURN QUERY SELECT true, 'Beneficio especial aplicado', 0::DECIMAL(10,2);
    END IF;
END;
$$ LANGUAGE plpgsql;
```

---

### 8. Tabla de INTEGRACIONES (APIs Externas)

```sql
CREATE TABLE integraciones (
    id_integracion SERIAL PRIMARY KEY,
    servicio VARCHAR(50) NOT NULL, -- amadeus, stripe, whatsapp, telegram, google_flights
    endpoint VARCHAR(200),
    tipo_operacion VARCHAR(50), -- buscar_vuelos, procesar_pago, enviar_mensaje
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

CREATE INDEX idx_integraciones_servicio ON integraciones(servicio);
CREATE INDEX idx_integraciones_fecha ON integraciones(fecha_hora DESC);
CREATE INDEX idx_integraciones_exitoso ON integraciones(exitoso);

-- Vista para analizar performance de APIs
CREATE OR REPLACE VIEW vista_performance_apis AS
SELECT 
    servicio,
    COUNT(*) as total_llamadas,
    COUNT(*) FILTER (WHERE exitoso = true) as exitosas,
    COUNT(*) FILTER (WHERE exitoso = false) as fallidas,
    ROUND(COUNT(*) FILTER (WHERE exitoso = true)::DECIMAL / COUNT(*) * 100, 2) as tasa_exito,
    ROUND(AVG(tiempo_respuesta_ms), 2) as tiempo_promedio_ms,
    MAX(tiempo_respuesta_ms) as tiempo_max_ms,
    DATE(fecha_hora) as fecha
FROM integraciones
GROUP BY servicio, DATE(fecha_hora)
ORDER BY fecha DESC, total_llamadas DESC;
```

---

## 🔧 MEJORAS A TABLAS EXISTENTES

### Mejoras a tabla `clientes`:
```sql
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS ultimo_contacto TIMESTAMP;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS canal_preferido VARCHAR(20);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS telegram_id VARCHAR(50);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS whatsapp VARCHAR(20);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS idioma VARCHAR(5) DEFAULT 'es';
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS pais VARCHAR(50);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS ciudad VARCHAR(100);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS fecha_nacimiento DATE;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS genero VARCHAR(20);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS preferencias JSONB; -- destinos_favoritos, presupuesto_habitual, etc
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS nps_score INT; -- Último NPS dado (0-10)
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS total_gastado DECIMAL(12,2) DEFAULT 0;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS num_viajes INT DEFAULT 0;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT true;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS notas TEXT;

-- Trigger para actualizar estadísticas del cliente
CREATE OR REPLACE FUNCTION actualizar_estadisticas_cliente()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clientes SET
        total_gastado = (SELECT COALESCE(SUM(precio), 0) FROM reservas WHERE id_cliente = NEW.id_cliente),
        num_viajes = (SELECT COUNT(*) FROM reservas WHERE id_cliente = NEW.id_cliente AND estado = 'confirmado')
    WHERE id_cliente = NEW.id_cliente;
    
    -- Auto-promover a VIP si gastó más de $5000 USD
    UPDATE clientes SET tipo_cliente = 'VIP' 
    WHERE id_cliente = NEW.id_cliente AND total_gastado >= 5000 AND tipo_cliente != 'VIP';
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_estadisticas_cliente
AFTER INSERT OR UPDATE ON reservas
FOR EACH ROW EXECUTE FUNCTION actualizar_estadisticas_cliente();
```

### Mejoras a tabla `reservas`:
```sql
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS aerolinea VARCHAR(100);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS numero_vuelo VARCHAR(20);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS hotel_nombre VARCHAR(200);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS hotel_direccion TEXT;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS num_adultos INT DEFAULT 1;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS num_niños INT DEFAULT 0;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS num_bebes INT DEFAULT 0;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS clase VARCHAR(20); -- economica, ejecutiva, primera
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS equipaje VARCHAR(50); -- solo_mano, 1_maleta, 2_maletas
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS seguro_viaje BOOLEAN DEFAULT false;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS monto_seguro DECIMAL(10,2);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS codigo_reserva_externo VARCHAR(50); -- PNR de aerolínea
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS fecha_limite_pago TIMESTAMP;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS cancelable BOOLEAN DEFAULT true;
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS penalidad_cancelacion DECIMAL(10,2);
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP DEFAULT NOW();
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS fecha_actualizacion TIMESTAMP DEFAULT NOW();
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS creado_por VARCHAR(100); -- Agente o 'sistema'
ALTER TABLE reservas ADD COLUMN IF NOT EXISTS metadata JSONB;

-- Trigger para fecha_limite_pago (7 días por defecto)
CREATE OR REPLACE FUNCTION set_fecha_limite_pago()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_limite_pago IS NULL THEN
        NEW.fecha_limite_pago = NOW() + INTERVAL '7 days';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_fecha_limite
BEFORE INSERT ON reservas
FOR EACH ROW EXECUTE FUNCTION set_fecha_limite_pago();
```

### Mejoras a tabla `pagos`:
```sql
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS referencia_transaccion VARCHAR(100);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS banco VARCHAR(100);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS ultimos_4_digitos VARCHAR(4); -- Tarjeta
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS tipo_tarjeta VARCHAR(20); -- visa, mastercard, amex
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS cuotas INT DEFAULT 1;
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS moneda VARCHAR(3) DEFAULT 'USD';
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS tasa_cambio DECIMAL(10,4);
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS comision DECIMAL(10,2) DEFAULT 0;
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS neto DECIMAL(10,2); -- monto - comision
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS comprobante_url TEXT; -- Link a comprobante PDF
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS ip_address INET;
ALTER TABLE pagos ADD COLUMN IF NOT EXISTS metadata JSONB;

-- Trigger para calcular neto
CREATE OR REPLACE FUNCTION calcular_neto_pago()
RETURNS TRIGGER AS $$
BEGIN
    NEW.neto = NEW.monto - COALESCE(NEW.comision, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calcular_neto
BEFORE INSERT OR UPDATE ON pagos
FOR EACH ROW EXECUTE FUNCTION calcular_neto_pago();
```

---

## 📊 VISTAS ÚTILES PARA REPORTES

```sql
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
    COUNT(r.id_reserva) as num_reservas,
    COALESCE(SUM(r.precio), 0) as total_gastado,
    MAX(r.fecha_creacion) as ultimo_viaje,
    c.email,
    c.telefono
FROM clientes c
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente
ORDER BY total_gastado DESC;

-- Vista: Destinos más vendidos
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
    ROUND(COUNT(*) FILTER (WHERE contactado = true)::DECIMAL / COUNT(*) * 100, 2) as tasa_contacto,
    ROUND(COUNT(*) FILTER (WHERE estado = 'convertido')::DECIMAL / NULLIF(COUNT(*) FILTER (WHERE contactado = true), 0) * 100, 2) as tasa_conversion
FROM leads
GROUP BY DATE(fecha_creacion)
ORDER BY fecha DESC;
```

---

## 🎯 PRIORIDADES DE IMPLEMENTACIÓN

### FASE 1 (CRÍTICO - Esta semana):
1. ✅ Tabla `auditoria` + triggers
2. ✅ Tabla `conversaciones`
3. ✅ Mejoras a `clientes` (campos faltantes)
4. ✅ Mejoras a `reservas` (fecha_limite_pago)

### FASE 2 (ALTA - Próximas 2 semanas):
1. ✅ Tabla `leads` completa
2. ✅ Tabla `notificaciones` + triggers automáticos
3. ✅ Tabla `promociones`
4. ✅ Vistas de reportes

### FASE 3 (MEDIA - Mes 1):
1. ✅ Tabla `documentos`
2. ✅ Tabla `metricas_diarias`
3. ✅ Tabla `integraciones`

---

¿Quiero que genere el script SQL completo para ejecutar todo de una vez? 🚀
