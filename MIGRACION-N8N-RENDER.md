# 🚀 Guía de Migración: n8n de ngrok a Render

## 📋 Resumen de la Migración
- **Desde**: ngrok (túnel temporal)
- **Hacia**: Render (hosting permanente)
- **Beneficios**: URL estable, SSL automático, mayor confiabilidad

---

## 🎯 PASO 1: Preparación del Repositorio

### 1.1 Crear estructura del proyecto
```
n8n-render/
├── Dockerfile
├── docker-compose.yml
├── render.yaml
├── .env.example
├── README.md
└── data/
    └── .gitkeep
```

### 1.2 Dockerfile para n8n
```dockerfile
FROM n8nio/n8n:latest

# Variables de entorno
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV WEBHOOK_URL=https://your-app-name.onrender.com
ENV N8N_EDITOR_BASE_URL=https://your-app-name.onrender.com

# Configuración de base de datos
ENV DB_TYPE=postgresdb
ENV DB_POSTGRESDB_HOST=${POSTGRES_HOST}
ENV DB_POSTGRESDB_PORT=${POSTGRES_PORT}
ENV DB_POSTGRESDB_DATABASE=${POSTGRES_DATABASE}
ENV DB_POSTGRESDB_USER=${POSTGRES_USER}
ENV DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
ENV DB_POSTGRESDB_SSL_ENABLED=true
ENV DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false

# Directorio de datos
WORKDIR /home/node/.n8n
VOLUME ["/home/node/.n8n"]

EXPOSE 5678

CMD ["n8n", "start"]
```

### 1.3 docker-compose.yml (para desarrollo local)
```yaml
version: '3.8'

services:
  n8n:
    build: .
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://localhost:5678
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=${POSTGRES_HOST}
      - DB_POSTGRESDB_PORT=${POSTGRES_PORT}
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DATABASE}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - n8n_data:/home/node/.n8n
    restart: unless-stopped

volumes:
  n8n_data:
```

### 1.4 render.yaml (configuración de Render)
```yaml
services:
  - type: web
    name: efig-n8n
    env: docker
    plan: starter
    dockerfilePath: ./Dockerfile
    envVars:
      - key: N8N_BASIC_AUTH_ACTIVE
        value: true
      - key: N8N_BASIC_AUTH_USER
        fromDatabase:
          name: efig-postgres
          property: user
      - key: N8N_BASIC_AUTH_PASSWORD
        generateValue: true
      - key: N8N_HOST
        value: 0.0.0.0
      - key: N8N_PORT
        value: 5678
      - key: N8N_PROTOCOL
        value: https
      - key: WEBHOOK_URL
        value: https://efig-n8n.onrender.com
      - key: N8N_EDITOR_BASE_URL
        value: https://efig-n8n.onrender.com
      - key: DB_TYPE
        value: postgresdb
      - key: DB_POSTGRESDB_HOST
        fromDatabase:
          name: efig-postgres
          property: host
      - key: DB_POSTGRESDB_PORT
        fromDatabase:
          name: efig-postgres
          property: port
      - key: DB_POSTGRESDB_DATABASE
        fromDatabase:
          name: efig-postgres
          property: database
      - key: DB_POSTGRESDB_USER
        fromDatabase:
          name: efig-postgres
          property: user
      - key: DB_POSTGRESDB_PASSWORD
        fromDatabase:
          name: efig-postgres
          property: password

databases:
  - name: efig-postgres
    plan: free
    databaseName: n8n_db
    user: n8n_user
```

---

## 🎯 PASO 2: Configuración en Render

### 2.1 Crear cuenta en Render
1. Ve a [render.com](https://render.com)
2. Regístrate con GitHub/GitLab
3. Conecta tu repositorio

### 2.2 Crear base de datos PostgreSQL
```
Dashboard → New → PostgreSQL
- Name: efig-postgres
- Database Name: n8n_db
- User: n8n_user
- Plan: Free (o Starter si necesitas más recursos)
- Region: Oregon (US West)
```

**Anota las credenciales:**
```
Internal Database URL: postgresql://user:password@host:port/database
External Database URL: postgresql://user:password@external-host:port/database
```

### 2.3 Crear Web Service
```
Dashboard → New → Web Service
- Connect Repository: tu-repo/n8n-render
- Name: efig-n8n
- Environment: Docker
- Plan: Starter ($7/mes)
- Region: Oregon (US West)
```

### 2.4 Variables de entorno en Render
```
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=tu-password-seguro
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://efig-n8n.onrender.com
N8N_EDITOR_BASE_URL=https://efig-n8n.onrender.com
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=tu-host-postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n_db
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_PASSWORD=tu-password-postgres
DB_POSTGRESDB_SSL_ENABLED=true
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false
```

---

## 🎯 PASO 3: Migrar Datos Existentes

### 3.1 Exportar workflows de n8n actual
```bash
# En tu n8n actual (ngrok)
1. Ve a Settings → Import/Export
2. Export all workflows como JSON
3. Guarda el archivo: workflows-backup.json
```

### 3.2 Exportar credenciales
```bash
# También exporta credenciales si las tienes
1. Settings → Credentials
2. Export credentials
3. Guarda: credentials-backup.json
```

### 3.3 Migrar base de datos (si usas PostgreSQL)
```bash
# Desde tu PostgreSQL actual
pg_dump -h 34.66.86.207 -p 5433 -U n8n -d n8n_db > n8n_backup.sql

# Hacia Render PostgreSQL
psql postgresql://user:password@host:port/database < n8n_backup.sql
```

---

## 🎯 PASO 4: Configuración Post-Despliegue

### 4.1 Verificar despliegue
```
URL: https://efig-n8n.onrender.com
Login: admin / tu-password
```

### 4.2 Importar workflows
```bash
1. Accede a https://efig-n8n.onrender.com
2. Settings → Import/Export
3. Import workflows desde workflows-backup.json
4. Import credentials desde credentials-backup.json
```

### 4.3 Actualizar webhooks
```bash
# Actualizar URLs en workflows que usen webhooks
Antes: https://abc123.ngrok.io/webhook/...
Después: https://efig-n8n.onrender.com/webhook/...
```

---

## 🎯 PASO 5: Configuración de Integraciones

### 5.1 Telegram Bot
```bash
# Actualizar webhook de Telegram
curl -X POST "https://api.telegram.org/bot{BOT_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://efig-n8n.onrender.com/webhook/telegram"}'
```

### 5.2 Copilot API
```bash
# Actualizar configuración del servidor Copilot
# En tu servidor (34.66.86.207:8002)
# Cambiar URL de n8n:
N8N_WEBHOOK_URL=https://efig-n8n.onrender.com/webhook/copilot
```

### 5.3 EFIG API
```bash
# Actualizar EFIG API server (34.66.86.207:3001)
# Cambiar configuraciones que apunten a n8n:
N8N_URL=https://efig-n8n.onrender.com
```

---

## 🎯 PASO 6: Monitoring y Mantenimiento

### 6.1 Monitoring en Render
```bash
# Render Dashboard → Service → Metrics
- CPU Usage
- Memory Usage  
- Response Times
- Error Rates
```

### 6.2 Logs en tiempo real
```bash
# Render Dashboard → Service → Logs
# O vía CLI:
render logs -s efig-n8n --tail
```

### 6.3 Backup automático
```yaml
# GitHub Actions para backup semanal
name: n8n Backup
on:
  schedule:
    - cron: '0 2 * * 0'  # Cada domingo a las 2 AM
jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Export workflows
        run: |
          curl -u admin:password \
            https://efig-n8n.onrender.com/rest/workflows \
            -o workflows-backup-$(date +%Y%m%d).json
```

---

## 🎯 PASO 7: Optimizaciones

### 7.1 Custom Domain (Opcional)
```bash
# En Render Dashboard
1. Settings → Custom Domains
2. Add: n8n.efigtravel.com
3. Configure DNS: CNAME n8n → efig-n8n.onrender.com
```

### 7.2 Performance
```dockerfile
# Optimizaciones en Dockerfile
ENV N8N_LOG_LEVEL=warn
ENV N8N_LOG_OUTPUT=file
ENV NODE_OPTIONS="--max-old-space-size=1024"
```

### 7.3 Security Headers
```yaml
# render.yaml - headers de seguridad
headers:
  - path: /*
    name: X-Frame-Options
    value: DENY
  - path: /*
    name: X-Content-Type-Options  
    value: nosniff
```

---

## 🎯 PASO 8: Testing y Validación

### 8.1 Tests de conectividad
```bash
# Test básico
curl -I https://efig-n8n.onrender.com

# Test webhook
curl -X POST https://efig-n8n.onrender.com/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"test": "message"}'
```

### 8.2 Test de workflows
```bash
1. Ejecuta cada workflow manualmente
2. Verifica logs en Render
3. Confirma integraciones (Telegram, API)
4. Test de notificaciones
```

---

## 📊 Comparación ngrok vs Render

| Aspecto | ngrok | Render |
|---------|-------|---------|
| **Estabilidad** | ❌ Túnel temporal | ✅ Hosting permanente |
| **URL** | ❌ Cambia cada sesión | ✅ URL fija |
| **SSL** | ✅ Automático | ✅ Automático |
| **Costo** | 💰 $8/mes (Pro) | 💰 $7/mes (Starter) |
| **Uptime** | ❌ Depende de local | ✅ 99.9% SLA |
| **Escalabilidad** | ❌ Limitada | ✅ Automática |
| **Monitoring** | ❌ Básico | ✅ Completo |
| **Backups** | ❌ Manual | ✅ Automático |

---

## 🚨 Troubleshooting

### Error: Database Connection
```bash
# Verificar variables de entorno
render shell efig-n8n
env | grep DB_

# Test conexión
psql $DATABASE_URL -c "SELECT version();"
```

### Error: Memory Limits
```yaml
# En render.yaml aumentar plan
plan: standard  # $25/mes, 2GB RAM
```

### Error: Webhook Timeout
```javascript
// En workflows, aumentar timeout
{
  "timeout": 30000,
  "retry": {
    "times": 3,
    "interval": 5000
  }
}
```

---

## 📝 Checklist Final

### Pre-Migration ✅
- [ ] Backup de workflows exportado
- [ ] Backup de credenciales exportado  
- [ ] Backup de base de datos creado
- [ ] Repositorio GitHub configurado
- [ ] Dockerfile y configuraciones listas

### Migration ✅
- [ ] Base de datos PostgreSQL en Render creada
- [ ] Web service en Render desplegado
- [ ] Variables de entorno configuradas
- [ ] SSL certificate activo
- [ ] URL https://efig-n8n.onrender.com accesible

### Post-Migration ✅
- [ ] Workflows importados y funcionando
- [ ] Credenciales configuradas
- [ ] Webhooks actualizados (Telegram, APIs)
- [ ] Tests de conectividad pasados
- [ ] Monitoring configurado
- [ ] Documentación actualizada

### Cleanup ✅
- [ ] ngrok tunnel cerrado
- [ ] Referencias de ngrok URL actualizadas
- [ ] Team notificado del cambio
- [ ] DNS records actualizados (si aplica)

---

## 🎯 URLs Finales

```
n8n Interface: https://efig-n8n.onrender.com
Webhook Base: https://efig-n8n.onrender.com/webhook/
Telegram Webhook: https://efig-n8n.onrender.com/webhook/telegram
API Webhook: https://efig-n8n.onrender.com/webhook/api
```

¡Tu n8n ahora está en producción con Render! 🚀