# 🚀 Inicio Rápido - LLM Agent con Google Gemini

## ✨ ¿Por qué Gemini?

- **GRATIS**: 1,500 requests/día sin costo
- **Rápido**: Gemini 1.5 Flash es muy veloz
- **Potente**: Similar a GPT-4 en calidad
- **Sin tarjeta**: No necesitas tarjeta de crédito

---

## Paso 1: Obtener API Key de Google AI (3 min)

### 1.1 Ir a Google AI Studio

Abre tu navegador y ve a:
```
https://aistudio.google.com/app/apikey
```

### 1.2 Crear API Key

1. Inicia sesión con tu cuenta de Google
2. Clic en **"Create API Key"**
3. Selecciona un proyecto existente o crea uno nuevo
4. Copia la API Key (empieza con `AIza...`)
5. Guárdala en un lugar seguro

**IMPORTANTE**: La API Key se muestra solo una vez, pero puedes crear más si la pierdes.

---

## Paso 2: Configurar Credencial en n8n (2 min)

### 2.1 Crear credencial Google PaLM API

1. Abre n8n → http://localhost:5678
2. Clic en tu avatar (esquina superior derecha)
3. **Settings → Credentials**
4. Clic en **"Add Credential"**
5. Busca **"Google PaLM API"** (es la misma credencial para Gemini)
6. Pega tu API Key en el campo **"API Key"**
7. **Save**

---

## Paso 3: Importar Workflow (1 min)

1. En n8n → **Workflows** (menú lateral)
2. Clic en **"+ Add workflow"**
3. Clic en los **tres puntos (⋮)** arriba a la derecha
4. **Import from File**
5. Selecciona:
   ```
   C:\Users\teamp\Documents\N8N FINAL\workflows\llm_agent_gemini_n8n.json
   ```
6. El workflow se abre en el editor

---

## Paso 4: Configurar Nodos (2 min)

### 4.1 Nodo "Google Gemini API"

1. Haz clic en el nodo **"Google Gemini API"**
2. En el panel derecho, busca **"Credential to connect with"**
3. Selecciona la credencial **"Google PaLM API"** que creaste
4. (Ya está configurado para usar Gemini 1.5 Flash)

### 4.2 Nodo "Ejecutar SQL en Postgres"

1. Haz clic en el nodo **"Ejecutar SQL en Postgres"**
2. En el panel derecho, busca **"Credential to connect with"**
3. Selecciona tu credencial de Postgres existente:
   - Host: `host.docker.internal`
   - Port: `5432`
   - Database: `n8n_db`
   - User: `n8n`
   - Password: `n8npass`

---

## Paso 5: Activar el Workflow (30 seg)

1. Busca el toggle **"Inactive"** en la esquina superior derecha
2. Haz clic para cambiar a **"Active"** (debe ponerse verde)
3. Guarda con **Ctrl+S** o el botón Save

✅ **¡Listo! El agente con Gemini está activo.**

---

## Paso 6: Probar (1 min)

Abre PowerShell y ejecuta:

```powershell
# Test 1: Registrar un cliente
$body = @{ mensaje = "Registra un cliente llamado María García, email maria@test.com, teléfono +34666777888" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"
```

**Resultado esperado:**
```json
{
  "success": true,
  "message": "Cliente María García registrado exitosamente",
  "action": "insert",
  "table": "clientes",
  "sql_executed": "INSERT INTO clientes ...",
  "result": [...]
}
```

---

## Más Pruebas

```powershell
# Test 2: Consultar clientes
$body = @{ mensaje = "Muéstrame todos los clientes registrados" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Test 3: Crear reserva
$body = @{ mensaje = "Crea una reserva de vuelo para C-0001 a Madrid del 15 al 20 de noviembre, precio 320 euros" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Test 4: Consulta compleja
$body = @{ mensaje = "Muéstrame las reservas pendientes con precio mayor a 300 euros" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Test 5: Análisis
$body = @{ mensaje = "¿Cuántos clientes VIP tenemos y cuál es el total de sus reservas?" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"
```

---

## Script Automatizado de Pruebas

Ejecuta múltiples pruebas automáticamente:

```powershell
.\scripts\test_llm_agent.ps1
```

---

## Verificar en la Base de Datos

```powershell
# Ver clientes registrados
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_cliente, nombre_completo, email FROM clientes ORDER BY id DESC LIMIT 5;"

# Ver reservas creadas
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_reserva, id_cliente, destino, precio FROM reservas ORDER BY id DESC LIMIT 5;"
```

---

## 💡 Ventajas de Gemini 1.5 Flash

### Velocidad
- **2-3x más rápido** que GPT-4
- Respuesta típica: 1-2 segundos

### Costo
- **GRATIS** hasta 1,500 requests/día
- Suficiente para desarrollo y pruebas
- Para producción: muy económico ($0.075 por 1M tokens)

### Calidad
- **Excelente en SQL** y tareas estructuradas
- Sigue instrucciones precisamente
- Genera JSON válido consistentemente

### Contexto
- Ventana de contexto: **1 millón de tokens**
- Puedes incluir todo el esquema de DB en el prompt

---

## 🔄 Comparación con OpenAI

| Característica | Gemini 1.5 Flash | GPT-4o |
|---------------|------------------|---------|
| **Costo (desarrollo)** | Gratis (1,500/día) | ~$0.01/request |
| **Velocidad** | ⚡⚡⚡ Muy rápido | ⚡⚡ Rápido |
| **Calidad SQL** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Contexto** | 1M tokens | 128K tokens |
| **Requiere tarjeta** | ❌ No | ✅ Sí |
| **Límite de rate** | 1,500/día gratis | Según plan |

**Recomendación**: Usa Gemini para desarrollo/pruebas, considera GPT-4 si necesitas features específicas.

---

## 🛠️ Personalización

### Cambiar el modelo

En el nodo "Google Gemini API", cambia la URL por:

**Gemini 1.5 Pro** (más potente, más lento):
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent
```

**Gemini 1.5 Flash** (default, recomendado):
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent
```

### Ajustar temperatura

En el nodo "Preparar Contexto LLM", en `generationConfig`:
- `temperature: 0.1` → Más determinístico (recomendado para SQL)
- `temperature: 0.5` → Balanceado
- `temperature: 0.9` → Más creativo

### Aumentar tokens de salida

Si necesitas respuestas más largas:
```json
"generationConfig": {
  "temperature": 0.2,
  "maxOutputTokens": 4096
}
```

---

## 🚨 Troubleshooting

### Error: "API key not valid"
- **Solución**: Verifica que copiaste la API key completa
- Crea una nueva en https://aistudio.google.com/app/apikey

### Error: "Resource exhausted"
- **Causa**: Superaste el límite de 1,500 requests/día
- **Solución**: Espera hasta mañana o configura billing en Google Cloud

### El LLM devuelve texto en vez de JSON
- **Causa**: Gemini a veces incluye markdown
- **Solución**: Ya está manejado en el nodo "Parsear Decisión del LLM"

### SQL inválido o con errores
- **Solución**: 
  - Verifica que el System Prompt está completo
  - Añade ejemplos más específicos de tu caso de uso
  - Reduce temperature a 0.1

### Respuesta lenta (>5 segundos)
- **Causa**: Usar Gemini Pro en vez de Flash
- **Solución**: Usa Gemini 1.5 Flash (default)

---

## 📊 Límites y Quotas

### Tier Gratis (sin tarjeta)
- **Requests**: 1,500 por día
- **Tokens por minuto**: 32,000
- **Requests por minuto**: 15

### Con Billing (Pay-as-you-go)
- **Requests**: Sin límite
- **Costo Gemini Flash**: $0.075 por 1M tokens input, $0.30 por 1M output
- **Costo Gemini Pro**: $1.25 por 1M tokens input, $5.00 por 1M output

---

## 🎯 Siguientes Pasos

Una vez funcionando:

1. **Conectar con Telegram/WhatsApp** para interfaz conversacional
2. **Añadir validación de SQL** para producción
3. **Implementar memoria** (contexto entre mensajes)
4. **Dashboard web** para visualizar interacciones
5. **Logs de auditoría** de todas las operaciones

---

## 📚 Documentación Adicional

- **Guía completa del LLM Agent**: `LLM_AGENT.md`
- **50+ ejemplos de prompts**: `prompts/ejemplos_usuario.md`
- **Esquema de DB**: `SCHEMA.md`
- **Documentación oficial Gemini**: https://ai.google.dev/docs

---

## 🎉 ¡Ya está!

Ahora tienes un agente IA potente y **GRATIS** que gestiona tu base de datos con lenguaje natural.

**Prueba con tu equipo:**
```
"Muéstrame las reservas de hoy"
"¿Cuántos clientes nuevos tenemos esta semana?"
"Crea una reserva para el cliente C-0001"
"Dame un reporte de ventas del mes"
```

¿Necesitas ayuda con algo específico? ¡Dime y te ayudo!
