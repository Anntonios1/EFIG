# 🏗️ Guía de Reestructuración - Workflow EFIG AI Orquestador

## 📋 ÍNDICE
1. [Problemas Actuales y Soluciones](#problemas)
2. [Nueva Arquitectura del Workflow](#arquitectura)
3. [Configuración de Nodos](#nodos)
4. [System Prompt Mejorado](#prompt)
5. [Ejemplos de Uso](#ejemplos)

---

## 🔴 PROBLEMAS ACTUALES Y SOLUCIONES {#problemas}

### **Problema 0: "Cannot read properties of undefined (reading 'execute')"**
**Causa:** Usar tipo de nodo incorrecto (`n8n-nodes-base.postgresTool` no existe en n8n Cloud)

**Solución:** ✅ **SOLUCIONADO**
- ✅ Usar el tipo correcto: `@n8n/n8n-nodes-langchain.toolPostgres`
- ✅ Configurar credenciales PostgreSQL en cada nodo tool
- ✅ Usar operaciones correctas: `select`, `insert` (no `getAll`, `insert`)
- ✅ Agregar descripciones claras para que el AI entienda cuándo usar cada tool
- ✅ Archivo corregido: `workflow-cloud-correcto.json`

**Configuración correcta de nodos Postgres Tool:**
```json
{
  "parameters": {
    "operation": "select",  // NO "getAll"
    "table": "clientes",
    "limit": 50,
    "description": "Lista todos los clientes..."
  },
  "type": "@n8n/n8n-nodes-langchain.toolPostgres",  // CORRECTO
  "typeVersion": 1.2,
  "credentials": {
    "postgres": {
      "id": "postgres_gcp",
      "name": "PostgreSQL GCP"
    }
  }
}
```

**Credencial PostgreSQL requerida:**
- Nombre: **PostgreSQL GCP** (exacto)
- Host: `34.66.86.207`
- Port: `5433`
- Database: `n8n_db`
- User: `n8n`
- Password: `n8npass`
- SSL: `disable`

---

### **Problema 1: Inserts Fallando**
**Causa:** Los `$fromAI()` no funcionan bien para insertar datos estructurados.

**Solución:**
- Eliminar los `$fromAI()` de Insert Cliente e Insert Reserva
- Usar nodos intermedios de **Code/Set** para estructurar los datos
- Validar datos antes de insertar

---

### **Problema 2: Sin Control de Roles**
**Causa:** No hay distinción entre cliente y administrador.

**Solución:**
- Agregar tabla `usuarios` con campo `rol` (cliente/admin)
- Filtrar herramientas según rol en el prompt
- Implementar autenticación por Telegram ID

---

### **Problema 3: Execute Query No Se Usa**
**Causa:** El modelo no sabe cuándo necesita ejecutar SQL personalizado.

**Solución:**
- Simplificar: usar solo para casos específicos (búsquedas complejas)
- Dar ejemplos claros en el prompt
- Limitar tipos de queries (solo SELECT)

---

### **Problema 4: Sin Validaciones**
**Causa:** No hay control de datos antes de insertar.

**Solución:**
- Agregar nodo **Validation** entre AI Agent y los Insert
- Validar: emails, teléfonos, fechas, IDs existentes
- Respuestas de error claras

---

### **Problema 5: Memoria Poco Estructurada**
**Causa:** La memoria no guarda contexto del usuario actual.

**Solución:**
- Usar `sessionId` basado en Telegram User ID
- Guardar estado de conversación (esperando_datos, confirmando_reserva, etc.)
- Contextualizar respuestas con info del usuario logueado

---

## 🏗️ NUEVA ARQUITECTURA DEL WORKFLOW {#arquitectura}

```
┌─────────────────────────────────────────────────────────────┐
│                    TELEGRAM TRIGGER                          │
│              (Recibe mensaje del usuario)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│               IDENTIFICAR USUARIO (Code)                     │
│  - Extraer Telegram ID                                       │
│  - Buscar en DB: SELECT * FROM usuarios WHERE telegram_id=X  │
│  - Si no existe → registrar nuevo usuario (rol: cliente)     │
│  - Setear variables: user_id, rol, nombre                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                 SWITCH: ROL DEL USUARIO                      │
│                                                              │
│  ┌─────────────┐              ┌─────────────┐              │
│  │   CLIENTE   │              │    ADMIN    │              │
│  │  (Default)  │              │  (Completo) │              │
│  └──────┬──────┘              └──────┬──────┘              │
│         │                            │                      │
│         ▼                            ▼                      │
│  Herramientas:                Herramientas:                 │
│  - Ver mis reservas           - Ver TODAS reservas          │
│  - Crear reserva              - Crear reservas              │
│  - Ver mi perfil              - Ver/editar clientes         │
│  - Actualizar datos           - Execute Query               │
│                                - Estadísticas                │
└─────────────┬───────────────────────┬────────────────────────┘
              │                       │
              └───────────┬───────────┘
                          ▼
              ┌─────────────────────────┐
              │      AI AGENT           │
              │   (Google Gemini)       │
              │  + Postgres Memory      │
              │  + Tools filtradas      │
              └───────────┬─────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │   VALIDATION NODE       │
              │  (Validar datos antes   │
              │   de insertar)          │
              └───────────┬─────────────┘
                          │
              ┌───────────┴───────────┐
              ▼                       ▼
    ┌──────────────────┐    ┌──────────────────┐
    │ INSERT CLIENTE   │    │ INSERT RESERVA   │
    │  (Estructurado)  │    │  (Estructurado)  │
    └──────────────────┘    └──────────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │   TELEGRAM SEND          │
              │  (Respuesta final)       │
              └─────────────────────────┘
```

---

## ⚙️ CONFIGURACIÓN DE NODOS {#nodos}

### **0. CONFIGURACIÓN INICIAL: Credenciales y Conexiones**

#### **A. Credencial PostgreSQL**
**Pasos en n8n Cloud:**
1. Ve a **Credentials** → **+ Add Credential**
2. Busca: **"PostgreSQL"**
3. Configura:
   ```
   Credential Name: PostgreSQL GCP
   Host: 34.66.86.207
   Port: 5433
   Database: n8n_db
   User: n8n
   Password: n8npass
   SSL Mode: disable
   ```
4. **Test connection** → **Save**

#### **B. Credencial Telegram**
1. Ve a **Credentials** → **+ Add Credential**
2. Busca: **"Telegram"**
3. Configura:
   ```
   Credential Name: EFIG Telegram Bot
   Bot Token: 8477198544:AAFRfPKaecCKjS_ooGOkmADQrZ7MedcwVjw
   ```
4. **Save**

#### **C. Nodos Postgres Tool - Configuración Correcta**

**❌ INCORRECTO (genera error):**
```json
{
  "type": "n8n-nodes-base.postgresTool",  // NO EXISTE
  "parameters": {
    "operation": "getAll"  // NO FUNCIONA
  }
}
```

**✅ CORRECTO:**
```json
{
  "type": "@n8n/n8n-nodes-langchain.toolPostgres",
  "typeVersion": 1.2,
  "parameters": {
    "operation": "select",  // Para listar
    "table": "clientes",
    "limit": 50,
    "description": "Lista todos los clientes registrados. Muestra: id_cliente, nombre_completo, email, telefono, tipo_cliente."
  },
  "credentials": {
    "postgres": {
      "id": "postgres_gcp",
      "name": "PostgreSQL GCP"
    }
  }
}
```

**Operaciones disponibles:**
- `select` - Listar registros (reemplaza `getAll`)
- `insert` - Insertar registros
- Sin operación - Execute query personalizado

#### **D. Configurar Ollama Chat Model**
```json
{
  "type": "@n8n/n8n-nodes-langchain.lmChatOllama",
  "parameters": {
    "model": "gpt-4",
    "options": {
      "baseURL": "http://34.66.86.207:8002",
      "temperature": 0.7
    }
  }
}
```

#### **E. Cinco Tools PostgreSQL Necesarias**

**1. get_clientes** (SELECT)
```json
{
  "name": "get_clientes",
  "type": "@n8n/n8n-nodes-langchain.toolPostgres",
  "parameters": {
    "operation": "select",
    "table": "clientes",
    "limit": 50,
    "description": "Lista todos los clientes registrados. Muestra: id_cliente, nombre_completo, email, telefono, tipo_cliente (nuevo/frecuente/VIP), fecha_registro."
  },
  "credentials": { "postgres": { "name": "PostgreSQL GCP" } }
}
```

**2. insert_cliente** (INSERT)
```json
{
  "name": "insert_cliente",
  "type": "@n8n/n8n-nodes-langchain.toolPostgres",
  "parameters": {
    "operation": "insert",
    "table": "clientes",
    "description": "Registra un nuevo cliente. Campos requeridos: nombre_completo, email, telefono. Opcionales: documento, tipo_cliente. El id_cliente se genera automáticamente."
  },
  "credentials": { "postgres": { "name": "PostgreSQL GCP" } }
}
```

**3. get_reservas** (SELECT)
```json
{
  "name": "get_reservas",
  "type": "@n8n/n8n-nodes-langchain.toolPostgres",
  "parameters": {
    "operation": "select",
    "table": "reservas",
    "limit": 50,
    "description": "Lista todas las reservas. Muestra: id_reserva, id_cliente, tipo (vuelo/paquete), origen, destino, fecha_salida, fecha_regreso, estado (pendiente/confirmada/cancelada), precio."
  },
  "credentials": { "postgres": { "name": "PostgreSQL GCP" } }
}
```

**4. insert_reserva** (INSERT)
```json
{
  "name": "insert_reserva",
  "type": "@n8n/n8n-nodes-langchain.toolPostgres",
  "parameters": {
    "operation": "insert",
    "table": "reservas",
    "description": "Crea una reserva. Requeridos: id_cliente (ej: C-0003), destino, fecha_salida (YYYY-MM-DD), fecha_regreso (YYYY-MM-DD), precio. Opcionales: tipo, origen, estado, notas."
  },
  "credentials": { "postgres": { "name": "PostgreSQL GCP" } }
}
```

**5. execute_query** (QUERY)
```json
{
  "name": "execute_query",
  "type": "@n8n/n8n-nodes-langchain.toolPostgres",
  "parameters": {
    "description": "Ejecuta consultas SQL personalizadas. Para búsquedas específicas, filtros, JOINs. Ejemplo: SELECT * FROM clientes WHERE nombre_completo ILIKE '%María%'"
  },
  "credentials": { "postgres": { "name": "PostgreSQL GCP" } }
}
```

#### **F. Conexiones del Workflow**
```
Telegram Trigger → AI Agent Orquestador → Telegram Send
                         ↓
                  Ollama Chat Model (ai_languageModel)
                         ↓
                  5 Postgres Tools (ai_tool):
                  - get_clientes
                  - insert_cliente
                  - get_reservas
                  - insert_reserva
                  - execute_query
```

---

### **1. NODO: Identificar Usuario (Code)**

**Ubicación:** Entre "Telegram Trigger" y "AI Agent"

**Código:**
```javascript
// Extraer datos del usuario de Telegram
const telegramUserId = $input.item.json.message.from.id;
const userName = $input.item.json.message.from.first_name || 'Usuario';
const userUsername = $input.item.json.message.from.username || '';

// Consultar si existe en DB
const query = `
  SELECT id_usuario, rol, nombre_completo, email, telefono 
  FROM usuarios 
  WHERE telegram_id = '${telegramUserId}'
`;

let userData;
try {
  // Ejecutar query (necesitas conectar a Postgres aquí)
  const result = await $postgres.query(query);
  
  if (result.rows.length === 0) {
    // Usuario nuevo - registrar automáticamente
    const insertQuery = `
      INSERT INTO usuarios (telegram_id, nombre_completo, rol, estado)
      VALUES ('${telegramUserId}', '${userName}', 'cliente', 'activo')
      RETURNING id_usuario, rol, nombre_completo
    `;
    const insertResult = await $postgres.query(insertQuery);
    userData = insertResult.rows[0];
  } else {
    userData = result.rows[0];
  }
} catch (error) {
  // Si falla, asumir rol cliente
  userData = {
    id_usuario: `TEMP-${telegramUserId}`,
    rol: 'cliente',
    nombre_completo: userName
  };
}

// Retornar datos enriquecidos
return {
  json: {
    ...item.json,
    user: {
      id: userData.id_usuario,
      rol: userData.rol,
      nombre: userData.nombre_completo,
      telegram_id: telegramUserId,
      username: userUsername
    },
    sessionId: `telegram-${telegramUserId}`, // Para memoria
    message_text: item.json.message.text
  }
};
```

---

### **2. NODO: Switch - Filtrar por Rol**

**Ubicación:** Después de "Identificar Usuario"

**Configuración:**
- **Mode:** Rules
- **Rule 1:** `{{ $json.user.rol }}` equals `admin` → Output 1 (Admin)
- **Rule 2:** `{{ $json.user.rol }}` equals `cliente` → Output 2 (Cliente)
- **Fallback:** Output 2 (Cliente por defecto)

---

### **3. TOOLS PARA CLIENTES (Output 2 del Switch)**

#### **Tool 1: Get Mis Reservas**
```
Nodo: Postgres Tool (Select)
Tabla: reservas
Filtro WHERE: id_cliente = '{{ $json.user.id }}'
Descripción para AI: "Obtiene las reservas del cliente actual"
```

#### **Tool 2: Ver Mi Perfil**
```
Nodo: Postgres Tool (Select)
Tabla: clientes
Filtro WHERE: id_cliente = '{{ $json.user.id }}'
Descripción para AI: "Muestra la información del perfil del cliente"
```

#### **Tool 3: Crear Reserva (CON VALIDACIÓN)**
```
Flujo:
AI Agent → Validation Node → Prepare Insert Data → Insert Reserva

Validation Node (Code):
- Validar fechas (salida < regreso, >= hoy)
- Validar destino no vacío
- Verificar que el id_cliente exista
- Si falla: retornar error
```

---

### **4. TOOLS PARA ADMIN (Output 1 del Switch)**

#### **Tool 1: Get Todas Las Reservas**
```
Nodo: Postgres Tool (Select)
Tabla: reservas
Sin filtros (retorna todas)
```

#### **Tool 2: Execute Query Seguro**
```
Nodo: Postgres Tool (Execute Query)
Validación en Code previo:
- Solo permitir SELECT
- Bloquear DROP, DELETE, UPDATE
- Limitar a tablas permitidas
```

#### **Tool 3: Get Estadísticas**
```
Nodo: Postgres Tool (Execute Query)
Query predefinida:
SELECT 
  COUNT(*) as total_reservas,
  COUNT(DISTINCT id_cliente) as total_clientes,
  SUM(precio) as ingresos_totales,
  destino,
  COUNT(*) as reservas_por_destino
FROM reservas
WHERE fecha_salida >= NOW()
GROUP BY destino
ORDER BY reservas_por_destino DESC
LIMIT 10
```

---

### **5. NODO: Validation Before Insert**

**Ubicación:** Entre AI Agent y los Insert nodes

**Código:**
```javascript
const data = $input.item.json;

// Validaciones según tipo de operación
if (data.operation === 'insert_cliente') {
  // Validar email
  if (!data.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
    throw new Error('Email inválido');
  }
  
  // Validar teléfono
  if (!data.telefono || !/^\d{10}$/.test(data.telefono.replace(/\D/g, ''))) {
    throw new Error('Teléfono inválido (debe tener 10 dígitos)');
  }
  
  // Validar nombre
  if (!data.nombre_completo || data.nombre_completo.length < 3) {
    throw new Error('Nombre debe tener al menos 3 caracteres');
  }
}

if (data.operation === 'insert_reserva') {
  // Validar fechas
  const salida = new Date(data.fecha_salida);
  const regreso = new Date(data.fecha_regreso);
  const hoy = new Date();
  
  if (salida < hoy) {
    throw new Error('La fecha de salida no puede ser en el pasado');
  }
  
  if (regreso <= salida) {
    throw new Error('La fecha de regreso debe ser posterior a la salida');
  }
  
  // Validar destino
  if (!data.destino || data.destino.length < 2) {
    throw new Error('Destino inválido');
  }
  
  // Verificar que el cliente existe
  const clienteExists = await $postgres.query(
    `SELECT id_cliente FROM clientes WHERE id_cliente = '${data.id_cliente}'`
  );
  
  if (clienteExists.rows.length === 0) {
    throw new Error('Cliente no encontrado. Debe registrarse primero.');
  }
}

return { json: data };
```

---

### **6. NODO: Prepare Insert Cliente**

**Ubicación:** Entre Validation y Insert Cliente

**Código:**
```javascript
const data = $input.item.json;
const timestamp = Date.now();
const userId = data.user?.id || 'TEMP';

return {
  json: {
    id_cliente: `C-${timestamp}`,
    nombre_completo: data.nombre_completo,
    email: data.email.toLowerCase().trim(),
    telefono: data.telefono.replace(/\D/g, ''), // Solo números
    direccion: data.direccion || '',
    fecha_registro: new Date().toISOString()
  }
};
```

**Luego conectar a:**
```
Nodo: Postgres (Insert)
Tabla: clientes
Mapeo: Usar directamente los campos del JSON anterior
```

---

### **7. NODO: Prepare Insert Reserva**

**Código:**
```javascript
const data = $input.item.json;
const timestamp = Date.now();

return {
  json: {
    id_reserva: `R-${timestamp}`,
    id_cliente: data.id_cliente,
    tipo: data.tipo || 'vuelo',
    origen: data.origen || 'Bogotá',
    destino: data.destino,
    fecha_salida: data.fecha_salida,
    fecha_regreso: data.fecha_regreso,
    estado: 'pendiente',
    precio: data.precio || 0,
    notas: data.notas || ''
  }
};
```

---

## 📝 SYSTEM PROMPT MEJORADO {#prompt}

```text
Eres el asistente AI de EFIG Vuelos & Travel, agencia internacional de viajes.

## 🎭 CONTEXTO DEL USUARIO ACTUAL
- **Nombre:** {{ $json.user.nombre }}
- **ID:** {{ $json.user.id }}
- **Rol:** {{ $json.user.rol }}

## 🔧 TUS HERRAMIENTAS Y CUÁNDO USARLAS

### 📋 PARA CLIENTES:

**1. Get Mis Reservas**
- **Cuándo:** Usuario pregunta "mis reservas", "mis viajes", "qué tengo reservado"
- **Cómo:** Llamas esta herramienta SIN parámetros (ya filtra por su ID)
- **Después:** Muestras las reservas encontradas de forma clara

**2. Ver Mi Perfil**
- **Cuándo:** Usuario pregunta por sus datos, email, teléfono
- **Cómo:** Llamas sin parámetros
- **Después:** Muestras la info y preguntas si quiere actualizar algo

**3. Crear Reserva**
- **Cuándo:** Usuario dice "quiero viajar a X", "reservar vuelo a Y"
- **Requisitos OBLIGATORIOS:**
  - `destino` (ej: "París")
  - `fecha_salida` (formato YYYY-MM-DD)
  - `fecha_regreso` (formato YYYY-MM-DD)
- **Proceso:**
  1. Si falta algún dato, pregunta UNO por uno
  2. Confirma ANTES de crear: "¿Confirmas reservar [destino] del [fecha] al [fecha]?"
  3. Si confirma → llama herramienta con:
     ```json
     {
       "id_cliente": "{{ $json.user.id }}",
       "destino": "París",
       "fecha_salida": "2025-06-10",
       "fecha_regreso": "2025-06-20",
       "origen": "Bogotá",
       "tipo": "vuelo"
     }
     ```
  4. Si falla → explica el error y pide corregir datos

### 🔐 PARA ADMINISTRADORES:

**4. Get Todas Las Reservas**
- **Cuándo:** Admin pregunta "todas las reservas", "lista de reservas"
- **Filtros opcionales:** Por fecha, destino, estado

**5. Get Todos Los Clientes**
- **Cuándo:** Admin pregunta "lista de clientes", "cuántos clientes"

**6. Execute Query Seguro**
- **Cuándo:** Admin necesita datos específicos no cubiertos por otras herramientas
- **IMPORTANTE:** Solo para SELECT, nunca DELETE/UPDATE/DROP
- **Ejemplo válido:**
  ```sql
  SELECT nombre_completo, email FROM clientes WHERE fecha_registro >= '2025-01-01'
  ```
- **Si pide query peligrosa:** Rechaza y explica por qué

**7. Estadísticas**
- **Cuándo:** Admin pregunta "estadísticas", "reporte", "resumen"
- **Muestra:** Total reservas, clientes, ingresos, destinos populares

## 📞 MANEJO DE DATOS INCOMPLETOS

### Si usuario dice: "Quiero viajar a París"
❌ NO hagas: Crear reserva inmediatamente
✅ SÍ haz:
1. Pregunta: "¿Cuándo quieres viajar? (fecha de salida)"
2. Espera respuesta → "¿Cuándo regresas? (fecha de regreso)"
3. Resumen: "Confirma: Vuelo a París del 10/06 al 20/06. ¿Correcto?"
4. Si "sí" → Crea reserva

### Si usuario dice: "Soy Juan, juan@email.com, 318-999-9999"
✅ Reconoce: Quiere registrarse como cliente
✅ Llama Insert Cliente con esos datos
✅ Confirma: "¡Bienvenido Juan! 🎉 Ya estás registrado. ¿A dónde quieres viajar?"

## 🚫 REGLAS DE SEGURIDAD

1. **NUNCA** muestres datos de otros clientes a un cliente (solo admin)
2. **NUNCA** ejecutes queries de modificación (DELETE/UPDATE) sin confirmación
3. **SIEMPRE** confirma antes de crear reservas
4. **SIEMPRE** valida que las fechas sean lógicas (salida < regreso, futuro)
5. **NUNCA** inventes IDs de clientes, usa el del usuario actual: {{ $json.user.id }}

## 💬 ESTILO DE COMUNICACIÓN

- 😊 Amable y cercano
- 🌍 Usa emojis de banderas para destinos
- ✅ Confirma acciones importantes
- 💡 Da recomendaciones proactivas sobre visas, clima, tours
- 📋 Respuestas estructuradas y claras

## 🎯 EJEMPLOS DE BUENAS RESPUESTAS

**Cliente pregunta:** "Mis reservas"
```
🎫 Tus Reservas Activas:

1️⃣ París 🇫🇷
   📅 Salida: 10 de junio 2025
   📅 Regreso: 20 de junio 2025
   💵 Precio: $2.000.000 COP
   ✅ Estado: Confirmada

No tienes más reservas. ¿Quieres agregar un nuevo destino? ✈️
```

**Cliente pregunta:** "Quiero ir a Cancún en julio"
```
¡Excelente elección! 🇲🇽🏖️ Cancún es hermoso en julio.

Para crear tu reserva necesito:
📅 ¿Qué día de julio viajas? (Ej: 15 de julio)
```

---

## 🔄 FLUJO DE CREACIÓN DE RESERVA

```
Usuario: "Quiero ir a París"
Tú: "¡Genial! 🇫🇷 ¿Cuándo quieres viajar?"

Usuario: "Del 10 al 20 de junio"
Tú: "Perfecto. Confirma:
     ✈️ Destino: París
     📅 Salida: 10 de junio 2025
     📅 Regreso: 20 de junio 2025
     💵 Precio estimado: $2.000.000 COP
     
     ¿Está correcto?"

Usuario: "Sí"
Tú: [LLAMAS herramienta Insert Reserva]
     "✅ ¡Reserva creada! Código: R-1234567
     
     📋 Próximos pasos:
     1. No necesitas visa Schengen (90 días)
     2. Pasaporte vigente requerido
     3. Clima en junio: 18-25°C
     
     ¿Quieres que te recomiende tours en París?"
```

---

**¡Ayuda a los usuarios a vivir experiencias inolvidables!** 🌍✈️
```

---

## 🧪 EJEMPLOS DE USO {#ejemplos}

### **Caso 1: Cliente Nuevo Crea Reserva**

```
[Telegram] Usuario: Hola, quiero viajar a Cartagena

[Identificar Usuario]
- telegram_id: 123456
- No existe en DB → Crear usuario nuevo
- Asignar rol: cliente
- Retornar: user_id=C-001, rol=cliente

[AI Agent recibe contexto]
- user_id: C-001
- rol: cliente
- Herramientas disponibles: Get Mis Reservas, Ver Perfil, Crear Reserva

[AI responde]
"¡Hola! 👋 Bienvenido a EFIG. ¿Cuándo quieres viajar a Cartagena? 🏖️"

[Usuario]: Del 15 al 22 de diciembre

[AI Agent llama Create Reserva]
Parámetros:
{
  "id_cliente": "C-001",
  "destino": "Cartagena",
  "fecha_salida": "2025-12-15",
  "fecha_regreso": "2025-12-22"
}

[Validation Node]
✅ Fechas válidas
✅ Cliente existe
✅ Destino válido

[Prepare Insert]
Genera:
{
  "id_reserva": "R-1733445678",
  "id_cliente": "C-001",
  "destino": "Cartagena",
  ...
}

[Insert Reserva]
✅ Insertado exitosamente

[AI responde]
"✅ ¡Reserva confirmada!
 
🎫 Código: R-1733445678
📍 Cartagena 🇨🇴
📅 15 al 22 de diciembre
💵 Precio: $350.000 COP

📋 Requisitos:
- Solo cédula colombiana
- Clima: 28-32°C

¿Quieres que te recomiende hoteles?"
```

---

### **Caso 2: Admin Consulta Estadísticas**

```
[Telegram] Admin: Dame las estadísticas

[Identificar Usuario]
- telegram_id: 999999
- Existe: user_id=A-001, rol=admin

[AI Agent]
- Herramientas disponibles: TODAS + Execute Query + Estadísticas

[AI llama Get Estadísticas]

[Retorna]
{
  "total_reservas": 156,
  "total_clientes": 89,
  "ingresos_totales": 124500000,
  "top_destinos": [
    {"destino": "Cartagena", "count": 34},
    {"destino": "San Andrés", "count": 28}
  ]
}

[AI responde]
"📊 **Estadísticas EFIG**

📈 Resumen General:
- Total Reservas: 156
- Clientes Activos: 89
- Ingresos: $124.500.000 COP

🏆 Destinos Más Populares:
1. Cartagena 🏖️ - 34 reservas
2. San Andrés 🏝️ - 28 reservas

¿Quieres ver más detalles?"
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Fase 0: Configuración Básica (COMPLETADO ✅)
- [x] Crear credencial "PostgreSQL GCP" en n8n Cloud
- [x] Crear credencial "EFIG Telegram Bot" en n8n Cloud
- [x] Configurar 5 nodos Postgres Tool con tipo correcto (`@n8n/n8n-nodes-langchain.toolPostgres`)
- [x] Configurar Ollama Chat Model con URL: `http://34.66.86.207:8002`
- [x] Importar workflow: `workflow-cloud-correcto.json`
- [x] Activar workflow
- [x] Poblar base de datos con datos de prueba (16 clientes, 17 reservas, 10 pagos)

**Estado actual:**
- ✅ PostgreSQL funcionando en GCP (34.66.86.207:5433)
- ✅ Copilot API funcionando (34.66.86.207:8002)
- ✅ Base de datos poblada con datos realistas
- ✅ Workflow básico funcionando (listar clientes, reservas)

### Fase 1: Estructura Base (PRÓXIMO)
- [ ] Crear tabla `usuarios` en Postgres (telegram_id, rol, nombre, email, estado)
- [ ] Agregar nodo "Identificar Usuario" (Code)
- [ ] Agregar nodo "Switch" para filtrar por rol
- [ ] Configurar sessionId en Postgres Chat Memory

### Fase 2: Tools para Clientes
- [ ] Configurar "Get Mis Reservas" (filtrado por user.id)
- [ ] Configurar "Ver Mi Perfil"
- [ ] Crear flujo validación → Prepare → Insert para Reservas
- [ ] Crear flujo similar para Insert Cliente

### Fase 3: Tools para Admin
- [ ] Configurar "Get Todas Reservas"
- [ ] Configurar "Get Todos Clientes"
- [ ] Crear "Execute Query Seguro" con validaciones
- [ ] Crear "Get Estadísticas"

### Fase 4: Seguridad y Validaciones
- [ ] Implementar Validation Node
- [ ] Validar emails, teléfonos, fechas
- [ ] Bloquear queries peligrosos
- [ ] Agregar logs de acciones

### Fase 5: Mejoras UX
- [ ] Actualizar System Prompt con ejemplos
- [ ] Agregar confirmaciones antes de inserts
- [ ] Implementar manejo de errores amigable
- [ ] Agregar comandos útiles (/mis_reservas, /ayuda)

---

## 🐛 DEBUGGING

### Si Insert Reserva falla:
1. Revisar logs del nodo "Prepare Insert Reserva"
2. Verificar que los campos coincidan EXACTAMENTE con la tabla
3. Comprobar que id_cliente existe en la tabla clientes
4. Validar formato de fechas (YYYY-MM-DD)

### Si el AI no usa las herramientas:
1. Verificar que las descripciones de las tools sean claras
2. Revisar que el System Prompt tenga ejemplos de cuándo usarlas
3. Probar con comandos explícitos: "USA la herramienta Get Mis Reservas"

### Si la memoria no funciona:
1. Verificar que sessionId esté llegando: `{{ $json.sessionId }}`
2. Comprobar conexión a Postgres
3. Revisar tabla `n8n_chat_histories` en la DB

---

## 📚 RECURSOS ADICIONALES

- [N8n Postgres Tool Docs](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/)
- [LangChain Memory](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.memorybufferchat/)
- [AI Agent Best Practices](https://docs.n8n.io/advanced-ai/examples/)

---

**¡Con esta estructura tendrás un workflow robusto, seguro y escalable!** 🚀

**Próximos pasos:**
1. Implementa Fase 1 (estructura base)
2. Prueba con un usuario de prueba
3. Ve iterando fase por fase
4. Documenta errores que encuentres para ajustar

¿Te ayudo con algún nodo específico o quieres que profundice en alguna parte?
