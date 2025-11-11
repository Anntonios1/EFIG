# GitHub Copilot API Server

Servidor API compatible con OpenAI que usa GitHub Copilot como backend.
Perfecto para usar GPT-4 en n8n, Telegram bots, y cualquier aplicación que soporte OpenAI API.

## 🚀 Características

- ✅ Compatible 100% con OpenAI API
- ✅ Streaming y non-streaming
- ✅ GPT-4, GPT-4o, GPT-4o-mini
- ✅ Cache de tokens inteligente
- ✅ Listo para Docker
- ✅ Logs detallados
- ✅ Health checks

## 📦 Instalación

### Opción 1: Python directo

```bash
cd copilot-api-server

# Instalar dependencias
pip install -r requirements.txt

# Configurar token
cp .env.example .env
# Edita .env y pon tu token de GitHub Copilot

# Iniciar servidor
python server.py
```

### Opción 2: Docker

```bash
cd copilot-api-server

# Construir imagen
docker build -t copilot-api-server .

# Ejecutar
docker run -d \
  --name copilot-api \
  -p 8000:8000 \
  -e GITHUB_COPILOT_TOKEN=ghu_tu_token_aqui \
  copilot-api-server
```

### Opción 3: Docker Compose (recomendado)

Actualiza tu `docker-compose.yml` principal y ejecuta:
```bash
docker-compose up -d copilot-api
```

## 🔑 Obtener Token de GitHub Copilot

1. Ve a GitHub Settings → Developer Settings
2. Crea un Personal Access Token con permisos de Copilot
3. El token debe empezar con `ghu_`
4. Cópialo en `.env` o como variable de entorno

## 🌐 Endpoints

### GET /v1/models
Lista modelos disponibles

**Ejemplo:**
```bash
curl http://localhost:8000/v1/models
```

**Respuesta:**
```json
{
  "object": "list",
  "data": [
    {"id": "gpt-4o", "object": "model", "owned_by": "github-copilot"},
    {"id": "gpt-4", "object": "model", "owned_by": "github-copilot"}
  ]
}
```

### POST /v1/chat/completions
Chat completions (streaming o non-streaming)

**Ejemplo (curl):**
```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [
      {"role": "user", "content": "Hola, ¿cómo estás?"}
    ],
    "stream": false
  }'
```

**Ejemplo (PowerShell):**
```powershell
$body = @{
    model = "gpt-4o"
    messages = @(
        @{
            role = "user"
            content = "¿Cuál es la capital de Francia?"
        }
    )
    temperature = 0.7
    stream = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/v1/chat/completions" `
  -Method Post `
  -Body $body `
  -ContentType "application/json"
```

## 🤖 Usar en n8n

### 1. Crear Credencial HTTP Request

En n8n:
1. Settings → Credentials → New
2. Tipo: **HTTP Request (Generic)**
3. Configuración:
   - **Name:** GitHub Copilot API
   - **Authentication:** None (o Header Auth si quieres)
   - **Base URL:** `http://localhost:8000` (o tu URL)

### 2. Usar en workflow

Agrega un nodo **HTTP Request**:
```json
{
  "url": "http://localhost:8000/v1/chat/completions",
  "method": "POST",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "model": "gpt-4o",
    "messages": [
      {
        "role": "system",
        "content": "Eres un asistente de agencia de viajes."
      },
      {
        "role": "user",
        "content": "{{ $json.mensaje }}"
      }
    ],
    "temperature": 0.7,
    "stream": false
  }
}
```

### 3. Parsear respuesta

La respuesta viene en formato OpenAI:
```javascript
// En un nodo Code o Set
const response = $input.item.json;
const mensaje = response.choices[0].message.content;
return { mensaje };
```

## 🔗 Integración con Telegram Bot

**Workflow completo:**
```
Telegram Trigger → HTTP Request (Copilot API) → Telegram Send Message
```

**HTTP Request:**
- URL: `http://localhost:8000/v1/chat/completions`
- Method: POST
- Body:
```json
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "user",
      "content": "{{ $json.message.text }}"
    }
  ]
}
```

**Telegram Send Message:**
- Chat ID: `{{ $node["Telegram Trigger"].json.message.chat.id }}`
- Text: `{{ $node["HTTP Request"].json.choices[0].message.content }}`

## 📊 Monitoreo

### Health Check
```bash
curl http://localhost:8000/health
```

### Ver logs
```bash
# Python
# Los logs aparecen en la consola

# Docker
docker logs -f copilot-api
```

## ⚙️ Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `GITHUB_COPILOT_TOKEN` | Token de GitHub Copilot (ghu_xxx) | **Requerido** |
| `HOST` | Host del servidor | `0.0.0.0` |
| `PORT` | Puerto del servidor | `8000` |
| `DEBUG` | Modo debug | `false` |

## 🎯 Modelos Disponibles

- `gpt-4o` - GPT-4 Omni (recomendado)
- `gpt-4` - GPT-4 clásico
- `gpt-4o-mini` - GPT-4 mini (más rápido)
- `gpt-3.5-turbo` - GPT-3.5 Turbo

## 🔒 Seguridad

⚠️ **Importante:** Este servidor NO tiene autenticación por defecto.

Para producción, considera:
- Agregar API key authentication
- Usar HTTPS (reverse proxy con nginx/caddy)
- Rate limiting
- Restricciones de IP

## 🐛 Troubleshooting

### Error: "Cliente no inicializado"
- Verifica que `GITHUB_COPILOT_TOKEN` esté configurado
- El token debe empezar con `ghu_`

### Error: "No se pudo obtener token"
- Verifica que el token sea válido
- Revisa que tengas permisos de Copilot activos

### Timeout en requests
- Aumenta `timeout_streaming` en el código
- Verifica tu conexión a internet

### n8n no puede conectarse
- Si usas Docker, asegúrate que n8n y copilot-api estén en la misma red
- Usa `host.docker.internal` en lugar de `localhost` si n8n está en Docker

## 📝 Ejemplo Completo

```python
import requests

response = requests.post(
    "http://localhost:8000/v1/chat/completions",
    json={
        "model": "gpt-4o",
        "messages": [
            {"role": "system", "content": "Eres un experto en SQL y PostgreSQL."},
            {"role": "user", "content": "¿Cómo hago un JOIN de 3 tablas?"}
        ],
        "temperature": 0.3,
        "stream": False
    }
)

result = response.json()
print(result["choices"][0]["message"]["content"])
```

## 🚀 Next Steps

1. Configura tu token en `.env`
2. Inicia el servidor: `python server.py`
3. Prueba con curl o PowerShell
4. Integra en n8n
5. Conecta con tu bot de Telegram

---

**¿Problemas?** Revisa los logs con `DEBUG=true`
