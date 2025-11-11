# 🚀 GUÍA DE CONFIGURACIÓN RENDER - VARIABLES DE ENTORNO

## 📍 URL del Dashboard
https://dashboard.render.com/web/srv-d49j6gv5r7bs73bbp8hg/env

---

## 🔧 VARIABLES DE ENTORNO A CONFIGURAR

**Copia y pega cada variable una por una en Render:**

### 1. Configuración Básica
```
NODE_ENV = production
N8N_HOST = 0.0.0.0
N8N_PORT = 5678
N8N_PROTOCOL = https
N8N_LOG_LEVEL = info
N8N_LOG_OUTPUT = console
```

### 2. URLs y Webhooks
```
WEBHOOK_URL = https://efig.onrender.com
N8N_EDITOR_BASE_URL = https://efig.onrender.com
```

### 3. Autenticación
```
N8N_BASIC_AUTH_ACTIVE = true
N8N_BASIC_AUTH_USER = admin
N8N_BASIC_AUTH_PASSWORD = n8npass
```

### 4. Configuración de Seguridad
```
N8N_SECURE_COOKIE = true
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = true
```

### 5. Base de Datos PostgreSQL (GCP)
```
DB_TYPE = postgresdb
DB_POSTGRESDB_HOST = 34.66.86.207
DB_POSTGRESDB_PORT = 5433
DB_POSTGRESDB_DATABASE = n8n_db
DB_POSTGRESDB_USER = n8n_user
DB_POSTGRESDB_PASSWORD = n8npass
DB_POSTGRESDB_SSL_ENABLED = true
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED = false
```

### 6. Timezone
```
TZ = America/Bogota
GENERIC_TIMEZONE = America/Bogota
```

### 7. Configuración de Rendimiento
```
EXECUTIONS_PROCESS = main
EXECUTIONS_TIMEOUT = 3600
EXECUTIONS_TIMEOUT_MAX = 7200
NODE_OPTIONS = --max-old-space-size=1024
```

---

## 📋 PASOS PARA CONFIGURAR EN RENDER

1. **Ve a Environment Variables**: https://dashboard.render.com/web/srv-d49j6gv5r7bs73bbp8hg/env

2. **Para cada variable**:
   - Haz clic en "Add Environment Variable"
   - Key: `[nombre de la variable]`
   - Value: `[valor de la variable]`
   - Haz clic en "Save"

3. **Al terminar todas las variables**:
   - Haz clic en "Deploy latest commit"
   - Espera a que termine el deploy

---

## ✅ VERIFICACIÓN

**Total de variables:** 21 variables de entorno

**Variables críticas que DEBEN estar:**
- ✅ `DB_TYPE=postgresdb`
- ✅ `DB_POSTGRESDB_HOST=34.66.86.207`
- ✅ `DB_POSTGRESDB_PORT=5433`
- ✅ `N8N_BASIC_AUTH_ACTIVE=true`

---

## 🎯 RESULTADO ESPERADO

Una vez configuradas todas las variables, n8n debería:
1. ✅ Conectarse a la base de datos PostgreSQL en GCP
2. ✅ Iniciarse correctamente
3. ✅ Estar disponible en: https://efig.onrender.com
4. ✅ Login: admin / n8npass