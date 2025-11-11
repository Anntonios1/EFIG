# Guía Visual - Activar Workflow en n8n

## ✅ ESTADO DEL SISTEMA
- PostgreSQL: ✓ Corriendo (puerto 5432)
- n8n: ✓ Corriendo (http://localhost:5678)
- Workflow: ✗ NO ACTIVO (por eso el error 404)

---

## 📋 PASOS PARA ACTIVAR EL WORKFLOW

### PASO 1: Abrir n8n
```
Abre tu navegador → http://localhost:5678
```

---

### PASO 2: Crear Credencial de PostgreSQL

```
┌──────────────────────────────────────────┐
│  n8n Interface                      [👤] │ ← Haz clic en tu avatar
├──────────────────────────────────────────┤
│  🏠 Workflows                             │
│  📊 Executions                            │
│  ⚙️  Settings     ← Clic aquí           │
│     └─ Credentials ← Luego aquí          │
└──────────────────────────────────────────┘
```

Luego:
1. Botón **[+ Add Credential]**
2. Buscar: **"Postgres"**
3. Completar:
   ```
   Credential Name: Postgres Local (o como quieras)
   Host: host.docker.internal
   Port: 5432
   Database: n8n_db
   User: n8n
   Password: n8npass
   SSL: Disabled
   ```
4. Botón **[Test]** (debe decir "Connection successful")
5. Botón **[Save]**

---

### PASO 3: Importar Workflow

```
┌──────────────────────────────────────────┐
│  Workflows                     [+ Add]   │ ← Clic en "+ Add workflow"
└──────────────────────────────────────────┘
```

Se abre el editor vacío. Arriba a la derecha:

```
┌──────────────────────────────────────────────────────────┐
│  Workflow Name              [Save] [Execute] [Inactive] [⋮] │ ← Clic en ⋮ (tres puntos)
└──────────────────────────────────────────────────────────┘
```

Menú desplegable:
- Import from File ← **Selecciona esto**
- Navega a: `C:\Users\teamp\Documents\N8N FINAL\workflows\register_cliente_postgres_n8n.json`
- Clic **[Open]**

---

### PASO 4: Configurar el Nodo Postgres

El workflow se carga en el canvas. Verás algo así:

```
[Webhook] → [Set] → ┌─ [Postgres]
                     ├─ [Gmail Send]
                     └─ [Telegram]
```

1. Haz clic en el nodo **[Postgres]** (el rectángulo en el canvas)
2. En el panel derecho, busca la sección **"Credential to connect with"**
3. En el dropdown, selecciona la credencial que creaste: **"Postgres Local"**
4. (Opcional) Clic en **[Test step]** para verificar que conecta

---

### PASO 5: (OPCIONAL) Desactivar Gmail y Telegram

Si NO quieres configurar Gmail/Telegram ahora:

1. Haz clic derecho en el nodo **[Gmail Send]** → **Disable**
2. Haz clic derecho en el nodo **[Telegram]** → **Disable**
3. Guarda (Ctrl+S o botón Save arriba)

Los nodos desactivados se verán atenuados pero el workflow funcionará.

---

### PASO 6: 🔴 ACTIVAR EL WORKFLOW (CRÍTICO)

Arriba a la derecha verás un toggle:

```
┌──────────────────────────────────────────────────┐
│  [Save] [Execute Workflow] [Inactive ⚪] [⋮]     │ ← Haz clic en "Inactive"
└──────────────────────────────────────────────────┘

Después:
┌──────────────────────────────────────────────────┐
│  [Save] [Execute Workflow] [Active ✅] [⋮]       │ ← Debe cambiar a "Active" en verde
└──────────────────────────────────────────────────┘
```

**¡IMPORTANTE!** Sin activar el workflow, el webhook de producción NO existe y seguirás teniendo el error 404.

---

## 🧪 PROBAR EL WEBHOOK

Una vez ACTIVADO el workflow, vuelve a PowerShell y ejecuta:

```powershell
# Crear el body JSON
$body = @{ 
    nombre = "Juan Perez"
    email = "juan@example.com"
    telefono = "+34123456780"
    documento = "Y9876543"
} | ConvertTo-Json

# Llamar al webhook
Invoke-RestMethod -Uri "http://localhost:5678/webhook/nuevo-cliente" `
  -Method Post `
  -Body $body `
  -ContentType "application/json"
```

**Resultado esperado:** Silencio (sin error 404) o un JSON de respuesta vacío/exitoso.

---

## ✅ VERIFICAR LA INSERCIÓN EN LA BASE DE DATOS

```powershell
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_cliente, nombre_completo, email FROM clientes ORDER BY id DESC LIMIT 5;"
```

Deberías ver:
```
 id_cliente | nombre_completo |        email        
------------+-----------------+---------------------
 C-XXXX     | Juan Perez      | juan@example.com
 C-0001     | Ana Perez       | ana@example.com
```

---

## 🔍 TROUBLESHOOTING

### Error: "Connection refused" al crear credencial
- **Causa:** n8n corre en Docker y no puede alcanzar `localhost`
- **Solución:** Usa `host.docker.internal` en vez de `localhost` en el campo Host

### Sigo teniendo 404 después de activar
- **Causa:** El workflow no se guardó activo
- **Solución:** Verifica que el toggle esté en verde "Active", guarda (Ctrl+S) y recarga la página de n8n

### El nodo Postgres da error al ejecutar
- **Causa:** Credencial mal configurada o PostgreSQL no está corriendo
- **Solución:** 
  1. Verifica: `docker ps --filter name=n8n_postgres`
  2. Re-crea la credencial con los datos exactos de arriba

### No veo el webhook después de activar
- **Causa:** El path del webhook puede ser diferente
- **Solución:** En el nodo Webhook, verifica que el campo "Path" sea `nuevo-cliente`

---

## 📚 ARCHIVOS DE REFERENCIA

- Esquema completo de DB: `SCHEMA.md`
- Instrucciones generales: `INSTRUCCIONES.md`
- README principal: `README.md`
- Workflow de reservas: `workflows/register_reserva_postgres_n8n.json` (para después)

---

¿Necesitas ayuda con algún paso específico? Dime en qué parte estás y te ayudo.
