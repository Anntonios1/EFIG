# 🔐 Configuración de Credenciales en n8n Cloud

## Problema: "No tiene acceso" al listar clientes

El workflow necesita que configures las credenciales de PostgreSQL en n8n Cloud para que el AI Agent pueda acceder a la base de datos.

---

## ✅ Pasos para Configurar

### 1. Accede a n8n Cloud
- URL: https://jeylermartinez.app.n8n.cloud
- Inicia sesión

### 2. Ve a Credenciales
- En el menú lateral izquierdo, haz clic en **"Credentials"** (Credenciales)
- O usa el atajo: `Ctrl + K` y escribe "credentials"

### 3. Crear Nueva Credencial PostgreSQL

#### Haz clic en **"+ Add Credential"**
- Busca: **"PostgreSQL"** o **"Postgres"**
- Selecciona: **"PostgreSQL account"**

#### Completa los datos:

```
Credential Name: PostgreSQL GCP
Host: 34.66.86.207
Port: 5433
Database: n8n_db
User: n8n
Password: n8npass
SSL Mode: disable
```

**⚠️ IMPORTANTE:** El nombre debe ser exactamente **"PostgreSQL GCP"** para que coincida con el workflow.

#### Guarda la credencial
- Haz clic en **"Test connection"** para verificar
- Si funciona, haz clic en **"Save"**

---

## 4. Importar el Workflow Actualizado

### Elimina el workflow anterior (si existe)
1. Ve a **Workflows**
2. Encuentra "EFIG - AI Orquestador"
3. Haz clic en los 3 puntos `⋮` → **Delete**

### Importa el nuevo workflow
1. Haz clic en **"+ Add workflow"**
2. Selecciona **"Import from file"**
3. Sube el archivo: `workflow-ai-final.json`
4. Haz clic en **"Import"**

---

## 5. Configurar el Bot de Telegram

### En el nodo "Telegram Trigger"
1. Haz clic en el nodo **"Telegram Trigger"**
2. En **"Credential to connect with"**, crea una nueva:
   - **Bot Token**: `8477198544:AAFRfPKaecCKjS_ooGOkmADQrZ7MedcwVjw`
   - **Name**: `EFIG Telegram Bot`

### En el nodo "Telegram Send"
1. Haz clic en el nodo **"Telegram Send"**
2. Selecciona la misma credencial: **"EFIG Telegram Bot"**

---

## 6. Configurar Ollama (Copilot API)

### En el nodo "Ollama GPT-4"
1. Haz clic en el nodo **"Ollama GPT-4"**
2. En **"Base URL"**, ingresa:
   ```
   http://34.66.86.207:8002
   ```
3. En **"Model"**, verifica que diga: `gpt-4`
4. En **"Temperature"**: `0.7`

---

## 7. Verificar Todos los Nodos PostgreSQL

Asegúrate de que **TODOS** estos nodos tengan la credencial "PostgreSQL GCP":

- ✅ **Get Clientes** - Lista clientes
- ✅ **Insert Cliente** - Registra nuevos clientes
- ✅ **Execute Query** - Consultas SQL personalizadas
- ✅ **Get Reservas** - Lista reservas
- ✅ **Insert Reserva** - Crea reservas

Para cada uno:
1. Haz clic en el nodo
2. En **"Credential to connect with"**
3. Selecciona: **"PostgreSQL GCP"**

---

## 8. Activar el Workflow

1. En la esquina superior derecha, cambia el switch de **"Inactive"** a **"Active"**
2. Verás un mensaje: "Workflow activated"

---

## 9. Probar el Bot

Abre Telegram y envía mensajes a **@EFIGVUELOS_bot**:

### Pruebas básicas:
```
Hola
```
Respuesta: Saludo del asistente

```
Lista los clientes
```
Respuesta: Lista de 16 clientes registrados

```
Muéstrame las reservas confirmadas
```
Respuesta: 8 reservas confirmadas con detalles

```
Quiero viajar a París
```
Respuesta: Información sobre París, precios, requisitos

---

## 🔧 Solución de Problemas

### Error: "No tiene acceso" o "Credential not found"
**Causa:** La credencial no está configurada o el nombre no coincide

**Solución:**
1. Verifica que la credencial se llame exactamente: **"PostgreSQL GCP"**
2. Verifica que todos los nodos PostgreSQL Tool tengan la credencial asignada
3. Haz clic en cada nodo y confirma que dice "PostgreSQL GCP" en credentials

### Error: "Cannot connect to database"
**Causa:** Datos de conexión incorrectos o firewall

**Solución:**
1. Verifica los datos de conexión:
   - Host: `34.66.86.207`
   - Port: `5433` (no 5432)
   - Database: `n8n_db`
   - User: `n8n`
   - Password: `n8npass`
2. Verifica que el firewall esté abierto en GCP
3. Prueba la conexión desde tu PC:
   ```bash
   telnet 34.66.86.207 5433
   ```

### Error: "Model not found" en Ollama
**Causa:** La URL de Ollama es incorrecta

**Solución:**
1. Verifica la URL en el nodo "Ollama GPT-4"
2. Debe ser: `http://34.66.86.207:8002`
3. Prueba manualmente:
   ```powershell
   Invoke-RestMethod -Uri "http://34.66.86.207:8002/api/tags"
   ```

### Bot no responde en Telegram
**Causa:** Workflow no está activado o webhook no configurado

**Solución:**
1. Verifica que el workflow esté **Active** (switch verde)
2. Verifica el webhook de Telegram:
   ```powershell
   Invoke-RestMethod -Uri "https://api.telegram.org/bot8477198544:AAFRfPKaecCKjS_ooGOkmADQrZ7MedcwVjw/getWebhookInfo"
   ```
3. Debe mostrar: `url: https://jeylermartinez.app.n8n.cloud/webhook/...`

---

## 📋 Checklist Final

Antes de probar, verifica:

- [ ] Credencial "PostgreSQL GCP" creada y probada
- [ ] Credencial "EFIG Telegram Bot" creada
- [ ] Workflow importado correctamente
- [ ] Nodo "Telegram Trigger" con credencial configurada
- [ ] Nodo "Telegram Send" con credencial configurada
- [ ] Nodo "Ollama GPT-4" con URL: http://34.66.86.207:8002
- [ ] Todos los 5 nodos PostgreSQL Tool con credencial "PostgreSQL GCP"
- [ ] Workflow **ACTIVADO** (switch verde)
- [ ] Base de datos con 16 clientes y 17 reservas

---

## 🎯 Resultado Esperado

Cuando envíes **"Lista los clientes"** al bot, deberías recibir:

```
📋 Clientes Registrados (16 en total):

1. 🆔 C-0001 - Ana Perez
   📧 ana@email.com | 📱 318-1234567
   
2. 🆔 C-0003 - María González Pérez
   📧 maria.gonzalez@email.com | 📱 320-1111111
   
3. 🆔 C-0005 - Carlos Andrés Rodríguez
   📧 carlos.rodriguez@email.com | 📱 315-2222222

[... 13 clientes más ...]

✨ ¿En qué más puedo ayudarte? Puedo:
- Crear nuevas reservas
- Consultar disponibilidad
- Informar sobre destinos
- Procesar pagos
```

---

## 🚀 Siguientes Pasos

Una vez que funcione:

1. **Prueba consultas complejas:**
   - "Quiero viajar a Dubai en mayo con mi familia"
   - "Necesito información sobre visa americana"
   - "Cuáles son las reservas pendientes"

2. **Crea nuevos clientes:**
   - "Soy Pedro García, email pedro@email.com, teléfono 318-7777777"

3. **Registra reservas:**
   - "Quiero reservar para Carlos Rodríguez un viaje a Cancún del 15 al 22 de diciembre"

4. **Explora funciones:**
   - Pregunta por hoteles en París
   - Solicita información sobre tours en Cartagena
   - Consulta sobre requisitos de visa Schengen

---

**¡Listo! Tu agencia de viajes con IA está funcionando! 🎉✈️🌎**
