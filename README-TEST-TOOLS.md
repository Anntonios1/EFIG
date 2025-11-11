# Test de Tool Calls - Copilot AI Agent

## 📋 Descripción
Workflow de n8n que prueba el soporte de **Tool Calls** en el servidor Copilot API.

## 🎯 Características del Workflow

### AI Agent con 3 Tools:
1. **listar_clientes** - Lista todos los clientes (sin parámetros)
2. **buscar_cliente** - Busca por ID o nombre (parámetros: cliente_id, nombre)
3. **listar_reservas_cliente** - Lista reservas de un cliente (parámetro: cliente_id)

### Flujo:
```
Webhook Trigger → Extract Input → AI Agent (con 3 tools) → Format Response → Respond
                                       ↓
                                 OpenAI Model
                              (Copilot API Server)
```

## 📥 Importar en n8n

1. Ve a tu n8n Cloud: https://teampikiautomation.app.n8n.cloud
2. Click en "+" → "Import from file"
3. Selecciona: `workflow-test-tool-calls.json`
4. Configura credenciales:
   - **PostgreSQL Cloud**: Tu conexión a postgres_cloud
   - **Copilot API**: 
     - API Key: `cualquier-valor` (no se valida)
     - Base URL: `http://34.66.86.207:8002/v1`

## 🧪 Ejecutar Tests

### Opción 1: Desde PowerShell
```powershell
.\test-workflow-tools.ps1
```

### Opción 2: Manualmente con curl
```bash
curl -X POST https://teampikiautomation.app.n8n.cloud/webhook/test-tool-calls \
  -H "Content-Type: application/json" \
  -d '{"message": "lista todos los clientes"}'
```

### Opción 3: Desde n8n
1. Activa el workflow
2. Ve a la URL del webhook
3. Envía POST con body:
```json
{
  "message": "busca el cliente C-0036"
}
```

## 🔍 Casos de Test

| Test | Mensaje | Tools Esperados |
|------|---------|----------------|
| 1 | "lista todos los clientes" | `listar_clientes` |
| 2 | "busca el cliente C-0036" | `buscar_cliente` |
| 3 | "muéstrame las reservas del cliente C-0036" | `buscar_cliente` → `listar_reservas_cliente` |
| 4 | "busca el cliente Jeyler y dime cuántas reservas tiene" | `buscar_cliente` → `listar_reservas_cliente` |
| 5 | "hola, cómo estás?" | Ninguno (solo chat) |

## 🔧 Verificar Tool Calls

### Ver logs del servidor Copilot:
```bash
docker logs copilot_api_cloud --tail 50 | grep "🔧 Tools"
```

Deberías ver líneas como:
```
🔧 Tools incluidos: 3
🔧 Tool calls detectados: 1
```

### Respuesta esperada del servidor:
```json
{
  "choices": [{
    "finish_reason": "tool_calls",
    "message": {
      "role": "assistant",
      "tool_calls": [{
        "id": "call_abc123",
        "type": "function",
        "function": {
          "name": "listar_clientes",
          "arguments": "{}"
        }
      }]
    }
  }]
}
```

## ⚙️ Configuración del AI Agent

El prompt del agente:
```
Eres un asistente virtual para el sistema EFIG (Eventos, Fiestas, Invitados, Gestión).

Tu trabajo es ayudar a gestionar:
- 👥 Clientes (crear, buscar, listar)
- 📅 Reservas (crear, consultar)
- 💰 Pagos (registrar, verificar)

Usa las herramientas disponibles para acceder a la base de datos.
```

Modelo: **gpt-4**  
Temperature: **0.3** (para respuestas más deterministas)  
Max Tokens: **2000**

## 🐛 Troubleshooting

### Error: "Connection refused"
- Verifica que el servidor Copilot esté corriendo:
  ```bash
  docker ps | grep copilot_api_cloud
  ```

### Error: "Invalid JSON"
- Revisa los logs del servidor para ver qué está recibiendo
- El servidor ahora tiene mejor manejo de errores y mostrará el raw data

### El AI no usa las tools
- Verifica que el prompt sea claro
- Asegúrate de que las descripciones de las tools sean específicas
- Prueba con temperatura más baja (0.1 - 0.3)

### Tool calls no aparecen en la respuesta
- Revisa que el servidor tenga la versión actualizada (con soporte de tools)
- Verifica los logs: `docker logs copilot_api_cloud --tail 100`

## 📊 Métricas Esperadas

Con tool calls funcionando correctamente:

- ✅ **Latencia**: 2-5 segundos por request
- ✅ **Tool detection**: 95%+ en prompts claros
- ✅ **Múltiples tools**: Soportado (hasta 10 tools simultáneos)
- ✅ **Modelos**: Los 10 modelos disponibles funcionan con tools

## 🎉 Éxito Esperado

Si todo funciona, verás:
1. ✅ Respuesta del webhook con datos formateados
2. ✅ En logs: "🔧 Tools incluidos: X"
3. ✅ En logs: "🔧 Tool calls detectados: Y"
4. ✅ Datos correctos de PostgreSQL en la respuesta

## 📝 Notas

- El workflow usa **Workflow Tools** en lugar de Code Tools para mejor debugging
- Cada tool tiene su propio nodo de PostgreSQL executeQuery
- El AI Agent decide automáticamente qué tools usar basado en el mensaje
- La sesión se mantiene para conversaciones multi-turn

## 🔗 URLs

- Servidor Copilot: http://34.66.86.207:8002
- Webhook: https://teampikiautomation.app.n8n.cloud/webhook/test-tool-calls
- n8n Cloud: https://teampikiautomation.app.n8n.cloud

---

Creado: 2025-11-06  
Servidor: openwebui-server (GCP)  
PostgreSQL: postgres_cloud (puerto 5433)
