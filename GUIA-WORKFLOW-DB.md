# 🗄️ Workflow con Base de Datos - Guía Completa

## 📋 Funcionalidades

Este workflow maneja:

### ✅ 1. Registrar Clientes
**Cómo usarlo:**
```
Usuario: "Quiero registrarme
Nombre: Juan Pérez
Email: juan@email.com
Teléfono: +57 300 1234567"
```

**El bot:**
- Extrae automáticamente los datos
- Los inserta en PostgreSQL tabla `clientes`
- Genera ID automático (C-0001, C-0002, etc.)
- Confirma el registro

### ✅ 2. Consultar Clientes
**Cómo usarlo:**
```
Usuario: "consultar clientes"
o
Usuario: "ver clientes"
o
Usuario: "buscar clientes"
```

**El bot:**
- Lee los últimos 10 clientes de PostgreSQL
- Los formatea bonito
- Los muestra con ID, nombre, email, teléfono

### ✅ 3. Conversación General
**Cómo usarlo:**
```
Usuario: "Hola, ¿cuánto cuesta un vuelo a Cartagena?"
```

**El bot:**
- Usa GPT-4 para responder
- Da información sobre destinos, precios
- Guía al usuario

---

## 🔧 Cómo Funciona (Flujo Técnico)

```
Telegram Trigger
    ↓
    ├─→ ¿Contiene "registrar"? 
    │       ↓ SÍ
    │   Extraer Datos (Code)
    │       ↓
    │   Postgres INSERT
    │       ↓
    │   Confirmar Registro (Code)
    │       ↓
    │   Enviar Respuesta (Telegram)
    │
    ├─→ ¿Contiene "consultar|clientes|buscar"?
    │       ↓ SÍ
    │   Postgres SELECT
    │       ↓
    │   Formatear Resultados (Code)
    │       ↓
    │   Enviar Respuesta (Telegram)
    │
    └─→ Ninguna palabra clave
            ↓
        AI Agent (GPT-4)
            ↓
        Preparar Respuesta (Code)
            ↓
        Enviar Respuesta (Telegram)
```

---

## 🚀 Instalación

### 1. Importar el Workflow

1. Abre n8n Cloud: https://jeylermartinez.app.n8n.cloud
2. Ve a **Workflows**
3. Click **Import from File**
4. Selecciona: `workflow-db-completo.json`
5. Click **Import**

### 2. Configurar Credenciales

Necesitas configurar **3 credenciales** en total:

#### A. Telegram Trigger
1. Click en el nodo **"Telegram Trigger"**
2. En **Credentials**, selecciona tu credencial de Telegram
3. Guarda

#### B. Registrar Cliente (Postgres)
1. Click en el nodo **"Registrar Cliente"**
2. En **Credentials**, selecciona **"Postgres Cloud GCP"**
   - Host: `34.66.86.207`
   - Port: `5433`
   - Database: `n8n_db`
   - User: `n8n`
   - Password: `n8npass`
3. En **Schema**, selecciona: `public`
4. En **Table**, selecciona: `clientes`
5. Guarda

#### C. Consultar Clientes (Postgres)
1. Click en el nodo **"Consultar Clientes"**
2. En **Credentials**, selecciona **"Postgres Cloud GCP"**
3. Guarda

#### D. Ollama Chat Model
1. Click en el nodo **"Ollama Chat Model"**
2. En **Credentials**, selecciona **"Copilot API GCP"**
   - Base URL: `http://34.66.86.207:8002`
3. En **Model**, escribe: `gpt-4`
4. Guarda

#### E. Enviar Respuesta (Telegram)
1. Click en el nodo **"Enviar Respuesta"**
2. En **Credentials**, selecciona tu credencial de Telegram
3. Guarda

### 3. Guardar y Activar

1. Click **"Save"** (arriba a la derecha)
2. Activa el workflow (switch verde)

---

## 🧪 Casos de Prueba

### Prueba 1: Registrar un Cliente

**Envía este mensaje a tu bot:**
```
Quiero registrarme
Nombre: María García
Email: maria@email.com
Teléfono: +57 310 9876543
```

**Respuesta esperada:**
```
✅ ¡Registro Exitoso!

👤 Nombre: María García
📧 Email: maria@email.com
📱 Teléfono: +57 310 9876543
🆔 ID Cliente: C-0002

¡Bienvenido a EFIG Vuelos! ✈️
```

### Prueba 2: Consultar Clientes

**Envía:**
```
consultar clientes
```

**Respuesta esperada:**
```
📋 Últimos Clientes Registrados:

1. María García
   📧 maria@email.com
   📱 +57 310 9876543
   🆔 C-0002
   📅 04/11/2025

2. Juan Pérez
   📧 juan@email.com
   📱 +57 300 1234567
   🆔 C-0001
   📅 03/11/2025
```

### Prueba 3: Pregunta General

**Envía:**
```
Hola, ¿cuánto cuesta un vuelo a San Andrés?
```

**Respuesta esperada:**
```
¡Hola! 😊 

Los vuelos a San Andrés desde Bogotá tienen un costo aproximado entre $350.000 y $600.000 COP, dependiendo de la temporada y anticipación. 🏖️

Las mejores ofertas se encuentran reservando con 2-3 meses de anticipación. ✈️

¿Te gustaría registrarte para ayudarte con tu reserva?
```

---

## 🔧 Personalización

### Agregar Más Operaciones de Base de Datos

#### Crear Reserva:

1. Agrega un nodo **"IF"** que detecte "reserva"
2. Agrega un nodo **"Code"** para extraer datos
3. Agrega un nodo **"Postgres"**:
   - Operation: **Insert**
   - Table: **reservas**
   - Columns:
     ```json
     {
       "id_cliente": "={{ $json.id_cliente }}",
       "destino": "={{ $json.destino }}",
       "fecha_salida": "={{ $json.fecha_salida }}",
       "fecha_regreso": "={{ $json.fecha_regreso }}",
       "estado": "pendiente"
     }
     ```

#### Consultar Reservas:

1. Agrega un nodo **"Postgres"**:
   - Operation: **Execute Query**
   - Query:
     ```sql
     SELECT 
       r.id_reserva,
       c.nombre_completo,
       r.destino,
       r.fecha_salida,
       r.fecha_regreso,
       r.estado
     FROM reservas r
     JOIN clientes c ON r.id_cliente = c.id_cliente
     ORDER BY r.fecha_reserva DESC
     LIMIT 10
     ```

#### Registrar Pago:

1. Nodo **"Postgres"** para INSERT en tabla `pagos`
2. Nodo **"Postgres"** para UPDATE estado de reserva a "confirmada"

---

## 🐛 Troubleshooting

### Error: "Could not find column"
**Solución:** Verifica que los nombres de columnas en el nodo Postgres coincidan exactamente con tu base de datos:
- `nombre_completo` (no `nombre`)
- `id_cliente` (no `cliente_id`)

### Error: "Connection refused"
**Solución:** 
1. Verifica que PostgreSQL esté corriendo en GCP
2. Verifica firewall: puerto 5433 abierto
3. Prueba conexión desde tu PC:
   ```powershell
   docker exec -it n8n_postgres psql -h 34.66.86.207 -p 5433 -U n8n -d n8n_db
   ```

### Error: "Webhook not found"
**Solución:** 
1. Desactiva y reactiva el workflow
2. Verifica en Telegram que el webhook esté activo:
   ```powershell
   Invoke-RestMethod -Uri "https://api.telegram.org/bot<TU_TOKEN>/getWebhookInfo"
   ```

### Bot no responde
**Solución:**
1. Ve a **Executions** en n8n Cloud
2. Busca ejecuciones fallidas
3. Click para ver el error detallado
4. Verifica que todas las credenciales estén configuradas

---

## 📊 Ver Datos en la Base de Datos

### Desde PuTTY (en la VM):

```bash
# Conectar a PostgreSQL
docker exec -it postgres_cloud psql -U n8n -d n8n_db

# Ver clientes
SELECT * FROM clientes;

# Ver reservas
SELECT * FROM reservas;

# Salir
\q
```

### Desde PowerShell (tu PC):

```powershell
# Ver clientes
docker exec -it n8n_postgres psql -h 34.66.86.207 -p 5433 -U n8n -d n8n_db -c "SELECT * FROM clientes;"
```

---

## 🎯 Próximos Pasos

Una vez que este workflow funcione:

1. **Agregar operación de reservas**
2. **Agregar operación de pagos**
3. **Agregar búsqueda de cliente por nombre**
4. **Agregar actualización de datos**
5. **Agregar eliminación de registros**
6. **Integrar con sistemas de pago**

---

**¡Todo listo! Importa el workflow y prueba registrando un cliente.** 🚀
