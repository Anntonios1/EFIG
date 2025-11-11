# 🚀 Workflows Avanzados - Parte 3

## WORKFLOW 4: Leads y Ventas Automáticas

### 🎯 Objetivo
Capturar leads de múltiples fuentes, calificarlos automáticamente y convertirlos en ventas con seguimiento inteligente.

### 📊 Embudo de Conversión
```
┌────────────────────────────────────────────────────┐
│              FUENTES DE LEADS                      │
│  Google Ads | Facebook | Instagram | Landing Page │
└──────────────────────┬─────────────────────────────┘
                       ▼
        ┌──────────────────────────────┐
        │   Lead Capture & Scoring     │
        │  - Captura datos completos   │
        │  - Score automático (0-100)  │
        │  - Enriquecimiento con APIs  │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │    Clasificación de Leads    │
        │  🔥 Hot: 80-100 (llamar YA)  │
        │  🌡️ Warm: 50-79 (seguir hoy)│
        │  ❄️ Cold: 0-49 (nurture)     │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │   Asignación Automática      │
        │  - Round-robin a agentes     │
        │  - Prioridad por score       │
        │  - Notificación instantánea  │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │   Secuencia de Follow-ups    │
        │  - Email bienvenida (T+5min) │
        │  - WhatsApp contacto (T+1h)  │
        │  - Llamada agente (T+4h)     │
        │  - Email oferta (T+24h)      │
        │  - Reactivación (T+7d)       │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │      Conversión o Drop       │
        │  Convertido → Crear Cliente  │
        │  Perdido → Re-engagement     │
        └──────────────────────────────┘
```

### 📝 Sistema de Scoring

```javascript
// Function Node: Lead Scoring Algorithm
const lead = $input.item.json;

let score = 0;

// 1. URGENCIA DEL VIAJE (30 pts)
if (lead.fecha_viaje) {
  const diasHastaViaje = Math.ceil((new Date(lead.fecha_viaje) - new Date()) / (1000 * 60 * 60 * 24));
  
  if (diasHastaViaje <= 7) score += 30;       // Viaje inmediato
  else if (diasHastaViaje <= 30) score += 20; // Este mes
  else if (diasHastaViaje <= 90) score += 10; // Este trimestre
  else score += 5;                             // Largo plazo
}

// 2. PRESUPUESTO (25 pts)
if (lead.presupuesto) {
  const budget = parseInt(lead.presupuesto);
  
  if (budget >= 3000) score += 25;      // Premium
  else if (budget >= 1500) score += 20; // Alto
  else if (budget >= 800) score += 15;  // Medio
  else if (budget >= 400) score += 10;  // Básico
  else score += 5;                       // Low budget
}

// 3. TIPO DE VIAJE (15 pts)
const tiposAltoValor = ['luna_miel', 'aniversario', 'corporativo', 'grupo'];
if (tiposAltoValor.includes(lead.tipo_viaje)) {
  score += 15;
} else if (lead.tipo_viaje === 'vacaciones') {
  score += 10;
} else {
  score += 5;
}

// 4. COMPLETITUD DE INFORMACIÓN (15 pts)
let camposCompletos = 0;
const camposRequeridos = ['nombre', 'email', 'telefono', 'destino', 'fecha_viaje', 'presupuesto'];

camposRequeridos.forEach(campo => {
  if (lead[campo] && lead[campo] !== '') camposCompletos++;
});

score += Math.round((camposCompletos / camposRequeridos.length) * 15);

// 5. ENGAGEMENT PREVIO (10 pts)
if (lead.visitas_web >= 5) score += 10;
else if (lead.visitas_web >= 3) score += 7;
else if (lead.visitas_web >= 1) score += 4;

// 6. FUENTE DEL LEAD (5 pts)
const fuentesAltoValor = ['referido', 'google_ads', 'cliente_anterior'];
if (fuentesAltoValor.includes(lead.fuente)) {
  score += 5;
} else {
  score += 2;
}

// CLASIFICACIÓN
let clasificacion;
let prioridad;
let accion_recomendada;

if (score >= 80) {
  clasificacion = 'HOT';
  prioridad = 'URGENTE';
  accion_recomendada = 'Llamar en los próximos 15 minutos';
} else if (score >= 50) {
  clasificacion = 'WARM';
  prioridad = 'ALTA';
  accion_recomendada = 'Contactar vía WhatsApp en 1 hora';
} else {
  clasificacion = 'COLD';
  prioridad = 'NORMAL';
  accion_recomendada = 'Agregar a secuencia de emails';
}

return {
  ...lead,
  score: score,
  clasificacion: clasificacion,
  prioridad: prioridad,
  accion_recomendada: accion_recomendada,
  fecha_scoring: new Date().toISOString()
};
```

### 📧 Secuencias Automáticas

#### Secuencia HOT (80-100 pts)
```
T+0: Notificación inmediata a agente de ventas
     "🔥 LEAD HOT: [Nombre] - Score 95 - Llamar AHORA"

T+5min: Email automático
     Asunto: "{{nombre}}, tu viaje a {{destino}} está a un paso"
     
     Hola {{nombre}},
     
     Vi que estás planeando un viaje a {{destino}}. ¡Excelente elección! 🌴
     
     Como especialistas en ese destino, tenemos ofertas exclusivas que 
     podrían ahorrarte hasta $500 USD.
     
     Mi colega {{agente_asignado}} te llamará en los próximos minutos al
     {{telefono}} para ayudarte a planear todo.
     
     ¿Prefieres que te contactemos por WhatsApp?
     [Botón: Sí, escríbeme por WhatsApp]
     
     O si tienes prisa:
     📞 Llámanos: +57 300 123 4567
     💬 WhatsApp: wa.me/573001234567
     
     ¡Hablamos ya!
     Equipo EFIG

T+15min: Si no responde → WhatsApp
     "Hola {{nombre}}! 👋 Soy {{agente}} de EFIG. Vi tu interés en viajar
     a {{destino}}. ¿Tienes 2 minutos para hablar? Tengo opciones perfectas
     para tu presupuesto de ${{presupuesto}}. ¿Te llamo o prefieres chatear?"

T+1h: Si no responde → SMS
     "{{nombre}}, intentamos contactarte para tu viaje a {{destino}}.
     Responde VIAJE para que te llamemos o visita: efig.co/{{lead_id}}"

T+4h: Si no convierte → Email con oferta especial
     Asunto: "⏰ Oferta válida 24h: {{destino}} desde ${{precio_oferta}}"
     
T+24h: Si no convierte → Recordatorio final
     "Esta es tu última oportunidad de aprovechar nuestra oferta especial..."
```

#### Secuencia WARM (50-79 pts)
```
T+0: Email de bienvenida
T+1h: WhatsApp de contacto
T+4h: Email con guía de destino
T+24h: Llamada de agente
T+3d: Email con testimonios
T+7d: Oferta limitada
T+14d: Encuesta de necesidades
```

#### Secuencia COLD (0-49 pts)
```
T+0: Email de bienvenida
T+24h: Contenido educativo (blog post)
T+3d: Newsletter semanal
T+7d: Case study de cliente
T+14d: Webinar gratuito
T+30d: Reactivación con descuento
```

### 🛠️ Nodos n8n para Leads

```
WORKFLOW: "Lead Capture & Conversion"

1. Webhook (Recibe lead de formulario)
   ├─ URL: /webhook/lead-capture
   └─ Método: POST

2. Set Node: Limpiar y normalizar datos
   ├─ Trim espacios
   ├─ Validar email
   ├─ Formatear teléfono
   └─ Timestamp de creación

3. HTTP Request: Enriquecimiento de datos
   ├─ API: ClearBit (datos de empresa si es B2B)
   ├─ API: Full Contact (perfil social)
   └─ API: Google Places (validar ubicación)

4. Function: Lead Scoring Algorithm
   └─ Output: score (0-100)

5. PostgreSQL: Insertar lead en DB
   └─ Tabla: leads (con score y clasificación)

6. Switch: Clasificación del lead
   ├─ Branch HOT (>=80)
   │  ├─ Slack: Notificar a ventas
   │  ├─ Email: Bienvenida urgente
   │  ├─ WhatsApp: Contacto inmediato
   │  └─ PostgreSQL: Asignar a agente disponible
   │
   ├─ Branch WARM (50-79)
   │  ├─ Email: Bienvenida normal
   │  ├─ Agregar a cola de seguimiento
   │  └─ Schedule: Llamada en 4 horas
   │
   └─ Branch COLD (0-49)
      ├─ Email: Bienvenida + contenido
      └─ Agregar a secuencia de nurturing

7. Google Sheets: Log de leads (backup)

8. Error Handler
   └─ Slack: Notificar error + datos del lead
```

---

## WORKFLOW 5: Reportes Automáticos Diarios

### 🎯 Objetivo
Generar y enviar reportes ejecutivos automáticos cada mañana con métricas clave del negocio.

### 📊 Reporte Diario Ejecutivo

```
════════════════════════════════════════════════════════════
📊 REPORTE DIARIO EFIG TRAVEL - {{fecha}}
════════════════════════════════════════════════════════════

🎯 MÉTRICAS PRINCIPALES (Últimas 24h)
────────────────────────────────────────────────────────────
💰 Ingresos:            ${{ingresos_dia}} USD ({{cambio_vs_ayer}}%)
🎫 Reservas nuevas:     {{reservas_count}} ({{cambio_vs_ayer}}%)
👥 Clientes nuevos:     {{clientes_nuevos}}
📈 Ticket promedio:     ${{ticket_promedio}} USD
💳 Pagos completados:   {{pagos_count}} (${{monto_pagos}})
⏳ Pagos pendientes:    {{pagos_pendientes}} (${{monto_pendiente}})

════════════════════════════════════════════════════════════
🔥 TOP 5 DESTINOS (Última semana)
────────────────────────────────────────────────────────────
1. {{destino_1}}       {{count_1}} reservas   ${{revenue_1}}
2. {{destino_2}}       {{count_2}} reservas   ${{revenue_2}}
3. {{destino_3}}       {{count_3}} reservas   ${{revenue_3}}
4. {{destino_4}}       {{count_4}} reservas   ${{revenue_4}}
5. {{destino_5}}       {{count_5}} reservas   ${{revenue_5}}

════════════════════════════════════════════════════════════
📊 CONVERSIÓN DEL EMBUDO
────────────────────────────────────────────────────────────
👤 Leads capturados:       {{leads_total}}
💬 Contactados:            {{leads_contactados}} ({{tasa_contacto}}%)
🎫 Reservas creadas:       {{reservas_total}} ({{tasa_conversion}}%)
✅ Pagos completados:      {{pagos_completados}} ({{tasa_pago}}%)

Tasa de conversión global: {{tasa_conversion_global}}%
{{#if tasa_conversion_global < 50}}
⚠️ ALERTA: Conversión por debajo del objetivo (50%)
{{/if}}

════════════════════════════════════════════════════════════
🚨 ALERTAS Y ACCIONES REQUERIDAS
────────────────────────────────────────────────────────────
{{#if pagos_vencen_hoy > 0}}
⚠️ {{pagos_vencen_hoy}} pagos vencen HOY - Contactar clientes
{{/if}}

{{#if reservas_sin_confirmar > 0}}
⚠️ {{reservas_sin_confirmar}} reservas sin confirmar >48h
{{/if}}

{{#if leads_hot_sin_contactar > 0}}
🔥 {{leads_hot_sin_contactar}} leads HOT sin contactar - URGENTE
{{/if}}

{{#if nps_negativo > 0}}
😞 {{nps_negativo}} clientes dejaron feedback negativo - Revisar
{{/if}}

════════════════════════════════════════════════════════════
📈 TENDENCIAS (vs 7 días anteriores)
────────────────────────────────────────────────────────────
Ingresos:         {{tendencia_ingresos}} {{emoji_tendencia_ingresos}}
Reservas:         {{tendencia_reservas}} {{emoji_tendencia_reservas}}
Conversión:       {{tendencia_conversion}} {{emoji_tendencia_conversion}}
Ticket promedio:  {{tendencia_ticket}} {{emoji_tendencia_ticket}}

════════════════════════════════════════════════════════════
👥 DESEMPEÑO DEL EQUIPO
────────────────────────────────────────────────────────────
🥇 Top Agente:    {{top_agente_nombre}} ({{top_agente_ventas}} ventas)
🏆 Top Venta:     {{top_venta_destino}} - ${{top_venta_monto}} USD
⭐ Cliente VIP del día: {{cliente_vip}}

════════════════════════════════════════════════════════════
🎯 OBJETIVOS DEL MES (Progreso)
────────────────────────────────────────────────────────────
Meta Ingresos:    ${{meta_ingresos}} → ${{actual_ingresos}} ({{progreso_ingresos}}%)
                  {{barra_progreso_ingresos}}
                  
Meta Reservas:    {{meta_reservas}} → {{actual_reservas}} ({{progreso_reservas}}%)
                  {{barra_progreso_reservas}}

Días restantes:   {{dias_restantes}} días

════════════════════════════════════════════════════════════
💡 INSIGHTS Y RECOMENDACIONES
────────────────────────────────────────────────────────────
{{insights_automaticos}}

════════════════════════════════════════════════════════════
Reporte generado automáticamente a las {{hora_generacion}}
Dashboard completo: https://efig.co/dashboard
════════════════════════════════════════════════════════════
```

### 🛠️ Workflow para Reportes

```sql
-- Query 1: Métricas principales (últimas 24h)
SELECT 
  COUNT(DISTINCT r.id_reserva) as reservas_count,
  COUNT(DISTINCT r.id_cliente) as clientes_count,
  SUM(r.precio) as ingresos_dia,
  AVG(r.precio) as ticket_promedio,
  COUNT(CASE WHEN p.estado = 'completado' THEN 1 END) as pagos_completados,
  SUM(CASE WHEN p.estado = 'completado' THEN p.monto ELSE 0 END) as monto_pagos,
  COUNT(CASE WHEN p.estado = 'pendiente' THEN 1 END) as pagos_pendientes,
  SUM(CASE WHEN p.estado = 'pendiente' THEN p.monto ELSE 0 END) as monto_pendiente
FROM reservas r
LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
WHERE r.fecha_creacion >= NOW() - INTERVAL '24 hours';

-- Query 2: Top 5 destinos (última semana)
SELECT 
  r.destino,
  COUNT(*) as count_reservas,
  SUM(r.precio) as revenue
FROM reservas r
WHERE r.fecha_creacion >= NOW() - INTERVAL '7 days'
GROUP BY r.destino
ORDER BY revenue DESC
LIMIT 5;

-- Query 3: Embudo de conversión
SELECT 
  COUNT(DISTINCT l.id) as leads_total,
  COUNT(DISTINCT CASE WHEN l.contactado = true THEN l.id END) as leads_contactados,
  COUNT(DISTINCT r.id_reserva) as reservas_total,
  COUNT(DISTINCT CASE WHEN p.estado = 'completado' THEN r.id_reserva END) as pagos_completados
FROM leads l
LEFT JOIN clientes c ON l.email = c.email
LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
WHERE l.fecha_creacion >= NOW() - INTERVAL '7 days';

-- Query 4: Alertas
SELECT 
  (SELECT COUNT(*) FROM pagos WHERE estado = 'pendiente' AND fecha_limite <= NOW() + INTERVAL '24 hours') as pagos_vencen_hoy,
  (SELECT COUNT(*) FROM reservas WHERE estado = 'pendiente' AND fecha_creacion <= NOW() - INTERVAL '48 hours') as reservas_sin_confirmar,
  (SELECT COUNT(*) FROM leads WHERE clasificacion = 'HOT' AND contactado = false) as leads_hot_sin_contactar;

-- Query 5: Top agente
SELECT 
  a.nombre,
  COUNT(r.id_reserva) as ventas,
  SUM(r.precio) as revenue_total
FROM agentes a
LEFT JOIN reservas r ON a.id_agente = r.id_agente
WHERE r.fecha_creacion >= NOW() - INTERVAL '7 days'
GROUP BY a.id_agente, a.nombre
ORDER BY revenue_total DESC
LIMIT 1;
```

### 📨 Workflow n8n Completo

```
WORKFLOW: "Daily Executive Report"
Trigger: Schedule (Cron: 0 7 * * *) // Todos los días 7:00 AM

1. Cron Trigger
2. PostgreSQL: Query métricas principales
3. PostgreSQL: Query top destinos
4. PostgreSQL: Query embudo conversión
5. PostgreSQL: Query alertas
6. PostgreSQL: Query top agente
7. PostgreSQL: Query objetivos del mes
8. Function: Calcular cambios vs ayer
9. Function: Generar insights automáticos (IA)
   ```javascript
   // Análisis automático con reglas
   const insights = [];
   
   if (conversionRate < 50) {
     insights.push("⚠️ Tasa de conversión baja. Revisar: 1) Tiempos de respuesta, 2) Calidad de leads, 3) Ofertas competitivas");
   }
   
   if (ticketPromedio > ticketPromedioSemanaAnterior * 1.15) {
     insights.push("✅ Ticket promedio subió 15%. Estrategia de upselling funcionando.");
   }
   
   if (leadsHotSinContactar > 5) {
     insights.push("🚨 URGENTE: Hay leads de alta prioridad sin atender. Asignar más agentes.");
   }
   
   if (destinoTop === destinoTopSemanaAnterior) {
     insights.push(`📍 ${destinoTop} mantiene liderazgo. Considerar aumentar inventario.`);
   }
   
   return insights.join("\n");
   ```
10. Function: Renderizar template de reporte
11. Split Into Branches:
    ├─ Send Email (CEO, Gerente Ventas, Gerente Ops)
    ├─ Send Slack (Canal #daily-reports)
    ├─ Send Telegram (Grupo de Management)
    └─ Save PDF (Google Drive)
12. PostgreSQL: Log reporte enviado
```

---

## 🎨 BONUS: Workflow de Contenido Automatizado

### 🎯 Objetivo
Generar contenido de marketing automáticamente usando IA.

### 📝 Generación de Blog Posts

```
WORKFLOW: "AI Content Generator"
Trigger: Schedule (Semanal - Lunes 9 AM)

Flujo:
1. Schedule Trigger
2. PostgreSQL: Obtener top 3 destinos de la semana
3. AI Agent (GPT-4): Generar outline de blog post
   Prompt:
   "Eres un experto en turismo. Crea un outline detallado para un blog post sobre
   '{{destino}}' que incluya:
   - Título SEO-friendly
   - 5 secciones principales
   - Tips prácticos
   - Mejores meses para viajar
   - Presupuesto estimado
   - CTA para reservar con EFIG"

4. AI Agent: Generar contenido completo (sección por sección)
5. AI Agent: Generar meta description SEO
6. AI Agent: Sugerir 10 palabras clave
7. Function: Formatear en Markdown
8. HTTP Request: Crear imagen destacada (DALL-E / Midjourney)
9. WordPress API: Crear draft de blog post
10. Slack: Notificar a marketing para revisión
11. Google Sheets: Log de contenido generado
```

### 📱 Generación de Posts para Redes Sociales

```
WORKFLOW: "Social Media Auto-Post"
Trigger: Webhook (cuando se crea reserva a destino nuevo)

Flujo:
1. Webhook Trigger (nueva reserva)
2. Check: ¿Es destino que no se ha posteado en 30 días?
3. AI Agent: Generar copy para redes sociales
   Prompt:
   "Crea 3 variaciones de post para redes sociales sobre {{destino}}:
   
   1. Instagram (max 150 chars + 10 hashtags)
   2. Facebook (max 280 chars + CTA)
   3. Twitter/X (max 280 chars + emoji)
   
   Tono: Inspirador, aventurero, FOMO
   Incluir: Precio desde ${{precio_minimo}}
   CTA: Reserva ahora en efig.co/{{destino_slug}}"

4. DALL-E: Generar imagen del destino
5. Function: Resize imagen (Instagram: 1080x1080, FB: 1200x630)
6. Split Branches:
   ├─ Instagram API: Crear post
   ├─ Facebook API: Crear post
   └─ Twitter API: Crear tweet
7. Google Sheets: Log de posts publicados
8. Slack: Notificar a marketing
```

---

¿Quieres que continúe con más workflows o profundizamos en alguno específico? 🚀
