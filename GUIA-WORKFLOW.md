# 🤖 Workflow Completo - EFIG Agencia de Viajes

## 📋 Descripción del Flujo

Este workflow maneja todas las operaciones de tu agencia de viajes a través de Telegram:

### ✅ Funcionalidades Implementadas

1. **📝 Registro de Clientes**
   - El bot recibe: nombre, email, teléfono
   - Los guarda automáticamente en PostgreSQL
   - Genera ID automático (C-0001, C-0002, etc.)

2. **✈️ Creación de Reservas**
   - El bot pregunta: destino, fechas
   - Busca el ID del cliente
   - Crea la reserva con estado "pendiente"
   - Genera ID de reserva (R-0001, R-0002, etc.)

3. **💳 Registro de Pagos**
   - El bot recibe: ID de reserva, monto, método
   - Registra el pago en la base de datos
   - Actualiza el estado de la reserva

4. **🔍 Consultas**
   - Buscar clientes por nombre
   - Ver reservas de un cliente
   - Verificar pagos
   - Consultar disponibilidad

5. **💬 Conversación Natural**
   - Responde preguntas generales
   - Da información sobre destinos
   - Asiste en el proceso completo

---

## 📥 Cómo Importar el Workflow

### En n8n Cloud:

1. Ve a **Workflows** en tu n8n Cloud
2. Click en el botón **"Import from File"** (o menú ⋮ > Import)
3. Selecciona el archivo: `workflow-completo-efig.json`
4. Click **"Import"**

### Configurar Credenciales:

Después de importar, necesitas actualizar las credenciales:

1. **Telegram Trigger**:
   - Click en el nodo
   - Selecciona tu credencial de Telegram existente

2. **Ollama Chat Model (GPT-4)**:
   - Click en el nodo
   - Selecciona: **"Copilot API GCP"**
   - Verifica que Model = `gpt-4`

3. **Postgres - Consultar Datos**:
   - Click en el nodo
   - Selecciona: **"Postgres Cloud GCP"**

4. **Postgres - Registrar Cliente**:
   - Click en el nodo
   - Selecciona: **"Postgres Cloud GCP"**

5. **Postgres - Crear Reserva**:
   - Click en el nodo
   - Selecciona: **"Postgres Cloud GCP"**

6. **Telegram - Enviar Respuesta**:
   - Click en el nodo
   - Selecciona tu credencial de Telegram existente

7. Click **"Save"** y **Activa el workflow**

---

## 🧪 Casos de Prueba

### 1. Registrar un Nuevo Cliente

**Usuario envía:**
```
Hola, quiero registrarme. 
Mi nombre es María García
Email: maria@email.com
Teléfono: +57 300 1234567
```

**Bot responde:**
```
¡Perfecto María! Te he registrado exitosamente en nuestro sistema.

📋 Tus datos:
- Nombre: María García
- Email: maria@email.com
- Teléfono: +57 300 1234567
- ID Cliente: C-0002

¿En qué más puedo ayudarte? Puedo ayudarte a:
- Hacer una reserva ✈️
- Consultar destinos 🌎
- Información de precios 💰
```

### 2. Crear una Reserva

**Usuario envía:**
```
Quiero viajar a Cartagena del 15 al 20 de diciembre
```

**Bot responde:**
```
¡Excelente elección! Cartagena es un destino hermoso 🌴

Necesito confirmar algunos datos:
- ¿Cuál es tu nombre completo para buscar tu registro?

(Si no estás registrado, puedo hacerlo ahora mismo con tu nombre, email y teléfono)
```

**Usuario envía:**
```
Soy María García
```

**Bot responde:**
```
¡Perfecto María! Encontré tu registro (ID: C-0002)

✅ Reserva creada exitosamente:
- Destino: Cartagena
- Salida: 15 de diciembre de 2025
- Regreso: 20 de diciembre de 2025
- Estado: Pendiente
- ID Reserva: R-0001

Para confirmar tu reserva, necesitamos procesar el pago. 
¿Deseas proceder con el pago ahora?
```

### 3. Consultar Información

**Usuario envía:**
```
¿Qué documentos necesito para viajar a Cartagena?
```

**Bot responde:**
```
Para viajar a Cartagena desde cualquier ciudad de Colombia necesitas:

📋 Documentos:
- Cédula de ciudadanía (original)
- Tarjeta de identidad (para menores)

💉 Recomendaciones de Salud:
- Vacuna contra fiebre amarilla (recomendada)
- Protector solar
- Repelente de mosquitos

¿Te gustaría que te ayude con tu reserva? 😊
```

### 4. Ver Mis Reservas

**Usuario envía:**
```
Quiero ver mis reservas
```

**Bot responde:**
```
📋 Tus reservas activas:

1️⃣ Reserva R-0001
   - Destino: Cartagena
   - Fechas: 15-20 Dic 2025
   - Estado: Pendiente ⏳
   - Pago pendiente

¿Necesitas hacer algún cambio o consultar algo más?
```

---

## 🎯 Prompt del AI Agent (Sistema)

El prompt ya está incluido en el workflow, pero aquí está explicado:

```
Eres un asistente virtual de EFIG Vuelos, una agencia de viajes especializada.

FUNCIONES PRINCIPALES:
1. Registrar clientes nuevos
2. Crear reservas de vuelos
3. Registrar pagos
4. Consultar información
5. Ayuda general sobre viajes

HERRAMIENTAS DISPONIBLES:
- Postgres - Consultar Datos: Para buscar info en la BD
- Postgres - Registrar Cliente: Para nuevos clientes
- Postgres - Crear Reserva: Para nuevas reservas

COMPORTAMIENTO:
- Siempre amable y profesional
- Confirma datos antes de crear registros
- Usa las herramientas para todas las operaciones
- Da información útil sobre destinos
```

---

## 🔧 Personalización

### Agregar Más Herramientas:

Puedes agregar nodos adicionales para:

1. **Registrar Pagos**:
   ```json
   {
     "operation": "insert",
     "table": "pagos",
     "columns": {
       "id_reserva": "={{ $json.id_reserva }}",
       "monto": "={{ $json.monto }}",
       "metodo_pago": "={{ $json.metodo_pago }}"
     }
   }
   ```

2. **Actualizar Estado de Reserva**:
   ```json
   {
     "operation": "update",
     "table": "reservas",
     "updateKey": "id_reserva",
     "columns": {
       "estado": "confirmada"
     }
   }
   ```

3. **Enviar Notificaciones por Email**:
   - Agregar nodo "Send Email"
   - Conectar después de crear reserva

### Modificar el Prompt:

En el nodo "AI Agent - EFIG", puedes editar el "System Message" para:
- Cambiar el tono (más formal/informal)
- Agregar más instrucciones
- Incluir políticas de la agencia
- Agregar información de precios

---

## 📊 Monitoreo

### Ver Ejecuciones:
1. Ve a **Executions** en n8n Cloud
2. Verás cada conversación de Telegram como una ejecución
3. Click en cualquiera para ver el detalle completo

### Errores Comunes:

**Error: "Credenciales no encontradas"**
- Solución: Configurar las credenciales en cada nodo

**Error: "Model not found"**
- Solución: Verificar que Copilot API esté corriendo en GCP

**Error: "Connection refused"**
- Solución: Verificar que PostgreSQL esté corriendo y el firewall abierto

---

## 🚀 Mejoras Futuras

- [ ] Integrar con sistema de pagos (Stripe, PayU)
- [ ] Enviar confirmaciones por email
- [ ] Generar PDF con itinerario
- [ ] Recordatorios automáticos de viaje
- [ ] Integración con APIs de aerolíneas
- [ ] Dashboard de métricas
- [ ] Notificaciones de ofertas

---

**¡Tu workflow está listo para usar! Importa el archivo JSON y comienza a probarlo.** 🎉
