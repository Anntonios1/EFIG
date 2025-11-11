# ✅ Base de Datos Re-inicializada Correctamente

Fecha: 2025-11-02
Estado: PostgreSQL corriendo con esquema actualizado

## Tablas creadas

- **clientes** (id_cliente, nombre_completo, email, telefono, documento, fecha_registro, tipo_cliente)
- **reservas** (id_reserva, id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, estado, precio, notas)
- **pagos** (id_pago, id_reserva, monto, fecha, metodo, estado)

## Datos de ejemplo

- Cliente C-0001 (Ana Perez, ana@example.com) insertado correctamente

## Siguiente paso: Configurar n8n

### 1. Levantar n8n (si aún no lo hiciste)

Opción A: Ejecutar n8n en Docker (temporal):

```powershell
docker run -it --rm -p 5678:5678 `
  -e N8N_BASIC_AUTH_ACTIVE=false `
  -e WEBHOOK_URL=http://localhost:5678/ `
  --name n8n-temp `
  n8nio/n8n:latest
```

Opción B: Si tienes n8n instalado localmente:

```powershell
n8n start
```

### 2. Acceder a n8n

Abre http://localhost:5678 en tu navegador.

### 3. Crear credencial PostgreSQL

1. Ve a **Settings → Credentials → Add Credential**
2. Busca **Postgres** y selecciónalo
3. Completa los campos:
   - **Host**: `host.docker.internal` (o `localhost` si n8n corre fuera de Docker)
   - **Port**: `5432`
   - **Database**: `n8n_db`
   - **User**: `n8n`
   - **Password**: `n8npass`
4. Haz clic en **Test** y luego **Save**

### 4. Importar workflow

1. Ve a **Workflows → Import from File**
2. Selecciona `workflows/register_cliente_postgres_n8n.json`
3. Una vez importado, abre el workflow
4. En el nodo **Postgres**, selecciona la credencial que acabas de crear
5. **Opcional**: Configura los nodos **Gmail** y **Telegram** con tus credenciales (o desactívalos si solo quieres probar la DB)
6. **IMPORTANTE**: Activa el workflow haciendo clic en el toggle "Active" en la esquina superior derecha

### 5. Probar el webhook

Desde PowerShell:

```powershell
$body = @{ 
    nombre = 'Juan Perez'
    email = 'juan@example.com'
    telefono = '+34123456780'
    documento = 'Y9876543'
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://localhost:5678/webhook/nuevo-cliente' `
  -Method Post `
  -Body $body `
  -ContentType 'application/json'
```

### 6. Verificar inserción en la DB

```powershell
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "SELECT id_cliente, nombre_completo, email FROM clientes ORDER BY id DESC LIMIT 5;"
```

### Script de prueba automático

Si quieres probar todo el flujo automáticamente:

```powershell
.\scripts\test_sistema.ps1
```

Este script verifica que n8n esté corriendo, registra un cliente, verifica la inserción en la DB y muestra un resumen.

---

## Siguientes pasos recomendados

1. Importar y activar `workflows/register_reserva_postgres_n8n.json` para probar el registro de reservas
2. Implementar workflow de recordatorios automáticos (cron que consulta reservas próximas)
3. Añadir validaciones (ej.: verificar que cliente existe antes de crear reserva)
4. Configurar backups automáticos de la base de datos

Para cualquier duda, revisa `SCHEMA.md` donde está toda la documentación del esquema con ejemplos de consultas.
