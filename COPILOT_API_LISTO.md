# 🚀 GitHub Copilot API Server - Funcionando!

## ✅ Estado Actual

El servidor está **completamente funcional** y corriendo en Docker:

```bash
Container: copilot_api_server
Puerto: 8000
Estado: Running
Health: OK
```

## 📡 Endpoints Disponibles

### 1. Health Check
```bash
GET http://localhost:8000/health
```

### 2. Listar Modelos
```bash
GET http://localhost:8000/v1/models
```

**Respuesta:**
```json
{
  "object": "list",
  "data": [
    {"id": "gpt-4", "object": "model", "owned_by": "github-copilot"}
  ]
}
```

### 3. Chat Completions (Compatible con OpenAI)

**Non-Streaming:**
```powershell
$body = @{ 
  messages = @(@{ 
    role = "user"
    content = "Hola, como estas?" 
  }) 
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://localhost:8000/v1/chat/completions" `
  -Method Post `
  -Body $body `
  -ContentType "application/json"
```

**Streaming:**
```powershell
$body = @{ 
  messages = @(@{ 
    role = "user"
    content = "Cuenta una historia corta" 
  })
  stream = $true
} | ConvertTo-Json -Depth 10

Invoke-WebRequest -Uri "http://localhost:8000/v1/chat/completions" `
  -Method Post `
  -Body $body `
  -ContentType "application/json"
```

## 🔌 Uso desde n8n

### URL del servidor dentro de Docker:
```
http://copilot-api:8000/v1/chat/completions
```

### Nodo HTTP Request - Configuración:

**Method:** POST  
**URL:** `http://copilot-api:8000/v1/chat/completions`  
**Authentication:** None  
**Send Body:** Yes  
**Body Content Type:** JSON

**Body:**
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "user",
      "content": "Tu pregunta aquí"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 4000,
  "stream": false
}
```

### Extraer respuesta (Nodo Code):
```javascript
// Obtener la respuesta del GPT-4
const response = $input.item.json;
const mensaje = response.choices[0].message.content;

return {
  json: {
    respuesta: mensaje,
    modelo: response.model,
    timestamp: new Date().toISOString()
  }
};
```

## 🎯 Ejemplo Completo: Chat con Telegram

1. **Telegram Trigger** → Recibe mensaje
2. **HTTP Request** → Envía a Copilot API
3. **Code** → Extrae respuesta
4. **Telegram** → Envía respuesta al usuario

## 💡 Características

✅ **Gratis** - Usa tu token de GitHub Copilot  
✅ **Compatible con OpenAI** - Misma API que GPT  
✅ **Streaming** - Respuestas en tiempo real  
✅ **GPT-4** - Modelo más avanzado  
✅ **Dockerizado** - Fácil de desplegar  
✅ **Persistente** - Se reinicia automáticamente  

## 🔧 Comandos Útiles

### Ver logs:
```bash
docker logs copilot_api_server
docker logs copilot_api_server --tail 50
docker logs copilot_api_server -f
```

### Reiniciar servidor:
```bash
docker-compose restart copilot-api
```

### Reconstruir imagen:
```bash
docker-compose build copilot-api
docker-compose up -d copilot-api
```

### Ver estado:
```bash
docker ps | grep copilot
docker-compose ps copilot-api
```

## 🧪 Pruebas Realizadas

✅ Non-streaming: Funciona perfectamente  
✅ Streaming: Funciona perfectamente  
✅ Docker: Container corriendo estable  
✅ Health check: Respondiendo correctamente  
✅ Integración con n8n: Lista para usar  

## 📝 Notas Importantes

1. **Encoding**: Evita caracteres especiales en el JSON (ñ, á, é, etc.)
2. **Red Docker**: Desde n8n usa `http://copilot-api:8000`
3. **Desde fuera**: Usa `http://localhost:8000`
4. **Token**: Ya está configurado en `.env`

## 🎉 ¡Todo Listo!

El servidor está funcionando y listo para alimentar tus workflows de n8n con GPT-4 gratis! 🚀
