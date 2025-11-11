# 📚 DOCUMENTACIÓN BASE DE DATOS - EFIG Vuelos & Travel

## 🎯 PROPÓSITO
Sistema de gestión de reservas de vuelos con clientes, reservas y pagos. Incluye generación automática de IDs únicos y seguimiento completo del ciclo de vida de una reserva.

---

## 📊 ESTRUCTURA DE LA BASE DE DATOS

### **Servidor:**
- Host: 34.66.86.207
- Puerto: 5433 (externo) → 5432 (interno Docker)
- Database: n8n_db
- Usuario: n8n
- Password: n8npass
- Contenedor: postgres_cloud

---

## 🗂️ TABLAS Y ESQUEMA

### **1️⃣ TABLA: clientes**
Almacena información de los clientes del sistema.

**Columnas:**

| Columna | Tipo | Restricciones | Default | Descripción |
|---------|------|---------------|---------|-------------|
| `id` | SERIAL | PRIMARY KEY | auto | ID numérico interno |
| `id_cliente` | TEXT | UNIQUE, NOT NULL | `''` | ID formato C-XXXX (ej: C-0001) |
| `nombre_completo` | TEXT | NOT NULL | - | Nombre completo del cliente |
| `email` | TEXT | NOT NULL | - | Correo electrónico |
| `telefono` | TEXT | NOT NULL | - | Número de teléfono |
| `documento` | TEXT | nullable | NULL | Cédula/pasaporte |
| `fecha_registro` | DATE | NOT NULL | CURRENT_DATE | Fecha de registro |
| `tipo_cliente` | TEXT | NOT NULL | `'nuevo'` | Tipo: 'nuevo', 'frecuente', 'VIP', 'admin' |
| `telegram_id` | BIGINT | UNIQUE, nullable | NULL | ID de Telegram del usuario |

**Trigger:**
- `generate_id_cliente()`: BEFORE INSERT - Genera automáticamente `id_cliente` en formato C-XXXX
  - Formato: 'C-' + número de 4 dígitos con ceros a la izquierda
  - Ejemplo: C-0001, C-0023, C-0156
  - Se calcula como MAX(id_cliente) + 1

**Índices:**
- `idx_clientes_telegram_id` en `telegram_id`

**Ejemplo de INSERT:**
```sql
INSERT INTO clientes (nombre_completo, email, telefono, documento, tipo_cliente)
VALUES ('Juan Pérez', 'juan@mail.com', '310-5555555', '12345678', 'nuevo')
RETURNING *;
-- Resultado: id_cliente = 'C-0034' (generado automáticamente)
```

**Roles importantes:**
- `tipo_cliente = 'admin'`: Tiene acceso completo al sistema
- `tipo_cliente = 'cliente'` o cualquier otro: Acceso limitado a sus propios datos

---

### **2️⃣ TABLA: reservas**
Almacena las reservas de vuelos/servicios de los clientes.

**Columnas:**

| Columna | Tipo | Restricciones | Default | Descripción |
|---------|------|---------------|---------|-------------|
| `id` | SERIAL | PRIMARY KEY | auto | ID numérico interno |
| `id_reserva` | TEXT | UNIQUE, NOT NULL | `''` | ID formato R-XXXX (ej: R-0001) |
| `id_cliente` | TEXT | NOT NULL, FK | `''` | Referencia a clientes.id_cliente |
| `tipo` | TEXT | NOT NULL | - | Tipo: 'vuelo', 'hotel', 'paquete' |
| `origen` | TEXT | nullable | NULL | Ciudad de origen |
| `destino` | TEXT | NOT NULL | - | Ciudad de destino |
| `fecha_salida` | DATE | NOT NULL | - | Fecha de salida |
| `fecha_regreso` | DATE | nullable | NULL | Fecha de regreso (si aplica) |
| `estado` | TEXT | NOT NULL | - | Estado: 'pendiente', 'confirmada', 'cancelada', 'completada' |
| `precio` | NUMERIC(10,2) | NOT NULL | - | Precio en COP |
| `notas` | TEXT | nullable | NULL | Observaciones adicionales |

**Trigger:**
- `generate_id_reserva()`: BEFORE INSERT - Genera automáticamente `id_reserva` en formato R-XXXX
  - Formato: 'R-' + número de 4 dígitos con ceros a la izquierda
  - Ejemplo: R-0001, R-0019, R-0234

**Foreign Key:**
- `fk_cliente`: `id_cliente` → `clientes.id_cliente`

**Ejemplo de INSERT:**
```sql
INSERT INTO reservas (id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, precio, estado, notas)
VALUES ('C-0034', 'vuelo', 'Bogotá', 'Cartagena', '2025-12-15', '2025-12-20', 850000, 'pendiente', 'Cliente VIP')
RETURNING *;
-- Resultado: id_reserva = 'R-0019' (generado automáticamente)
```

**Estados del ciclo de vida:**
1. `pendiente`: Reserva creada, esperando confirmación/pago
2. `confirmada`: Reserva confirmada y pagada
3. `completada`: Viaje realizado
4. `cancelada`: Reserva cancelada

---

### **3️⃣ TABLA: pagos**
Registra los pagos asociados a las reservas.

**Columnas:**

| Columna | Tipo | Restricciones | Default | Descripción |
|---------|------|---------------|---------|-------------|
| `id` | SERIAL | PRIMARY KEY | auto | ID numérico interno |
| `id_pago` | TEXT | UNIQUE, NOT NULL | `''` | ID formato P-XXXX (ej: P-0001) |
| `id_reserva` | TEXT | NOT NULL, FK | `''` | Referencia a reservas.id_reserva |
| `monto` | NUMERIC(10,2) | NOT NULL | - | Monto pagado en COP |
| `fecha` | DATE | NOT NULL | CURRENT_DATE | Fecha del pago |
| `metodo` | TEXT | NOT NULL | - | Método: 'efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'nequi', 'daviplata' |
| `estado` | TEXT | NOT NULL | - | Estado: 'pendiente', 'completado', 'fallido', 'reembolsado' |

**Trigger:**
- `generate_id_pago()`: BEFORE INSERT - Genera automáticamente `id_pago` en formato P-XXXX
  - Formato: 'P-' + número de 4 dígitos con ceros a la izquierda
  - Ejemplo: P-0001, P-0012, P-0345

**Foreign Key:**
- `fk_reserva`: `id_reserva` → `reservas.id_reserva`

**Ejemplo de INSERT:**
```sql
INSERT INTO pagos (id_reserva, monto, metodo, estado)
VALUES ('R-0019', 850000, 'tarjeta_credito', 'completado')
RETURNING *;
-- Resultado: id_pago = 'P-0012' (generado automáticamente)
```

---

### **4️⃣ TABLA: chat_history**
Almacena el historial de conversaciones para memoria del chatbot.

**Columnas:**

| Columna | Tipo | Restricciones | Default | Descripción |
|---------|------|---------------|---------|-------------|
| `id` | SERIAL | PRIMARY KEY | auto | ID numérico interno |
| `session_id` | VARCHAR(255) | NOT NULL | - | ID de la sesión (telegram_id) |
| `type` | VARCHAR(50) | NOT NULL | - | Tipo: 'human', 'ai' |
| `message` | TEXT | NOT NULL | - | Contenido del mensaje |
| `created_at` | TIMESTAMP | NOT NULL | CURRENT_TIMESTAMP | Timestamp del mensaje |

**Índices:**
- `idx_chat_history_session` en `session_id`

**Ejemplo de INSERT:**
```sql
INSERT INTO chat_history (session_id, type, message)
VALUES ('987654321', 'human', 'Quiero reservar un vuelo a Cartagena');

INSERT INTO chat_history (session_id, type, message)
VALUES ('987654321', 'ai', 'Claro, ¿para qué fecha necesitas el vuelo?');
```

---

## 🔗 RELACIONES ENTRE TABLAS

```
clientes (1) ──────< (N) reservas (1) ──────< (N) pagos
   ↓                        ↓                       ↓
id_cliente ────FK────> id_cliente        id_reserva ────FK────> id_reserva
```

**Ejemplo de datos relacionados:**
```
Cliente C-0038 (María Fernanda López)
  └─ Reserva R-0019 (Cartagena, $850,000)
       └─ Pago P-0012 (Tarjeta crédito, Completado)
```

---

## 🤖 INSTRUCCIONES PARA EL LLM

### **ROLES Y PERMISOS:**

**Si tipo_cliente = 'admin':**
- ✅ Puede ver TODOS los clientes, reservas y pagos
- ✅ Puede crear clientes para otras personas
- ✅ Puede crear reservas para cualquier cliente
- ✅ Puede crear pagos para cualquier reserva
- ✅ Puede actualizar estados

**Si tipo_cliente = 'nuevo', 'frecuente', 'VIP' (cliente normal):**
- ✅ Puede ver solo SUS propias reservas y pagos
- ✅ Puede crear reservas para sí mismo (usando su id_cliente)
- ❌ NO puede ver datos de otros clientes
- ❌ NO puede crear clientes

**Si telegram_id NO existe en la tabla:**
- ⚠️ Usuario no registrado
- Debe pedir: nombre_completo, email, telefono
- Opcional: documento, tipo_cliente

---

### **FORMATO DE QUERIES:**

**✅ CREAR CLIENTE (INSERT):**
```sql
INSERT INTO clientes (nombre_completo, email, telefono, documento, tipo_cliente)
VALUES ('Nombre Completo', 'email@ejemplo.com', '300-0000000', '12345678', 'nuevo')
RETURNING *;
```
**Nota:** NO incluir `id` ni `id_cliente` en el INSERT (se generan automáticamente)

**✅ CREAR RESERVA (INSERT):**
```sql
INSERT INTO reservas (id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, precio, estado, notas)
VALUES ('C-0034', 'vuelo', 'Bogotá', 'Cartagena', '2025-12-15', '2025-12-20', 850000, 'pendiente', 'Observaciones')
RETURNING *;
```
**Nota:** NO incluir `id` ni `id_reserva` en el INSERT

**✅ CREAR PAGO (INSERT):**
```sql
INSERT INTO pagos (id_reserva, monto, metodo, estado)
VALUES ('R-0019', 850000, 'tarjeta_credito', 'completado')
RETURNING *;
```
**Nota:** NO incluir `id` ni `id_pago` en el INSERT

**✅ VER RESERVAS DE UN CLIENTE:**
```sql
SELECT r.*, c.nombre_completo 
FROM reservas r 
LEFT JOIN clientes c ON r.id_cliente = c.id_cliente 
WHERE r.id_cliente = 'C-0034'
ORDER BY r.id DESC;
```

**✅ VER TODAS LAS RESERVAS (Admin):**
```sql
SELECT r.*, c.nombre_completo 
FROM reservas r 
LEFT JOIN clientes c ON r.id_cliente = c.id_cliente 
ORDER BY r.id DESC 
LIMIT 50;
```

**✅ VER PAGOS DE UN CLIENTE:**
```sql
SELECT p.*, r.id_cliente, r.destino 
FROM pagos p 
LEFT JOIN reservas r ON p.id_reserva = r.id_reserva 
WHERE r.id_cliente = 'C-0034'
ORDER BY p.id DESC;
```

**✅ ACTUALIZAR ESTADO DE RESERVA:**
```sql
UPDATE reservas 
SET estado = 'confirmada' 
WHERE id_reserva = 'R-0019'
RETURNING *;
```

---

### **VALIDACIONES IMPORTANTES:**

1. **Siempre verificar que el usuario exista:**
   ```sql
   SELECT id_cliente, tipo_cliente, telegram_id 
   FROM clientes 
   WHERE telegram_id = {{ telegram_id_del_usuario }}
   ```

2. **Para crear reserva, validar que id_cliente exista:**
   ```sql
   SELECT id_cliente FROM clientes WHERE id_cliente = 'C-0034'
   ```

3. **Para crear pago, validar que id_reserva exista:**
   ```sql
   SELECT id_reserva FROM reservas WHERE id_reserva = 'R-0019'
   ```

4. **Fechas siempre en formato 'YYYY-MM-DD':**
   - ✅ '2025-12-15'
   - ❌ '15/12/2025'
   - ❌ '15-12-2025'

5. **Precios sin símbolo de moneda:**
   - ✅ 850000
   - ❌ '$850000'
   - ❌ '850.000'

---

### **RESPUESTAS AL USUARIO:**

**Cuando creas un cliente:**
```
✅ Cliente registrado exitosamente

📋 Detalles:
• ID: C-0038
• Nombre: María Fernanda López
• Email: maria.lopez@mail.com
• Tipo: VIP

¡Bienvenido a EFIG Vuelos & Travel! ✈️
```

**Cuando creas una reserva:**
```
✅ Reserva creada exitosamente

🎫 Detalles:
• ID: R-0019
• Cliente: C-0038
• Destino: Cartagena
• Fecha salida: 2025-12-15
• Precio: $850,000 COP
• Estado: pendiente

¡Buen viaje! 🌍
```

**Cuando creas un pago:**
```
✅ Pago registrado exitosamente

💳 Detalles:
• ID: P-0012
• Reserva: R-0019
• Monto: $850,000 COP
• Método: tarjeta_credito
• Estado: completado

¡Gracias! 💚
```

**Cuando listas reservas:**
```
📊 Tus reservas (3)

1. `R-0019` - Cartagena
   Cliente: María Fernanda López
   Fecha: 2025-12-15 | $850,000
   Estado: confirmada

2. `R-0018` - Bogotá
   Cliente: María Fernanda López
   Fecha: 2025-11-20 | $450,000
   Estado: completada

3. `R-0015` - Medellín
   Cliente: María Fernanda López
   Fecha: 2025-10-05 | $380,000
   Estado: cancelada
```

---

## 🎯 CASOS DE USO COMUNES

### **1. Usuario nuevo quiere registrarse:**
```
Usuario: "Quiero registrarme"
LLM: Analiza → action: "CREAR_CLIENTE"
     Extrae: nombre_completo, email, telefono
     Ejecuta: INSERT INTO clientes...
     Responde: "✅ Cliente registrado! ID: C-0039"
```

### **2. Cliente quiere ver sus reservas:**
```
Usuario: "Muéstrame mis reservas"
LLM: Verifica → tipo_cliente = 'VIP' (no admin)
     Ejecuta: SELECT * FROM reservas WHERE id_cliente = 'C-0038'
     Responde: Lista con formato amigable
```

### **3. Admin quiere ver todos los clientes:**
```
Usuario: "Lista todos los clientes"
LLM: Verifica → tipo_cliente = 'admin' ✅
     Ejecuta: SELECT * FROM clientes ORDER BY id DESC LIMIT 50
     Responde: Lista completa con formato
```

### **4. Cliente quiere reservar un vuelo:**
```
Usuario: "Reserva un vuelo a Cartagena para el 20 de diciembre, precio 500000"
LLM: Analiza → action: "CREAR_MI_RESERVA"
     Extrae: destino='Cartagena', fecha_salida='2025-12-20', precio=500000
     Completa: id_cliente='C-0038', tipo='vuelo', estado='pendiente'
     Ejecuta: INSERT INTO reservas...
     Responde: "✅ Reserva creada! ID: R-0020"
```

---

## ⚠️ ERRORES COMUNES A EVITAR

1. **NO incluir id, id_cliente, id_reserva, id_pago en INSERT:**
   - ❌ `INSERT INTO clientes (id, id_cliente, nombre_completo...)`
   - ✅ `INSERT INTO clientes (nombre_completo, email...)`

2. **NO usar comillas dobles en valores de texto:**
   - ❌ `VALUES ("Juan Pérez"...)`
   - ✅ `VALUES ('Juan Pérez'...)`

3. **NO olvidar validar foreign keys:**
   - Antes de INSERT en reservas → verificar que id_cliente existe
   - Antes de INSERT en pagos → verificar que id_reserva existe

4. **NO permitir a clientes normales ver datos de otros:**
   - Siempre filtrar por `id_cliente` si tipo_cliente != 'admin'

5. **NO olvidar el formato de fecha:**
   - Siempre 'YYYY-MM-DD'

---

## 📝 CAMPOS OPCIONALES vs REQUERIDOS

### **clientes:**
- Requeridos: nombre_completo, email, telefono
- Opcionales: documento, tipo_cliente (default 'nuevo'), telegram_id

### **reservas:**
- Requeridos: id_cliente, tipo, destino, fecha_salida, precio, estado
- Opcionales: origen, fecha_regreso, notas

### **pagos:**
- Requeridos: id_reserva, monto, metodo, estado
- Opcionales: ninguno (fecha tiene DEFAULT)

---

## 🔄 FLUJO COMPLETO DE UNA RESERVA

```
1. Cliente se registra
   → INSERT INTO clientes
   → Genera: C-0039

2. Cliente crea reserva
   → INSERT INTO reservas (id_cliente='C-0039')
   → Genera: R-0020
   → Estado: 'pendiente'

3. Cliente realiza pago
   → INSERT INTO pagos (id_reserva='R-0020')
   → Genera: P-0013
   → Estado pago: 'completado'

4. Admin confirma reserva
   → UPDATE reservas SET estado='confirmada' WHERE id_reserva='R-0020'

5. Cliente viaja

6. Admin completa reserva
   → UPDATE reservas SET estado='completada' WHERE id_reserva='R-0020'
```

---

## 🎓 RESUMEN PARA EL LLM

**Cuando recibas un mensaje de usuario:**

1. **Verificar usuario:** Query a clientes con telegram_id
2. **Identificar rol:** admin o cliente normal
3. **Analizar intención:** CREAR_CLIENTE, CREAR_RESERVA, VER_RESERVAS, etc.
4. **Validar permisos:** ¿El rol permite esta acción?
5. **Extraer datos:** Parsear campos del mensaje
6. **Construir query:** INSERT/SELECT/UPDATE según acción
7. **Ejecutar:** Usar executeQuery con valores interpolados
8. **Formatear respuesta:** Mensaje amigable con emojis

**Recuerda:**
- ✅ Los IDs (C-XXXX, R-XXXX, P-XXXX) se generan automáticamente
- ✅ Clientes normales solo ven sus propios datos
- ✅ Admins ven todo
- ✅ Siempre usar RETURNING * para obtener los datos insertados
- ✅ Formatear respuestas con emojis y Markdown

---

## 📞 INFORMACIÓN DE CONEXIÓN

```javascript
// PostgreSQL Connection
{
  host: '34.66.86.207',
  port: 5433,
  database: 'n8n_db',
  user: 'n8n',
  password: 'n8npass'
}
```

**Credential ID en n8n:** `zp8jhHXrxcbGGmQO` (nombre: "DBSD")

---

**Última actualización:** 2025-11-05
**Total de clientes:** 43+ (hasta C-0038)
**Total de reservas:** 55+ (hasta R-0019)
**Total de pagos:** 32+ (hasta P-0012)
