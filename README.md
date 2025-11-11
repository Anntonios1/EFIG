# Sistema de Gestión para Agencia - Artefactos de ejemplo

Este repositorio contiene artefactos de ejemplo para implementar los workflows de una agencia de viajes en n8n.

Contenido creado (resumen):
- `sheets/Clientes.csv`, `sheets/Reservas.csv`, `sheets/Pagos.csv` — CSVs de ejemplo con datos.
- `workflows/register_cliente_n8n.json` — workflow original (Google Sheets).
- `workflows/register_cliente_postgres_n8n.json` — workflow adaptado a PostgreSQL.
- `workflows/register_reserva_postgres_n8n.json` — workflow (reserva) adaptado a PostgreSQL.
- `web/form.html` — formulario HTML de prueba.
- `templates/welcome_email.txt` — plantilla de email de bienvenida.
- `docker-compose.yml` y `db/init.sql` — PostgreSQL en Docker y esquema actualizado.
- `SCHEMA.md` — documentación completa del esquema de base de datos con ejemplos de consultas.
- `scripts/reinit_db.ps1` — script para re-inicializar la base si ya la levantaste antes.
- `scripts/test_sistema.ps1` — script de prueba automático que registra cliente/reserva y verifica la DB.

Asunciones por defecto (si no indicas otra):
- Base de datos: PostgreSQL en Docker (local).
- Envío de emails: Gmail (credenciales en n8n).
- Notificación interna: Telegram (bot + chatId) o Email.

-----

## Uso rápido: PostgreSQL en Docker

### Primera vez (o re-inicialización)

Si ya levantaste el contenedor antes y necesitas aplicar el esquema actualizado:

```powershell
cd "c:\Users\teamp\Documents\N8N FINAL"
.\scripts\reinit_db.ps1
```

Este script detiene el contenedor, elimina `db/data` y vuelve a levantar PostgreSQL con el esquema actualizado.

### Levantar normalmente

Si es la primera vez o ya re-inicializaste:

```powershell
cd "c:\Users\teamp\Documents\N8N FINAL"
docker-compose up -d
```

### Verificar tablas creadas

El archivo `db/init.sql` se ejecuta automáticamente en la primera inicialización:

```powershell
docker exec -it n8n_postgres psql -U n8n -d n8n_db -c "\dt"
```

3) Configura credencial en n8n (Credentials → Postgres):
- Host: `host.docker.internal` (o `localhost` si n8n corre localmente)
- Port: `5432`
- Database: `n8n_db`
- User: `n8n`
- Password: `n8npass`

4) Importa el workflow adaptado:

- En n8n → Workflows → Import → From File → selecciona `workflows/register_cliente_postgres_n8n.json`.
- Edita los nodos `Postgres` para seleccionar la credencial creada.

5) Probar el webhook desde PowerShell:

```powershell
$body = @{ nombre = 'Juan Perez'; email = 'juan@example.com'; telefono = '+34123456780'; documento = 'Y9876543' }
Invoke-RestMethod -Uri 'http://localhost:5678/webhook/nuevo-cliente' -Method Post -Body $body
```

Notas importantes:
- `db/init.sql` se monta en `/docker-entrypoint-initdb.d/` y solo se ejecuta la primera vez que se crea el volumen `db/data`. Si necesitas re-inicializar, detén el contenedor y borra `db/data`.
- El workflow JSON incluye placeholders (por ejemplo `YOUR_GMAIL_ADDRESS`, `YOUR_TELEGRAM_CHAT_ID`) que debes completar en n8n antes de activar.

-----

## Qué hay en los workflows Postgres

- `register_cliente_postgres_n8n.json`: Webhook → Set (formatea campos) → Postgres (insert en `clients`) → Gmail → Telegram.
- `register_reserva_postgres_n8n.json`: Webhook → Set → Postgres insert en `reservas` → (opcional) Google Calendar.

Puntos a ajustar después de importar:
- Reemplazar credenciales Postgres en n8n.
- Configurar credenciales Gmail y Telegram.
- En el nodo Webhook, valida la ruta si cambias el path.

-----

## Siguientes pasos sugeridos (puedo implementarlos):

- Crear workflow de recordatorios (cron) que consulte `reservas` en Postgres y envíe notificaciones 48h antes.
- Añadir búsqueda/relación: workflow de reserva que verifique que `idcliente` existe y, si no, devuelva error o cree el cliente.
- Preparar script de prueba que invoque webhooks y verifique inserciones consultando la DB dentro del contenedor.

Si quieres que implemente alguno de estos pasos ahora, dime cuál y lo hago: 1) Workflow reserva, 2) Recordatorios, 3) Script de prueba automático.
