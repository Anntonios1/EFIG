# 🚀 EFIG Travel Agency - n8n en Render

Migración exitosa de n8n desde ngrok a Render para hosting permanente y profesional.

## 📋 URLs de Producción

- **n8n Interface**: https://efig-n8n.onrender.com
- **Webhook Base**: https://efig-n8n.onrender.com/webhook/
- **Telegram Webhook**: https://efig-n8n.onrender.com/webhook/telegram

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Telegram Bot  │────│   n8n (Render)  │────│ PostgreSQL (GCP)│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                       ┌──────────────────┐
                       │  Copilot API     │
                       │ (34.66.86.207)   │
                       └──────────────────┘
```

## 🛠️ Desarrollo Local

### Prerrequisitos
- Docker y Docker Compose
- Git

### Configuración rápida
```bash
# 1. Clonar repositorio
git clone <tu-repo>
cd n8n-render

# 2. Copiar variables de entorno
cp .env.example .env

# 3. Iniciar servicios
docker-compose up -d

# 4. Acceder a n8n
open http://localhost:5678
```

### Credenciales por defecto
```
Usuario: admin
Contraseña: password123
```

## 🚀 Despliegue en Render

### 1. Conectar repositorio
- Ve a [render.com](https://render.com)
- New → Web Service
- Conecta tu repositorio GitHub

### 2. Configuración automática
El archivo `render.yaml` configura automáticamente:
- Web service con Docker
- Base de datos PostgreSQL
- Variables de entorno
- SSL automático

### 3. Variables críticas
```
WEBHOOK_URL=https://efig-n8n.onrender.com
N8N_BASIC_AUTH_PASSWORD=[auto-generado]
DATABASE_URL=[auto-conectado]
```

## 📊 Base de Datos

### PostgreSQL en Google Cloud Platform
```
Host: 34.66.86.207
Port: 5433
Database: n8n_db
User: n8n
```

### Estructura principal
- `clientes` - Información de clientes y estado de conversación
- `reservas` - Reservas de viajes con estados
- `pagos` - Transacciones y pagos
- `conversaciones` - Historial de chat
- `notificaciones` - Alertas programadas

## 🔧 Herramientas y Integraciones

### APIs conectadas
- **Telegram Bot API** - Chat y notificaciones
- **Copilot API** (34.66.86.207:8002) - IA conversacional  
- **EFIG API** (34.66.86.207:3001) - Lógica de negocio

### Workflows principales
1. **Atención al cliente por Telegram**
2. **Procesamiento de reservas** 
3. **Notificaciones automáticas**
4. **Reportes diarios**

## 🔐 Seguridad

- Autenticación básica habilitada
- SSL/TLS en todas las conexiones
- Variables de entorno para credenciales
- Headers de seguridad configurados

## 📈 Monitoring

### Render Dashboard
- CPU/Memory usage
- Response times
- Error rates
- Deployment logs

### Health Checks
- Endpoint: `/healthz`
- Intervalo: 30 segundos
- Timeout: 10 segundos

## 🛠️ Troubleshooting

### Logs en tiempo real
```bash
# Via Render CLI
render logs -s efig-n8n --tail

# Via dashboard
Render Dashboard → Service → Logs
```

### Problemas comunes

**Error de conexión a BD:**
```bash
# Verificar variables
render shell efig-n8n
env | grep DB_
```

**Webhook no funciona:**
- Verificar URL en Telegram: `/webhook/telegram`
- Revisar logs de Render
- Comprobar SSL certificate

**Memory issues:**
- Upgrade a plan Standard ($25/mes)
- Monitor usage en dashboard

## 📝 Mantenimiento

### Backups automáticos
- Workflows exportados semanalmente
- Base de datos respaldada en GCP
- Git repository con configuraciones

### Updates
```bash
# Rebuild automático en cada push a main
git push origin main
```

## 📞 Soporte

### URLs importantes
- **Render Status**: https://status.render.com
- **Documentation**: https://render.com/docs
- **n8n Docs**: https://docs.n8n.io

### Contactos
- **Desarrollo**: Jeyler Martinez
- **Infraestructura**: EFIG Team
- **Base de datos**: Google Cloud Platform

---

## 🎯 Próximos pasos

1. [ ] Custom domain: `n8n.efigtravel.com`
2. [ ] Monitoring avanzado con alertas
3. [ ] CI/CD pipeline para tests
4. [ ] Backup strategy mejorado
5. [ ] Load balancing para alta disponibilidad

¡n8n ahora está en producción de forma profesional! 🚀