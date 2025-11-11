# ✅ Configuración Completada - N8N Cloud

## 🎉 Servicios Desplegados en Google Cloud

**IP del Servidor:** `34.66.86.207`

### ✅ PostgreSQL Database
- **Host:** `34.66.86.207`
- **Port:** `5433`
- **Database:** `n8n_db`
- **User:** `n8n`
- **Password:** `n8npass`
- **SSL Mode:** `disable`
- **Estado:** ✅ Funcionando (1 cliente en la tabla)

### ✅ Copilot API Server (Ollama Compatible)
- **Base URL:** `http://34.66.86.207:8002`
- **Modelo:** `gpt-4`
- **Estado:** ✅ Funcionando
- **Test:** `curl http://34.66.86.207:8002/api/tags`

---

## 📝 Pasos para Configurar n8n Cloud

### 1. Configurar Credencial de PostgreSQL

1. Ve a tu n8n Cloud: https://jeylermartinez.app.n8n.cloud
2. Click en **Settings** (⚙️) → **Credentials**
3. Click en **Add Credential**
4. Busca y selecciona **"Postgres"**
5. Llena los datos:
   ```
   Name: Postgres Cloud GCP
   Host: 34.66.86.207
   Port: 5433
   Database: n8n_db
   User: n8n
   Password: n8npass
   SSL: Disable
   ```
6. Click **"Save"** y luego **"Test"** para verificar la conexión

### 2. Configurar Credencial de Ollama (Copilot API)

1. En **Settings** → **Credentials**
2. Click **Add Credential**
3. Busca **"Ollama"**
4. Llena los datos:
   ```
   Name: Copilot API GCP
   Base URL: http://34.66.86.207:8002
   ```
5. Click **"Save"**

### 3. Actualizar tu Workflow EFIG

1. Ve a **Workflows** → Abre tu workflow **"EFIG"**
2. **Telegram Trigger:** Ya está configurado ✅
3. **Ollama Chat Model:**
   - Click en el nodo
   - En **Credentials**, selecciona **"Copilot API GCP"**
   - En **Model**, escribe: `gpt-4`
4. **Postgres Tool:**
   - Click en el nodo
   - En **Credentials**, selecciona **"Postgres Cloud GCP"**
   - En **Schema**, selecciona: `public`
   - En **Table**, deja vacío o selecciona `clientes` si aparece
5. Click **"Save"** (arriba a la derecha)
6. **Activa el workflow** (switch verde)

---

## 🧪 Probar el Sistema

### Desde Telegram:
1. Abre Telegram y busca tu bot: **@EFIGVUELOS_bot**
2. Envía un mensaje de prueba, por ejemplo:
   ```
   Hola, quiero información sobre vuelos
   ```
3. El bot debería responder usando GPT-4 a través de tu Copilot API

### Verificar en n8n Cloud:
- Ve a **Executions** para ver las ejecuciones del workflow
- Deberías ver cada mensaje de Telegram como una nueva ejecución

---

## 🔧 Comandos Útiles (desde PuTTY en la VM)

```bash
# Ver estado de los contenedores
cd ~/n8n-backend
docker ps

# Ver logs de PostgreSQL
docker logs postgres_cloud -f

# Ver logs de Copilot API
docker logs copilot_api_cloud -f

# Reiniciar servicios
docker-compose restart

# Detener servicios
docker-compose down

# Iniciar servicios
docker-compose up -d

# Ver datos en PostgreSQL
docker exec -it postgres_cloud psql -U n8n -d n8n_db -c "SELECT * FROM clientes;"

# Probar Copilot API
curl http://localhost:8002/api/tags
```

---

## 📊 Estructura de la Base de Datos

### Tabla: clientes
```sql
- id_cliente (VARCHAR, PK) - Auto-generado como C-0001, C-0002, etc.
- nombre_completo (TEXT, NOT NULL)
- email (VARCHAR)
- telefono (VARCHAR)
- fecha_registro (TIMESTAMP)
```

### Tabla: reservas
```sql
- id_reserva (VARCHAR, PK) - Auto-generado como R-0001, R-0002, etc.
- id_cliente (VARCHAR, FK)
- destino (VARCHAR)
- fecha_salida (DATE)
- fecha_regreso (DATE)
- estado (VARCHAR) - 'pendiente', 'confirmada', 'cancelada'
- fecha_reserva (TIMESTAMP)
```

### Tabla: pagos
```sql
- id_pago (VARCHAR, PK) - Auto-generado como P-0001, P-0002, etc.
- id_reserva (VARCHAR, FK)
- monto (DECIMAL)
- metodo_pago (VARCHAR)
- fecha_pago (TIMESTAMP)
```

---

## 🚀 Próximos Pasos

1. **Probar el bot** enviando mensajes desde Telegram
2. **Agregar más clientes** usando el AI Agent
3. **Crear reservas** a través del bot
4. **Monitorear ejecuciones** en n8n Cloud

---

## 🔒 Seguridad (Opcional - Para Producción)

### Restringir acceso a PostgreSQL:
```bash
# En Google Cloud Console > VPC Network > Firewall Rules
# Editar "allow-postgres-5433"
# Cambiar "Source IP ranges" de 0.0.0.0/0 a la IP de n8n Cloud
```

### Habilitar SSL en PostgreSQL:
```bash
# Editar docker-compose.yml y agregar certificados SSL
# Cambiar en n8n Cloud: SSL Mode = require
```

### Agregar autenticación al Copilot API:
```bash
# Modificar server_simple.py para requerir API key
```

---

## ✅ Checklist Final

- [x] PostgreSQL desplegado en Google Cloud
- [x] Copilot API desplegado en Google Cloud
- [x] Firewall configurado (puertos 5433, 8002)
- [x] Conexiones probadas desde internet
- [ ] Credenciales configuradas en n8n Cloud
- [ ] Workflow EFIG actualizado con nuevas credenciales
- [ ] Bot probado desde Telegram

---

## 📞 Troubleshooting

### Si el bot no responde:
1. Verifica que el workflow esté **activo** en n8n Cloud
2. Revisa **Executions** para ver si hay errores
3. Verifica los logs en la VM:
   ```bash
   docker logs copilot_api_cloud
   docker logs postgres_cloud
   ```

### Si no puede conectar a PostgreSQL:
1. Verifica el firewall: puerto 5433 abierto
2. Verifica que el contenedor esté corriendo: `docker ps`
3. Prueba desde la VM: `docker exec -it postgres_cloud psql -U n8n -d n8n_db`

### Si no puede conectar a Copilot API:
1. Verifica el firewall: puerto 8002 abierto
2. Verifica que el contenedor esté corriendo: `docker ps`
3. Prueba desde la VM: `curl http://localhost:8002/api/tags`

---

**¡Todo está listo! Ahora configura las credenciales en n8n Cloud y prueba tu bot.** 🚀
