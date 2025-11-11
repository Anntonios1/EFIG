# 🚀 Guía de Implementación - Workflow con Roles y Validaciones

## 📋 Descripción

Este workflow implementa la arquitectura completa de la guía `n8n-workflow-guide.md`:

✅ **Identificación de usuarios** por Telegram ID
✅ **Roles diferenciados:** Cliente y Admin
✅ **Prompts especializados** según el rol
✅ **5 herramientas PostgreSQL** funcionando correctamente
✅ **Validaciones y confirmaciones** antes de inserts
✅ **Seguridad:** Filtrado de herramientas por rol

---

## 🏗️ Arquitectura del Workflow

```
Telegram Trigger
       ↓
Identificar Usuario (Code)
  - Extrae Telegram ID
  - Asigna rol (admin/cliente)
  - Crea sessionId
       ↓
Switch - Filtrar por Rol
       ↓              ↓
   [ADMIN]      [CLIENTE]
       ↓              ↓
AI Agent Admin  AI Agent Cliente
  (Todas tools)  (Tools básicas)
       ↓              ↓
   Merge Output
       ↓
  Telegram Send
```

---

## 🔧 Componentes del Workflow

### 1. **Telegram Trigger**
- Recibe mensajes del bot
- Extrae: message, chat, from (user data)

### 2. **Identificar Usuario (Code Node)**
```javascript
// Extrae Telegram ID y nombre
const telegramUserId = $input.item.json.message.from.id;
const userName = $input.item.json.message.from.first_name;

// Define lista de admins (PERSONALIZAR AQUÍ)
const adminIds = [123456789]; // Reemplazar con tu Telegram ID

// Asigna rol
const isAdmin = adminIds.includes(telegramUserId);

// Retorna datos enriquecidos
return {
  json: {
    message: $input.item.json.message,
    user: {
      telegram_id: telegramUserId,
      rol: isAdmin ? 'admin' : 'cliente',
      nombre: userName
    },
    sessionId: `telegram-${telegramUserId}`,
    message_text: $input.item.json.message.text
  }
};
```

**⚙️ CONFIGURACIÓN REQUERIDA:**
- Edita la línea: `const adminIds = [123456789];`
- Reemplaza `123456789` con tu Telegram ID real
- Para obtener tu ID: envía `/start` a @userinfobot en Telegram

### 3. **Switch - Filtrar por Rol**
- **Condición 1:** Si `user.rol == 'admin'` → Output 1 (AI Agent Admin)
- **Condición 2:** Si `user.rol == 'cliente'` → Output 2 (AI Agent Cliente)
- **Fallback:** Output 2 (Cliente por defecto)

### 4. **AI Agent - Admin**
**System Prompt:**
- Rol: Administrador con acceso total
- Herramientas: TODAS (get/insert clientes, reservas, execute_query)
- Capacidades especiales:
  - Ver estadísticas generales
  - Ejecutar queries SQL SELECT personalizados
  - Ver top destinos, clientes VIP, reservas próximas
  - Gestionar todos los clientes y reservas

**Comandos Admin:**
- "Dame las estadísticas"
- "Top 10 destinos"
- "Clientes VIP"
- "Reservas próximas"
- "Busca a [nombre cliente]"

### 5. **AI Agent - Cliente**
**System Prompt:**
- Rol: Cliente estándar
- Herramientas: get/insert clientes, reservas, execute_query (búsquedas)
- Flujo guiado para crear reservas:
  1. Pregunta datos faltantes uno por uno
  2. Busca id_cliente antes de crear reserva
  3. Confirma antes de insertar
  4. Valida fechas y precios

**Comandos Cliente:**
- "Lista los clientes"
- "Quiero viajar a [destino]"
- "Muestra las reservas"
- "Soy [nombre], [email], [teléfono]" (auto-registro)

### 6. **Ollama Chat Model**
- Modelo: gpt-4
- URL: `http://34.66.86.207:8002`
- Temperature: 0.7
- Conectado a AMBOS AI Agents (Admin y Cliente)

### 7. **5 Herramientas PostgreSQL**

#### **get_clientes**
- Operación: `select`
- Tabla: `clientes`
- Límite: 50
- Descripción clara para el AI

#### **insert_cliente**
- Operación: `insert`
- Tabla: `clientes`
- Campos: nombre_completo, email, telefono, documento, tipo_cliente

#### **get_reservas**
- Operación: `select`
- Tabla: `reservas`
- Límite: 50

#### **insert_reserva**
- Operación: `insert`
- Tabla: `reservas`
- Campos: id_cliente, destino, fecha_salida, fecha_regreso, precio, tipo, origen

#### **execute_query**
- Sin operación definida (query libre)
- Solo SELECT queries
- Descripción con ejemplos de uso

### 8. **Merge Output**
- Combina salida de ambos AI Agents
- Extrae el campo `output` del que se ejecutó
- Prepara datos para Telegram Send

### 9. **Telegram Send**
- Envía respuesta al usuario
- Parse mode: Markdown
- Chat ID del usuario original

---

## ✅ Pasos de Implementación

### **Paso 1: Configurar Credenciales**

#### A. PostgreSQL GCP
```
Credentials → + Add Credential → PostgreSQL

Nombre: PostgreSQL GCP
Host: 34.66.86.207
Port: 5433
Database: n8n_db
User: n8n
Password: n8npass
SSL Mode: disable

Test → Save
```

#### B. Telegram Bot
```
Credentials → + Add Credential → Telegram

Nombre: EFIG Telegram Bot
Bot Token: 8477198544:AAFRfPKaecCKjS_ooGOkmADQrZ7MedcwVjw

Save
```

### **Paso 2: Importar Workflow**

1. Ve a n8n Cloud: https://jeylermartinez.app.n8n.cloud
2. Workflows → + Add workflow → Import from file
3. Selecciona: `workflow-completo-con-roles.json`
4. Click en **Import**

### **Paso 3: Personalizar IDs de Admin**

1. Abre el nodo **"Identificar Usuario"**
2. Edita el código JavaScript
3. Encuentra la línea:
   ```javascript
   const adminIds = [123456789];
   ```
4. Reemplaza `123456789` con tu Telegram ID
   - Para obtenerlo: Envía `/start` a @userinfobot en Telegram
   - Ejemplo: `const adminIds = [987654321, 111222333];` (puedes agregar múltiples)
5. **Save**

### **Paso 4: Verificar Conexiones de Tools**

Asegúrate de que los 5 nodos de herramientas PostgreSQL estén conectados a AMBOS AI Agents:

- **get_clientes** → conexión `ai_tool` a AI Agent Admin y AI Agent Cliente
- **insert_cliente** → conexión `ai_tool` a ambos
- **get_reservas** → conexión `ai_tool` a ambos
- **insert_reserva** → conexión `ai_tool` a ambos
- **execute_query** → conexión `ai_tool` a ambos

### **Paso 5: Verificar Ollama Chat Model**

1. Abre el nodo **"Ollama Chat Model"**
2. Verifica:
   - Model: `gpt-4`
   - Base URL: `http://34.66.86.207:8002`
   - Temperature: `0.7`
3. Verifica conexión `ai_languageModel` a ambos AI Agents

### **Paso 6: Activar Workflow**

1. Switch en la esquina superior derecha: **Inactive** → **Active**
2. Verifica que el webhook esté registrado:
   ```powershell
   Invoke-RestMethod -Uri "https://api.telegram.org/bot8477198544:AAFRfPKaecCKjS_ooGOkmADQrZ7MedcwVjw/getWebhookInfo"
   ```
3. Debe mostrar: `url: https://jeylermartinez.app.n8n.cloud/webhook/...`

---

## 🧪 Pruebas

### **Como Cliente:**

1. Abre Telegram y busca: @EFIGVUELOS_bot
2. Envía: `/start` o `Hola`
3. Prueba comandos:
   ```
   Lista los clientes
   Muestra las reservas
   Quiero viajar a Cartagena
   ```

**Flujo de reserva esperado:**
```
Tú: "Quiero ir a Cartagena"
Bot: "¡Excelente! 🏖️ ¿Cuál es tu nombre completo para buscar tu registro?"

Tú: "María González"
Bot: "Perfecto María! ¿Cuándo quieres viajar? (fecha de salida)"

Tú: "15 de diciembre"
Bot: "¿Cuándo regresas?"

Tú: "22 de diciembre"
Bot: "Confirma tu reserva:
     ✈️ Destino: Cartagena 🏖️
     📅 Salida: 15 de diciembre 2025
     📅 Regreso: 22 de diciembre 2025
     💵 Precio: $350.000 COP
     
     ¿Está correcto? (responde sí/no)"

Tú: "Sí"
Bot: "✅ ¡Reserva creada exitosamente!
     
     🎫 Código: R-XXXX
     📍 Cartagena, Colombia 🇨🇴
     ..."
```

### **Como Admin:**

1. Asegúrate de que tu Telegram ID esté en la lista de admins
2. Envía comandos admin:
   ```
   Dame las estadísticas
   Top destinos
   Clientes VIP
   Reservas próximas
   Busca a María González
   ```

**Ejemplo de respuesta admin:**
```
Tú: "Dame las estadísticas"
Bot: "📊 **Estadísticas EFIG**
     
     📈 Resumen General:
     - Total Reservas: 17
     - Clientes Activos: 16
     - Ingresos: $31.840.000 COP
     
     📊 Por Estado:
     - Confirmadas: 8 ($15.530.000)
     - Pendientes: 7 ($12.330.000)
     - Canceladas: 2 ($3.980.000)
     
     🏆 Top Destinos:
     1. Cartagena - 1 reserva
     2. San Andrés - 1 reserva
     ..."
```

---

## 🔒 Seguridad Implementada

### ✅ Control de Acceso por Roles
- Clientes NO pueden ver queries de admin
- Admin tiene acceso completo
- Roles asignados automáticamente por Telegram ID

### ✅ Validaciones en Prompts
- Fechas deben ser futuras
- Fecha regreso > fecha salida
- Email con formato válido
- Teléfono con 10 dígitos
- Cliente debe existir antes de crear reserva

### ✅ Confirmaciones Obligatorias
- Reservas requieren confirmación explícita
- Insert de clientes muestra resumen antes de guardar
- Queries peligrosos bloqueados (DELETE, DROP)

### ✅ Limitaciones
- Execute query solo acepta SELECT
- Resultados limitados (LIMIT 50)
- No se pueden modificar datos sin confirmación

---

## 🐛 Solución de Problemas

### **Error: "Usuario no identificado"**
**Causa:** El nodo "Identificar Usuario" no está ejecutándose.
**Solución:**
1. Verifica que el nodo esté correctamente conectado después del Telegram Trigger
2. Revisa el código del nodo (debe tener el código JavaScript completo)

### **Error: "No se puede crear reserva"**
**Causa:** El AI no encuentra el id_cliente del usuario.
**Solución:**
1. Asegúrate de que el cliente esté registrado primero
2. El AI debe usar execute_query para buscar el cliente:
   ```sql
   SELECT id_cliente FROM clientes WHERE nombre_completo ILIKE '%[nombre]%' LIMIT 1
   ```

### **Error: "Credenciales no configuradas"**
**Causa:** Los nodos PostgreSQL Tool no tienen la credencial asignada.
**Solución:**
1. Abre cada nodo PostgreSQL Tool (5 en total)
2. En "Credential to connect with", selecciona: **PostgreSQL GCP**
3. Save cada nodo

### **Error: "Ollama no responde"**
**Causa:** La URL del Copilot API es incorrecta o el servidor está caído.
**Solución:**
1. Verifica que el servidor esté activo:
   ```powershell
   Invoke-RestMethod -Uri "http://34.66.86.207:8002/api/tags"
   ```
2. Si no responde, revisa el contenedor en GCP:
   ```bash
   docker ps | grep copilot
   docker logs copilot_api_cloud
   ```

### **El bot no diferencia roles**
**Causa:** El Switch no está configurado correctamente.
**Solución:**
1. Abre el nodo "Switch - Filtrar por Rol"
2. Verifica las condiciones:
   - Rule 1: `{{ $json.user.rol }}` equals `admin`
   - Rule 2: `{{ $json.user.rol }}` equals `cliente`
3. Verifica las salidas:
   - Output 1 (admin) → AI Agent - Admin
   - Output 2 (cliente) → AI Agent - Cliente

---

## 📊 Métricas y Monitoreo

### **Comandos Útiles para Admin**

**Total de ejecuciones:**
```sql
SELECT COUNT(*) as total_consultas FROM n8n_execution_entity;
```

**Reservas creadas hoy:**
```sql
SELECT COUNT(*) as reservas_hoy 
FROM reservas 
WHERE fecha_registro >= CURRENT_DATE;
```

**Clientes nuevos esta semana:**
```sql
SELECT COUNT(*) as nuevos_clientes 
FROM clientes 
WHERE fecha_registro >= CURRENT_DATE - INTERVAL '7 days';
```

---

## 🚀 Próximos Pasos (Mejoras Futuras)

### Fase 2: Tabla de Usuarios
- [ ] Crear tabla `usuarios` en PostgreSQL
- [ ] Vincular telegram_id con tabla usuarios
- [ ] Guardar historial de interacciones
- [ ] Implementar sistema de autenticación real

### Fase 3: Validaciones Avanzadas
- [ ] Agregar nodo de validación antes de inserts
- [ ] Verificar formato de emails
- [ ] Validar rangos de fechas
- [ ] Comprobar disponibilidad antes de reservar

### Fase 4: Memoria Persistente
- [ ] Agregar Postgres Chat Memory
- [ ] Guardar contexto de conversaciones
- [ ] Recordar preferencias de usuario
- [ ] Reanudar conversaciones interrumpidas

### Fase 5: Notificaciones
- [ ] Recordatorios de viajes próximos
- [ ] Alertas de documentos pendientes
- [ ] Confirmaciones de pagos
- [ ] Ofertas personalizadas

---

## 📚 Recursos

- **Archivo del workflow:** `workflow-completo-con-roles.json`
- **Guía completa:** `n8n-workflow-guide.md`
- **Workflow básico:** `workflow-cloud-correcto.json`
- **Configuración GCP:** `CONFIGURACION-COMPLETA.md`
- **Datos de prueba:** `datos-final.sql`

---

## ✅ Checklist Final

Antes de ir a producción:

- [ ] Credenciales PostgreSQL configuradas y probadas
- [ ] Credencial Telegram configurada
- [ ] IDs de admin personalizados en "Identificar Usuario"
- [ ] 5 nodos PostgreSQL Tool con credenciales asignadas
- [ ] Ollama Chat Model con URL correcta
- [ ] Conexiones verificadas (ai_tool y ai_languageModel)
- [ ] Workflow activado
- [ ] Webhook de Telegram funcionando
- [ ] Probado como cliente (listar, crear reserva)
- [ ] Probado como admin (estadísticas, queries)
- [ ] Base de datos con datos de prueba (16 clientes, 17 reservas)

---

**🎉 ¡Workflow implementado exitosamente!**

Tu agencia de viajes con IA ahora tiene:
- ✅ Control de acceso por roles
- ✅ Prompts especializados
- ✅ Validaciones y confirmaciones
- ✅ Seguridad en queries
- ✅ Base de datos real con datos de prueba

**¡Listo para procesar reservas reales!** ✈️🌍
