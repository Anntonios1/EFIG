## Configuración AI Agent en n8n

### 1. Crear nuevo workflow
- Manual Trigger

### 2. Agregar nodo "AI Agent"
- **Agent Type**: Conversational Agent
- **Prompt**: "Eres un asistente para gestión de clientes"

### 3. Conectar "OpenAI Chat Model"
- **Credentials**: 
  - API Key: `sk-cualquiera` (no importa)
  - Organization ID: (dejar vacío)
- **Model**: `gpt-4`
- **Base URL**: `http://34.66.86.207:8002/v1`
- **Temperature**: 0.3

### 4. Agregar Tool "Listar Clientes"
Tipo: **Code Tool**

```javascript
// Tool: listar_clientes
const query = "SELECT cliente_id, nombre, email, telefono FROM clientes LIMIT 10";

// Aquí conectarías con PostgreSQL
return {
  clientes: [
    { cliente_id: "C-0036", nombre: "Jeyler", email: "test@test.com" }
  ]
};
```

### 5. Test
Input: "lista todos los clientes"

**Resultado esperado:**
- El AI Agent llamará automáticamente a la tool
- Ejecutará la consulta
- Devolverá los resultados formateados

---

## ¿Funciona el Tool Call?

**✅ SÍ** - Como vimos en los tests:

```
🎉 TOOL CALL DETECTADO!
Tool: listar_clientes
Arguments: {}
```

```
✅ Tool: buscar_cliente
✅ Arguments: {"cliente_id":"C-0036"}
```

El servidor Copilot API ahora:
- ✅ Acepta parámetro `tools` en el request
- ✅ Detecta tool calls en la respuesta de Copilot
- ✅ Parsea argumentos correctamente
- ✅ Funciona con múltiples tools
- ✅ Compatible con OpenAI API y Ollama API
