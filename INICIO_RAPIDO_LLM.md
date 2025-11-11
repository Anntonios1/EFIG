# 🚀 Inicio Rápido - LLM Agent Orchestrator

## ¿Qué vas a lograr?

En 10 minutos tendrás un asistente IA que gestiona tu base de datos con lenguaje natural.

---

## Requisitos Previos

- ✅ PostgreSQL corriendo (`docker ps` debe mostrar `n8n_postgres`)
- ✅ n8n corriendo en http://localhost:5678
- ⏳ API Key de OpenAI (o usar alternativa local con Ollama)

---

## Paso 1: Obtener API Key de OpenAI (5 min)

### Opción A: OpenAI (Recomendado - Rápido y preciso)

1. Ve a https://platform.openai.com/api-keys
2. Inicia sesión o crea una cuenta
3. Clic en **"Create new secret key"**
4. Copia la key (empieza con `sk-...`)
5. **IMPORTANTE**: Guárdala en un lugar seguro (no se vuelve a mostrar)

**Costo estimado**: ~$0.01-0.03 por solicitud (muy barato para pruebas)

### Opción B: Ollama Local (Gratis pero más lento)

Si prefieres no usar OpenAI, puedo prepararte la versión con Ollama que corre localmente.

---

## Paso 2: Configurar Credencial en n8n (2 min)

1. Abre n8n → http://localhost:5678
2. Clic en tu avatar (esquina superior derecha)
3. **Settings → Credentials**
4. Clic en **"Add Credential"**
5. Busca **"OpenAI"**
6. Pega tu API Key
7. **Save**

---

## Paso 3: Importar Workflow (1 min)

1. En n8n → **Workflows** (menú lateral)
2. Clic en **"+ Add workflow"**
3. Clic en los **tres puntos (⋮)** arriba a la derecha
4. **Import from File**
5. Selecciona:
   ```
   C:\Users\teamp\Documents\N8N FINAL\workflows\llm_agent_orchestrator_n8n.json
   ```
6. El workflow se abre en el editor

---

## Paso 4: Configurar Nodos (2 min)

### 4.1 Nodo "OpenAI - LLM Agent"

1. Haz clic en el nodo **"OpenAI - LLM Agent"**
2. En el panel derecho, busca **"Credential to connect with"**
3. Selecciona la credencial de OpenAI que creaste
4. (Opcional) Ajusta la temperatura si quieres (0.3 = más determinístico, 0.7 = más creativo)

### 4.2 Nodo "Ejecutar SQL en Postgres"

1. Haz clic en el nodo **"Ejecutar SQL en Postgres"**
2. En el panel derecho, busca **"Credential to connect with"**
3. Selecciona tu credencial de Postgres:
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

✅ **¡Listo! El agente está activo.**

---

## Paso 6: Probar (1 min)

Abre PowerShell y ejecuta:

```powershell
# Test 1: Registrar un cliente
$body = @{ mensaje = "Registra un cliente llamado Test Agent, email agent@test.com, teléfono +34999888777" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"
```

**Resultado esperado:**
```json
{
  "success": true,
  "message": "Cliente Test Agent registrado exitosamente con ID C-XXXX",
  "action": "insert",
  "table": "clientes",
  "result": [...]
}
```

---

## Más Pruebas

```powershell
# Test 2: Consultar clientes
$body = @{ mensaje = "Muéstrame todos los clientes" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Test 3: Crear reserva
$body = @{ mensaje = "Crea una reserva de vuelo para C-0001 a Barcelona del 15 al 20 de noviembre, precio 280 euros" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"

# Test 4: Consulta analítica
$body = @{ mensaje = "¿Cuántos clientes VIP tenemos?" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5678/webhook/agente" -Method Post -Body $body -ContentType "application/json"
```

---

## Script Automatizado de Pruebas

Para ejecutar múltiples pruebas automáticamente:

```powershell
.\scripts\test_llm_agent.ps1
```

Este script ejecuta 7 pruebas diferentes y muestra los resultados.

---

## Verificar en la Base de Datos

```powershell
# Ver clientes registrados
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT * FROM clientes ORDER BY id DESC LIMIT 5;"

# Ver reservas creadas
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT * FROM reservas ORDER BY id DESC LIMIT 5;"
```

---

## 🎉 ¡Funciona!

Ahora puedes:
- **Registrar clientes** con lenguaje natural
- **Crear reservas** describiendo qué quieres
- **Consultar datos** haciendo preguntas
- **Actualizar registros** con instrucciones simples

---

## Siguientes Pasos

### 1. Conectar con Telegram/WhatsApp

Para que cualquier persona del equipo pueda interactuar con el agente desde el móvil:

```
Usuario en Telegram → Bot → n8n (LLM Agent) → Postgres → Respuesta
```

Dime si quieres que implemente esto.

### 2. Añadir Validación de Seguridad

Para producción, añadir:
- Whitelist de operaciones permitidas
- Validación de SQL antes de ejecutar
- Aprobación manual para DELETE/UPDATE masivo
- Logs de auditoría

### 3. Memoria/Contexto

Que el agente recuerde conversaciones previas:
```
Usuario: "Registra un cliente Juan Pérez"
Agente: "Cliente registrado con ID C-1234"
Usuario: "Ahora créale una reserva a París"
Agente: "Entendido, creo reserva para C-1234 a París"
```

---

## Troubleshooting

### Error: "OpenAI credential not found"
- **Solución**: Configura la credencial de OpenAI (Paso 2)

### Error: "Postgres connection failed"
- **Solución**: Verifica que PostgreSQL está corriendo (`docker ps`)
- Verifica credencial de Postgres en el nodo

### El LLM genera SQL inválido
- **Causa**: Prompt poco claro o modelo no adecuado
- **Solución**: 
  - Usa GPT-4o en vez de GPT-3.5
  - Ajusta el System Prompt en el nodo "Preparar Contexto LLM"

### Respuesta lenta (>10 segundos)
- **Causa**: OpenAI API puede estar saturado
- **Solución**: 
  - Reduce maxTokens a 1000
  - Considera usar Ollama local para mayor velocidad

---

## 📚 Documentación Completa

- **Guía detallada**: `LLM_AGENT.md`
- **Ejemplos de prompts**: `prompts/ejemplos_usuario.md`
- **Esquema de DB**: `SCHEMA.md`
- **Script de pruebas**: `scripts/test_llm_agent.ps1`

---

¿Necesitas ayuda con algún paso? ¡Dime y te guío!
