# 🤖 LLM Agent Orchestrator - Guía Completa

## ¿Qué hace el LLM?

El **LLM (Large Language Model)** actúa como un **orquestador inteligente** que:

1. ✅ **Entiende lenguaje natural** (no necesitas SQL)
2. ✅ **Analiza la intención** del usuario
3. ✅ **Genera consultas SQL** automáticamente
4. ✅ **Ejecuta operaciones** en PostgreSQL
5. ✅ **Almacena datos** en la base de datos
6. ✅ **Responde de forma conversacional**

---

## 📋 Ejemplos de lo que puede hacer

### 1. Registrar clientes
**Tú dices:**
> "Registra un cliente: Juan Perez, email juan@ejemplo.com, teléfono +57 300 123 4567"

**El LLM:**
- Analiza los datos
- Genera: `INSERT INTO clientes (nombre_completo, email, telefono, tipo_cliente) VALUES (...)`
- Ejecuta la query
- Responde: "✅ Cliente Juan Perez registrado con ID C-0007"

---

### 2. Consultar datos
**Tú dices:**
> "Muéstrame todos los clientes VIP"

**El LLM:**
- Genera: `SELECT * FROM clientes WHERE tipo_cliente = 'VIP'`
- Ejecuta la consulta
- Responde con la lista formateada

---

### 3. Crear reservas
**Tú dices:**
> "Crea una reserva para Juan Perez (C-0003) de Bogotá a Cartagena, del 20 al 25 de diciembre, precio $500"

**El LLM:**
- Extrae: id_cliente, origen, destino, fechas, precio
- Genera: `INSERT INTO reservas (...) VALUES (...)`
- Ejecuta y responde: "✅ Reserva R-0002 creada"

---

### 4. Registrar pagos
**Tú dices:**
> "Registra un pago de $250 para la reserva R-0002 con tarjeta"

**El LLM:**
- Genera: `INSERT INTO pagos (id_reserva, monto, metodo, estado) VALUES (...)`
- Ejecuta y actualiza la base de datos

---

### 5. Consultas complejas
**Tú dices:**
> "¿Cuánto ha pagado Juan Perez en total?"

**El LLM:**
- Genera: `SELECT SUM(p.monto) FROM pagos p JOIN reservas r ON ... WHERE r.id_cliente = 'C-0003'`
- Ejecuta y responde: "Juan Perez ha pagado $750 en total"

---

## 🔌 Canales de Interacción

El LLM puede recibir comandos desde:

### 1. **Telegram** (Recomendado)
```
Usuario: Hola, registra un cliente: Maria Lopez, maria@test.com
Bot LLM: ✅ Cliente Maria Lopez registrado con ID C-0008
```

### 2. **Webhook HTTP**
```bash
curl -X POST https://e149bd15a769.ngrok-free.app/webhook/agente \
  -H "Content-Type: application/json" \
  -d '{"mensaje": "Lista todos los clientes VIP"}'
```

### 3. **WhatsApp** (con Twilio)
Mismo flujo que Telegram

### 4. **Interfaz Web** (con formulario HTML)
Envía requests al webhook

---

## 🧠 Cómo funciona internamente

```
┌─────────────────┐
│  Usuario dice:  │
│ "Registra Juan" │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  LLM Analiza (GPT-4 / Gemini)      │
│  - Intención: REGISTRAR_CLIENTE     │
│  - Datos: {nombre: "Juan", ...}     │
│  - SQL: INSERT INTO clientes ...    │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Ejecuta en PostgreSQL              │
│  INSERT INTO clientes VALUES (...)  │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Responde al usuario                │
│  "✅ Cliente registrado C-0007"     │
└─────────────────────────────────────┘
```

---

## 📊 Datos que puede almacenar

### Clientes
```sql
INSERT INTO clientes (nombre_completo, email, telefono, documento, tipo_cliente)
VALUES ('Maria Lopez', 'maria@test.com', '+57 310 555 1234', '12345678', 'VIP');
```

### Reservas
```sql
INSERT INTO reservas (id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, precio)
VALUES ('C-0007', 'vuelo', 'Bogota', 'Cancun', '2025-12-20', '2025-12-27', 1200.00);
```

### Pagos
```sql
INSERT INTO pagos (id_reserva, monto, metodo, estado)
VALUES ('R-0005', 600.00, 'transferencia', 'completado');
```

---

## 🚀 Workflow creado

He generado el archivo:
**`workflows/telegram_llm_postgres_completo.json`**

Este workflow:
1. ✅ Recibe mensajes de Telegram
2. ✅ Los envía al LLM (OpenAI/Gemini)
3. ✅ El LLM analiza y genera SQL
4. ✅ Ejecuta las queries en PostgreSQL
5. ✅ Responde al usuario vía Telegram

---

## 🎯 Para usar con Gemini (gratis)

Cambia el nodo "HTTP Request - OpenAI" por:

**URL:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=TU_API_KEY`

**Body:**
```json
{
  "contents": [{
    "parts": [{
      "text": "{{ $json.system_prompt }}\n\nUsuario: {{ $json.mensaje_usuario }}"
    }]
  }],
  "generationConfig": {
    "temperature": 0.3,
    "responseMimeType": "application/json"
  }
}
```

---

## ✅ Ventajas del LLM Orchestrator

| Sin LLM | Con LLM |
|---------|---------|
| Escribir SQL manualmente | Hablar en lenguaje natural |
| Formularios rígidos | Conversación flexible |
| Un endpoint por acción | Un solo endpoint inteligente |
| Programar cada caso | El LLM adapta la lógica |

---

## 🧪 Prueba rápida

**PowerShell:**
```powershell
$body = @{
    mensaje = "Registra un cliente: Pedro Sanchez, email pedro@test.com, teléfono +57 320 999 8888"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://e149bd15a769.ngrok-free.app/webhook/agente" `
  -Method Post -Body $body -ContentType "application/json"
```

---

## 📝 Resumen

✅ **Sí, el LLM puede orquestar consultas Y almacenar datos**  
✅ **Funciona con PostgreSQL, MySQL, MongoDB, etc.**  
✅ **Puedes usarlo desde Telegram, WhatsApp, HTTP, etc.**  
✅ **No necesitas escribir SQL, solo hablar naturalmente**  
✅ **Ya tienes el workflow listo para importar**

**Importa el workflow y empieza a chatear con tu base de datos! 🚀**
