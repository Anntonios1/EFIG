# 🚀 Instrucciones para Deploy en Render - EFIG Travel Agency

## 📋 Paso a Paso para Crear el Servicio

### 1. Acceder a Render Dashboard
- Ve a: https://dashboard.render.com
- Asegúrate de estar logueado con tu cuenta GitHub

### 2. Crear Nuevo Web Service
1. Click en **"New +"** en el dashboard
2. Selecciona **"Web Service"**
3. Conecta tu repositorio GitHub: `Anntonios1/EFIG`

### 3. Configurar el Servicio
```
Name: efig-n8n-production
Environment: Docker
Region: Oregon (US West) - Recomendado por latencia
Branch: main
Dockerfile Path: ./Dockerfile
```

### 4. Variables de Entorno (Environment Variables)
Agrega estas variables una por una:

```bash
# Base de datos PostgreSQL (GCP)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=34.66.86.207
DB_POSTGRESDB_PORT=5433
DB_POSTGRESDB_DATABASE=n8n_db
DB_POSTGRESDB_USER=postgres
DB_POSTGRESDB_PASSWORD=n8n2024secure

# Configuración n8n
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=EFIGTravel2024!
N8N_HOST=efig-n8n-production.onrender.com
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://efig-n8n-production.onrender.com
N8N_EDITOR_BASE_URL=https://efig-n8n-production.onrender.com

# Telegram
N8N_TELEGRAM_BOT_TOKEN=TU_TOKEN_TELEGRAM_AQUI

# GitHub Copilot API (opcional)
GITHUB_COPILOT_TOKEN=TU_TOKEN_GITHUB_AQUI

# Seguridad y Performance
N8N_SECURE_COOKIE=true
N8N_LOG_LEVEL=info
N8N_METRICS=true
```

### 5. Plan de Render
- **Starter Plan**: $7/mes (512 MB RAM, 0.1 CPU)
- **Starter Pro**: $25/mes (2 GB RAM, 1 CPU) - **RECOMENDADO**

### 6. Deploy Automático
1. Render detectará automáticamente el `render.yaml` 
2. Construirá la imagen Docker
3. Desplegará la aplicación
4. Te dará la URL: `https://efig-n8n-production.onrender.com`

## ✅ Verificación Post-Deploy

### 1. Acceso a n8n
- URL: https://efig-n8n-production.onrender.com
- Usuario: admin
- Contraseña: EFIGTravel2024!

### 2. Verificar Base de Datos
- Debería conectarse automáticamente a PostgreSQL en GCP
- Verificar que las tablas n8n se crean correctamente

### 3. Configurar Telegram Bot
Una vez desplegado:
1. Ir a configuración de Telegram en n8n
2. Actualizar webhook URL a: `https://efig-n8n-production.onrender.com/webhook/telegram`
3. Reactivar workflows de Telegram

## 🔧 Solución de Problemas

### Si el deploy falla:
1. Revisar logs en Render Dashboard
2. Verificar variables de entorno
3. Comprobar conectividad a base de datos

### Si n8n no inicia:
1. Verificar credenciales de PostgreSQL
2. Revisar configuración de networking en GCP
3. Comprobar que el puerto 5433 esté abierto

## 📞 Siguiente Paso
Una vez que el deploy esté listo, configuraré los webhooks de Telegram y verificaré que todo funcione correctamente.