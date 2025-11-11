# Sistema con LLM Agent Orchestrator - Agencia de Viajes

## 🤖 ¿Qué es esto?

Un workflow donde un **LLM (Large Language Model)** actúa como agente inteligente que:
- Recibe mensajes en **lenguaje natural** del usuario
- Interpreta la **intención** (registrar cliente, crear reserva, consultar datos, etc.)
- Genera automáticamente el **SQL necesario**
- Ejecuta la operación en **PostgreSQL**
- Responde al usuario en **lenguaje natural**

### Ejemplo de uso

**Usuario escribe:**
```
"Registra un cliente llamado Carlos López, email carlos@test.com, teléfono +34987654321"
```

**El LLM:**
1. Analiza que es un INSERT en la tabla `clientes`
2. Genera: `INSERT INTO clientes (id_cliente, nombre_completo, email, telefono, tipo_cliente) VALUES ('C-1234', 'Carlos López', 'carlos@test.com', '+34987654321', 'nuevo')`
3. Lo ejecuta
4. Responde: "Cliente Carlos López registrado exitosamente con ID C-1234"

---

## 🚀 Opciones de LLM

He creado workflows para diferentes proveedores:

### 1. **Google Gemini** - ⭐ RECOMENDADO (Gratis)
- **Archivo**: `workflows/llm_agent_gemini_n8n.json`
- **Modelo**: Gemini 1.5 Flash (muy rápido) o Pro (más potente)
- **Costo**: **GRATIS** hasta 1,500 requests/día, luego $0.075/1M tokens
- **API Key**: Gratis en https://aistudio.google.com/app/apikey
- **Guía**: `INICIO_RAPIDO_GEMINI.md`
- **Ventajas**: Sin tarjeta, rápido, excelente en SQL

### 2. **OpenAI (GPT-4)** - Alternativa potente
- **Archivo**: `workflows/llm_agent_orchestrator_n8n.json`
- **Modelo**: GPT-4o (rápido y preciso)
- **Costo**: ~$0.01-0.03 por solicitud (requiere tarjeta)
- **API Key**: Necesitas cuenta en platform.openai.com
- **Guía**: `INICIO_RAPIDO_LLM.md`

### 3. **Anthropic Claude** - Alternativa potente
- **Archivo**: `workflows/llm_agent_claude_n8n.json` (próximamente)
- **Modelo**: Claude 3.5 Sonnet
- **Costo**: Similar a GPT-4
- **API Key**: Necesitas cuenta en console.anthropic.com

### 4. **Ollama (Local)** - Gratis y privado
- **Archivo**: `workflows/llm_agent_ollama_n8n.json` (próximamente)
- **Modelo**: Llama 3.1, Mistral, Qwen, etc.
- **Costo**: Gratis (corre en tu PC)
- **Requisitos**: Docker con Ollama o instalación local

---

## 📋 Configuración Rápida (OpenAI)

### Paso 1: Obtener API Key de OpenAI

1. Ve a https://platform.openai.com/api-keys
2. Crea una nueva API key
3. Cópiala (empieza con `sk-...`)

### Paso 2: Configurar credencial en n8n

1. En n8n → Settings → Credentials → Add Credential
2. Busca **"OpenAI"**
3. Pega tu API Key
4. Save

### Paso 3: Importar el workflow

1. Workflows → Import from File
2. Selecciona: `workflows/llm_agent_orchestrator_n8n.json`
3. En el nodo **"OpenAI - LLM Agent"**, selecciona la credencial creada
4. En el nodo **"Ejecutar SQL en Postgres"**, selecciona tu credencial de Postgres
5. **Activa el workflow** (toggle arriba)

### Paso 4: Probar

Desde PowerShell:

```powershell
# Ejemplo 1: Registrar un cliente
$body = @{ mensaje = "Registra un cliente llamado María García, email maria@test.com, teléfono +34111222333" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Ejemplo 2: Consultar clientes
$body = @{ mensaje = "Muéstrame todos los clientes registrados hoy" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Ejemplo 3: Crear una reserva
$body = @{ mensaje = "Crea una reserva de vuelo para el cliente C-0001 a Barcelona desde el 15 al 20 de noviembre, precio 320 euros" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Ejemplo 4: Consulta compleja
$body = @{ mensaje = "Muéstrame las reservas pendientes con destino a París" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"
```

---

## 🧠 Cómo funciona el LLM Agent

### Flujo del workflow

```
Usuario → Webhook → Preparar Contexto → LLM (analiza y decide) 
                                            ↓
                                    Genera JSON con acción + SQL
                                            ↓
                                    Parser extrae acción
                                            ↓
                                    Ejecuta SQL en Postgres
                                            ↓
                                    Formatea respuesta → Usuario
```

### Prompt del sistema (System Prompt)

El LLM recibe este contexto en cada solicitud:

```
Eres un asistente inteligente para una agencia de viajes.
Tu rol es interpretar las solicitudes del usuario y decidir qué acciones realizar en PostgreSQL.

Base de datos disponible:
- Tabla 'clientes': id_cliente, nombre_completo, email, telefono, documento, tipo_cliente
- Tabla 'reservas': id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio
- Tabla 'pagos': id_pago, id_reserva, monto, fecha, metodo, estado

Tu tarea:
1. Analiza la intención del usuario
2. Genera el SQL necesario
3. Devuelve JSON: {"action": "...", "table": "...", "sql": "...", "response_message": "..."}
```

### Ejemplo de respuesta del LLM

Usuario: "Registra un cliente Juan Pérez, email juan@test.com"

LLM devuelve:
```json
{
  "action": "insert",
  "table": "clientes",
  "sql": "INSERT INTO clientes (id_cliente, nombre_completo, email, tipo_cliente) VALUES ('C-' || floor(random()*9000+1000)::text, 'Juan Pérez', 'juan@test.com', 'nuevo') RETURNING *;",
  "response_message": "Cliente Juan Pérez registrado exitosamente"
}
```

---

## 🔐 Seguridad y Validación

### Riesgos de SQL Injection

⚠️ **IMPORTANTE**: El LLM genera SQL dinámicamente. Para producción:

1. **Validar el SQL generado** antes de ejecutarlo
2. **Whitelist de operaciones** permitidas
3. **Limitar permisos** del usuario de Postgres
4. **Logs de auditoría** de todas las operaciones

### Mejoras sugeridas (puedo implementarlas)

- Añadir nodo de validación que verifique el SQL antes de ejecutar
- Implementar rate limiting
- Añadir sistema de aprobación para operaciones críticas (DELETE, UPDATE masivo)
- Logs estructurados en tabla `auditoria`

---

## 📊 Casos de Uso

### 1. **Interfaz conversacional por chat**
```
Usuario: "¿Cuántos clientes VIP tenemos?"
LLM: "Tienes 12 clientes VIP registrados"
```

### 2. **Automatización de tareas**
```
Usuario: "Marca como confirmadas todas las reservas pendientes del cliente C-0001"
LLM: "He confirmado 3 reservas del cliente C-0001"
```

### 3. **Análisis y reportes**
```
Usuario: "Muéstrame el total de ventas de este mes agrupado por tipo de reserva"
LLM: [Genera SQL con GROUP BY y SUM, ejecuta y presenta resultados]
```

### 4. **Asistente para el equipo**
```
Usuario: "Dame un resumen de los vuelos que salen mañana"
LLM: [Consulta reservas con fecha_salida = mañana y muestra resumen]
```

---

## 🛠️ Personalización del Prompt

Puedes editar el System Prompt en el nodo **"Preparar Contexto LLM"** para:

- Cambiar el tono de las respuestas (formal/informal)
- Añadir reglas de negocio ("nunca borrar clientes VIP")
- Incluir validaciones ("precio máximo 5000 euros")
- Adaptar a tu flujo de trabajo específico

---

## 🚀 Siguientes pasos

1. **Probar el workflow básico** con OpenAI
2. **Añadir validación de SQL** para seguridad
3. **Conectar con Telegram/WhatsApp** para interfaz conversacional
4. **Implementar memoria/contexto** (que el LLM recuerde conversaciones previas)
5. **Añadir herramientas (tools)** para operaciones complejas (enviar emails, generar PDFs, etc.)

---

## 📚 Archivos relacionados

- **Workflow principal**: `workflows/llm_agent_orchestrator_n8n.json`
- **Esquema de DB**: `SCHEMA.md`
- **Scripts de prueba**: `scripts/test_llm_agent.ps1` (próximamente)
- **Ejemplos de prompts**: `prompts/ejemplos_usuario.txt` (próximamente)

---

## 💡 Tips y Troubleshooting

### El LLM no genera JSON válido
- Añade en el prompt: "SIEMPRE devuelve JSON válido sin markdown"
- Aumenta la temperatura a 0.1 para respuestas más deterministas

### SQL inválido o con errores
- Añade ejemplos específicos de tu esquema en el System Prompt
- Usa GPT-4o en vez de GPT-3.5 (más preciso en SQL)

### Costos elevados
- Usa Ollama local (gratis)
- Cachea respuestas comunes
- Limita maxTokens a 1000

---

¿Quieres que implemente alguna de estas mejoras ahora?
- Versión con Claude o Ollama
- Sistema de validación de SQL
- Interfaz de chat con Telegram
- Memoria/contexto entre mensajes
