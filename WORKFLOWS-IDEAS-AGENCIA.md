# 🔄 Workflows para Agencia de Viajes - Ideas y Arquitecturas

## 📋 Índice de Workflows
1. [Workflow 1: Atención al Cliente Omnicanal](#workflow-1-atención-al-cliente-omnicanal)
2. [Workflow 2: Sistema de Seguimiento Post-Venta](#workflow-2-sistema-de-seguimiento-post-venta)
3. [Workflow 3: Alertas y Notificaciones Inteligentes](#workflow-3-alertas-y-notificaciones-inteligentes)
4. [Workflow 4: Leads y Ventas Automáticas](#workflow-4-leads-y-ventas-automáticas)
5. [Workflow 5: Reportes Automáticos Diarios](#workflow-5-reportes-automáticos-diarios)

---

## WORKFLOW 1: Atención al Cliente Omnicanal

### 🎯 Objetivo
Centralizar todas las conversaciones de diferentes canales en un solo AI Agent inteligente.

### 📊 Arquitectura
```
┌─────────────────────────────────────────────────────────────┐
│                    CANALES DE ENTRADA                       │
├─────────────────────────────────────────────────────────────┤
│  Telegram  │  WhatsApp  │  Email  │  Web Chat  │  Facebook │
└─────┬──────┴──────┬─────┴────┬────┴──────┬─────┴─────┬─────┘
      │             │          │           │           │
      └─────────────┴──────────┴───────────┴───────────┘
                              ▼
              ┌───────────────────────────────┐
              │   Message Router & Parser     │
              │  - Detecta canal origen       │
              │  - Extrae ID cliente/chat     │
              │  - Normaliza formato          │
              └───────────────┬───────────────┘
                              ▼
              ┌───────────────────────────────┐
              │      Context Enrichment       │
              │  - Busca historial cliente    │
              │  - Carga reservas activas     │
              │  - Detecta idioma             │
              └───────────────┬───────────────┘
                              ▼
              ┌───────────────────────────────┐
              │        AI Agent (GPT-4)       │
              │  + 15 PostgreSQL Tools        │
              │  + Context: ultimas 5 msgs    │
              │  + System Prompt: Rol activo  │
              └───────────────┬───────────────┘
                              ▼
              ┌───────────────────────────────┐
              │      Response Formatter       │
              │  - Adapta formato al canal    │
              │  - Agrega botones si aplica   │
              │  - Sanitiza caracteres        │
              └───────────────┬───────────────┘
                              ▼
              ┌───────────────────────────────┐
              │      Response Sender          │
              │  - Envía por canal correcto   │
              │  - Registra en historial      │
              │  - Marca como leído           │
              └───────────────────────────────┘
```

### 🛠️ Nodos Necesarios en n8n
1. **Telegram Trigger** - Escucha mensajes de Telegram
2. **Webhook** - Recibe de WhatsApp Business API
3. **Email Trigger (IMAP)** - Lee emails entrantes
4. **Merge Node** - Combina todos los canales
5. **Switch Node** - Identifica canal origen
6. **PostgreSQL** - Busca cliente por teléfono/email/telegram_id
7. **Set Node** - Prepara contexto para AI
8. **AI Agent** - Procesa con Copilot + Tools
9. **Switch Node** - Rutea respuesta al canal correcto
10. **Telegram Send Message** - Responde por Telegram
11. **HTTP Request** - Responde por WhatsApp API
12. **Send Email** - Responde por email

### 📝 Variables de Contexto
```javascript
// Context que se pasa al AI Agent
{
  "canal": "telegram", // telegram | whatsapp | email | webchat
  "cliente": {
    "id": "C-0036",
    "nombre": "Jeyler Caro",
    "tipo": "frecuente",
    "idioma": "es",
    "historial_conversacion": [
      {"fecha": "2025-11-01", "tema": "consulta vuelo Miami"},
      {"fecha": "2025-10-15", "tema": "reserva confirmada Cartagena"}
    ]
  },
  "reservas_activas": [
    {
      "id": "R-0042",
      "destino": "Cartagena",
      "fecha_salida": "2025-12-15",
      "estado": "confirmado"
    }
  ],
  "mensaje_actual": "Hola, necesito cambiar mi vuelo a Cartagena",
  "timestamp": "2025-11-06T14:30:00Z"
}
```

### 🎨 System Prompt Sugerido
```
Eres el asistente de EFIG Travel Agency atendiendo por {{$json.canal}}.

Cliente actual:
- Nombre: {{$json.cliente.nombre}}
- Tipo: {{$json.cliente.tipo}}
- Historial reciente: {{$json.cliente.historial_conversacion}}

Reservas activas del cliente:
{{$json.reservas_activas}}

Mensaje del cliente:
"{{$json.mensaje_actual}}"

INSTRUCCIONES:
1. Si es cliente frecuente/VIP, saluda reconociendo su lealtad
2. Si tiene reservas activas, refiérelas cuando sea relevante
3. Usa las herramientas disponibles para consultar/modificar datos
4. Mantén respuestas cortas (max 3 párrafos) para {{$json.canal}}
5. Si es Telegram/WhatsApp, usa emojis moderadamente
6. Si es email, sé más formal y detallado

Responde de forma profesional y eficiente.
```

---

## WORKFLOW 2: Sistema de Seguimiento Post-Venta

### 🎯 Objetivo
Automatizar seguimientos personalizados después de cada reserva para mejorar experiencia y obtener feedback.

### 📊 Arquitectura
```
┌─────────────────────────────────────────┐
│     TRIGGER: Nueva Reserva Creada       │
│  (PostgreSQL Monitor cada 5 minutos)    │
└────────────────┬────────────────────────┘
                 ▼
┌─────────────────────────────────────────┐
│    Obtener Detalles de Reserva + Cliente│
│  - JOIN clientes, reservas, pagos       │
└────────────────┬────────────────────────┘
                 ▼
┌─────────────────────────────────────────┐
│       Schedule Follow-up Messages       │
│  - T+1 hora: Confirmación recibida      │
│  - T+24h: Recordatorio de documentos    │
│  - T-7 días: Pre-viaje (clima, tips)    │
│  - T-1 día: Recordatorio check-in       │
│  - T+1 día post-viaje: Feedback NPS     │
└────────────────┬────────────────────────┘
                 ▼
┌─────────────────────────────────────────┐
│     Cola de Mensajes Programados        │
│  (Google Sheets o PostgreSQL tabla)     │
└────────────────┬────────────────────────┘
                 ▼
┌─────────────────────────────────────────┐
│   CRON Workflow: Envía Mensajes         │
│   (Ejecuta cada hora)                   │
└─────────────────────────────────────────┘
```

### 📧 Templates de Mensajes

#### 1. Confirmación Inmediata (T+1 hora)
```
¡Hola {{nombre}}! 👋

Tu reserva ha sido confirmada exitosamente:

🎫 **Reserva:** {{id_reserva}}
✈️ **Destino:** {{destino}}
📅 **Fecha:** {{fecha_salida}}
💰 **Total:** ${{precio}} {{moneda}}
✅ **Estado Pago:** {{estado_pago}}

{{#if pago_pendiente}}
⚠️ Recuerda completar tu pago antes del {{fecha_limite}} para mantener tu reserva.
{{/if}}

**Próximos pasos:**
1. Revisa tu email - enviamos vouchers y detalles
2. Prepara documentos (pasaporte válido 6 meses)
3. Descarga nuestra app para gestión fácil

¿Dudas? Responde este mensaje. Estoy aquí 24/7. 😊

- EFIG Assistant
```

#### 2. Recordatorio Documentos (T+24 horas)
```
Hola {{nombre}}, 📄

Tu viaje a **{{destino}}** está cada vez más cerca. Asegúrate de tener:

**Documentos requeridos:**
✅ Pasaporte (vigencia mínima 6 meses)
✅ Visa {{#if requiere_visa}}(requerida para {{destino}}){{else}}(no requerida){{/if}}
✅ Tarjeta de vacunación COVID-19
{{#if menor_edad}}
✅ Permiso notarial de viaje (menores de edad)
{{/if}}

**Recomendaciones:**
- Haz check-in online 24h antes
- Llega al aeropuerto 3 horas antes (vuelo internacional)
- Lleva copia digital de documentos

¿Necesitas ayuda con algo? ¡Escríbeme! 💬
```

#### 3. Pre-Viaje (T-7 días)
```
🌴 ¡{{nombre}}, tu viaje está a la vuelta de la esquina!

En 7 días estarás disfrutando de **{{destino}}**. Aquí algunos tips:

**Clima esperado:** {{clima}}
**Temperatura promedio:** {{temperatura}}
**Qué empacar:**
- {{lista_empaque}}

**Info útil del destino:**
- Moneda: {{moneda_local}}
- Voltaje: {{voltaje}}
- Zona horaria: {{timezone}}
- Números de emergencia: {{emergencias}}

**Tu itinerario:**
- Vuelo: {{aerolinea}} {{numero_vuelo}}
- Salida: {{hora_salida}} - {{aeropuerto_origen}}
- Llegada: {{hora_llegada}} - {{aeropuerto_destino}}
{{#if hotel}}
- Hotel: {{hotel_nombre}} - Check-in {{hotel_checkin}}
{{/if}}

¿Todo listo? Si necesitas hacer cambios de último minuto, ¡háblame! 📲
```

#### 4. Día del Viaje (T-1 día)
```
🎒 ¡Mañana es el gran día, {{nombre}}!

**Checklist final:**
☐ Check-in online completado
☐ Maletas preparadas (max {{peso_equipaje}}kg)
☐ Documentos en mano
☐ Seguro de viaje activo
☐ Notificaste a tu banco sobre viaje

**Detalles de mañana:**
🕐 Llega al aeropuerto: {{hora_recomendada_llegada}}
🛫 Vuelo: {{numero_vuelo}} - Gate {{gate}}
📍 Terminal: {{terminal}}

**Contactos de emergencia:**
- EFIG 24/7: +57 300 123 4567
- Hotel: {{hotel_telefono}}
- Aerolínea: {{aerolinea_telefono}}

¡Que tengas un viaje increíble! Estamos aquí si necesitas algo. ✈️😊
```

#### 5. Post-Viaje NPS (T+1 día después del regreso)
```
👋 ¡Bienvenido de vuelta, {{nombre}}!

Esperamos que hayas disfrutado tu viaje a **{{destino}}**. Tu opinión es muy valiosa para nosotros.

**¿Nos ayudas con 2 minutos de tu tiempo?**

Del 1 al 10, ¿qué tan probable es que recomiendes EFIG a un amigo?

[Botón: 😞 1-2-3] [Botón: 😐 4-5-6] [Botón: 😊 7-8] [Botón: 🤩 9-10]

{{#if nps >= 9}}
¡Gracias! Como agradecimiento, te enviamos un **cupón de $50 USD** para tu próxima reserva. 🎁
{{/if}}

¿Algo que mejorar? Cuéntanos en este chat.

PD: ¿Ya pensaste en tu próximo destino? 😏✈️
```

### 🛠️ Nodos n8n para Follow-ups

```
1. Schedule Trigger (Cron: 0 */1 * * *) // Cada hora
2. PostgreSQL: SELECT mensajes programados pendientes
3. Loop Over Items
4. Switch: Tipo de mensaje (confirmación | pre-viaje | nps)
5. Set: Preparar variables del template
6. Function: Renderizar template con datos
7. Switch: Canal preferido (telegram | whatsapp | email)
8. Telegram/WhatsApp/Email Node: Enviar
9. PostgreSQL: UPDATE mensaje como enviado
10. Wait 1 second (evitar rate limits)
```

---

## WORKFLOW 3: Alertas y Notificaciones Inteligentes

### 🎯 Objetivo
Monitorear eventos críticos y notificar proactivamente a clientes y equipo interno.

### 🚨 Alertas a Implementar

#### A. Alertas para Clientes

1. **Pago Pendiente (48h antes de vencer)**
```sql
SELECT r.*, c.nombre_completo, c.telefono, c.email
FROM reservas r
JOIN clientes c ON r.id_cliente = c.id_cliente
WHERE r.estado = 'pendiente'
  AND r.fecha_limite_pago <= NOW() + INTERVAL '48 hours'
  AND r.fecha_limite_pago > NOW()
  AND NOT EXISTS (
    SELECT 1 FROM notificaciones_enviadas 
    WHERE reserva_id = r.id_reserva 
    AND tipo = 'recordatorio_pago_48h'
  )
```
Mensaje:
```
⏰ Recordatorio de pago - {{nombre}}

Tu reserva {{id_reserva}} vence en 48 horas:
- Destino: {{destino}}
- Monto pendiente: ${{monto_pendiente}}
- Vence: {{fecha_limite}}

**Métodos de pago:**
[Botón: 💳 Pagar con Tarjeta]
[Botón: 🏦 Transferencia]
[Botón: 💵 PSE]

¿Necesitas más tiempo? Escríbeme y lo gestionamos.
```

2. **Cambio de Vuelo por Aerolínea**
```
🚨 Actualización importante - {{nombre}}

Tu vuelo {{numero_vuelo}} a {{destino}} ha sido modificado:

**Cambios:**
- ❌ Hora anterior: {{hora_old}}
- ✅ Nueva hora: {{hora_new}}
- Diferencia: {{diferencia}} horas

**Tus opciones:**
1. Aceptar nuevo horario (sin costo)
2. Cambiar a otro vuelo (sujeto a disponibilidad)
3. Cancelar y reembolso total

Responde con el número de tu opción o llámanos: +57 300 123 4567
```

3. **Alerta de Clima Extremo**
```
🌪️ Alerta de clima - {{destino}}

Hola {{nombre}}, detectamos clima adverso en {{destino}} para tu viaje del {{fecha}}:

**Pronóstico:**
- {{descripcion_clima}}
- Temperatura: {{temp_min}}-{{temp_max}}°C
- Precipitación: {{prob_lluvia}}%

**Recomendaciones:**
- {{recomendaciones}}

**¿Quieres considerar cambiar fechas?**
Podemos buscar alternativas sin costo adicional.
```

#### B. Alertas para Equipo Interno

1. **Reserva de Alto Valor sin Confirmar**
```
🔔 ALERTA: Reserva alta prioridad

Cliente: {{nombre}} ({{tipo_cliente}})
Reserva: {{id_reserva}}
Monto: ${{precio}} {{moneda}}
Creada: {{hace_X_horas}} horas
Estado: Pendiente confirmación

Acción requerida: Llamar al cliente en las próximas 2 horas.
Teléfono: {{telefono}}
```

2. **Cliente VIP sin Atención en 10 minutos**
```
⚠️ ESCALAMIENTO AUTOMÁTICO

Cliente VIP: {{nombre}}
Mensaje recibido hace: 10 minutos
Canal: {{canal}}
Último mensaje: "{{mensaje}}"

Asignar agente humano AHORA.
```

3. **Caída del Sistema de Pagos**
```
🚨 CRÍTICO: Sistema de pagos no responde

- Último pago exitoso: {{ultimo_pago_timestamp}}
- Intentos fallidos: {{intentos_fallidos}}
- Clientes afectados: {{clientes_count}}

Acción inmediata requerida.
Notificado a: CTO, Soporte Tier 2
```

### 🛠️ Workflow de Alertas en n8n

```
Nombre: "Monitor de Alertas Críticas"
Trigger: Cron (cada 5 minutos)

Flujo:
1. Cron Trigger (*/5 * * * *)
2. Split Into Branches (paralelo):
   
   Branch A: Pagos Pendientes
   ├─ PostgreSQL Query
   ├─ Filter (solo vencimientos próximos)
   ├─ Loop Items
   ├─ AI Agent (genera mensaje personalizado)
   └─ Send Notification (Telegram/WhatsApp)
   
   Branch B: Cambios de Vuelos
   ├─ HTTP Request (API aerolínea)
   ├─ Compare con DB
   ├─ Filter (solo cambios detectados)
   └─ Send Alert
   
   Branch C: Clima Extremo
   ├─ HTTP Request (Weather API)
   ├─ JOIN con reservas próximas (7 días)
   ├─ Filter (alertas severas)
   └─ Send Warning
   
   Branch D: Monitoreo Interno
   ├─ Check sistema pagos (health endpoint)
   ├─ Check mensajes sin responder >10min
   ├─ Check reservas alta prioridad
   └─ Slack/Email a equipo

3. Merge branches
4. Log todas las alertas en PostgreSQL
5. Error Handler (si algo falla, notificar a admin)
```

---

Continúa en siguiente archivo...
