# Deploy a Google Cloud

## Opción 1: VM con Docker (Más Simple)

### 1. Crear VM en Google Cloud
```bash
# En Google Cloud Console:
# 1. Ve a Compute Engine > VM Instances
# 2. Create Instance:
#    - Name: n8n-backend
#    - Region: us-central1 (o la más cercana)
#    - Machine type: e2-small (2 vCPU, 2 GB RAM) - suficiente para empezar
#    - Boot disk: Ubuntu 22.04 LTS, 20 GB
#    - Firewall: Allow HTTP, HTTPS traffic
#    - Advanced > Networking > Network tags: add "n8n-backend"
```

### 2. Configurar Firewall Rules
```bash
# En Google Cloud Console > VPC Network > Firewall Rules
# Create Firewall Rule:
# - Name: allow-postgres-copilot
# - Targets: Specified target tags
# - Target tags: n8n-backend
# - Source IP ranges: 0.0.0.0/0 (para pruebas, luego restringir)
# - Protocols and ports: 
#   - tcp:5432 (PostgreSQL)
#   - tcp:8000 (Copilot API)
```

### 3. Conectar a la VM via SSH
```bash
# Desde Google Cloud Console > Compute Engine > SSH button
# O desde tu terminal:
gcloud compute ssh n8n-backend --zone=us-central1-a
```

### 4. Instalar Docker en la VM
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalación
docker --version
docker-compose --version

# Salir y reconectar para aplicar cambios de grupo
exit
```

### 5. Subir archivos a la VM
```powershell
# Desde tu PC local (PowerShell):
# Primero comprimir los archivos necesarios
Compress-Archive -Path "copilot-api-server", "init.sql", "docker-compose.cloud.yml" -DestinationPath "deploy.zip"

# Subir a la VM usando gcloud
gcloud compute scp deploy.zip n8n-backend:~/ --zone=us-central1-a

# O usar WinSCP / FileZilla con la IP externa de la VM
```

### 6. Deploy en la VM
```bash
# En la VM (via SSH):
# Descomprimir archivos
unzip deploy.zip

# Renombrar docker-compose
mv docker-compose.cloud.yml docker-compose.yml

# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Verificar que estén corriendo
docker ps
```

### 7. Obtener IP Externa
```bash
# En la VM:
curl ifconfig.me

# O en Google Cloud Console > Compute Engine > External IP
```

### 8. Conectar desde n8n Cloud

**PostgreSQL:**
- Host: `<IP_EXTERNA_VM>`
- Port: `5432`
- Database: `n8n_db`
- User: `n8n`
- Password: `n8npass`
- SSL: Disable (para pruebas, habilitar en producción)

**Ollama API (Copilot):**
- Base URL: `http://<IP_EXTERNA_VM>:8000`
- En n8n Cloud > Credentials > Ollama account:
  - Base URL: `http://<IP_EXTERNA_VM>:8000`

---

## Opción 2: Cloud SQL + Cloud Run (Serverless)

### PostgreSQL en Cloud SQL
```bash
# 1. Crear instancia Cloud SQL:
gcloud sql instances create n8n-postgres \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1

# 2. Crear base de datos
gcloud sql databases create n8n_db --instance=n8n-postgres

# 3. Crear usuario
gcloud sql users create n8n \
  --instance=n8n-postgres \
  --password=n8npass

# 4. Habilitar conexiones públicas (para n8n Cloud)
gcloud sql instances patch n8n-postgres \
  --authorized-networks=0.0.0.0/0

# 5. Obtener IP pública
gcloud sql instances describe n8n-postgres | grep ipAddress
```

### Copilot API en Cloud Run
```bash
# 1. Construir y subir imagen
cd copilot-api-server
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/copilot-api

# 2. Deploy a Cloud Run
gcloud run deploy copilot-api \
  --image gcr.io/YOUR_PROJECT_ID/copilot-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GITHUB_TOKEN=ghu_huZKj1sFEYQic1AUZM6ua3CY01QsBF2S4zw6

# 3. Obtener URL
gcloud run services describe copilot-api --region us-central1 --format='value(status.url)'
```

---

## Opción 3: Railway / Render (Más fácil que GCP)

### Railway (Recomendado para desarrollo)
1. Ve a https://railway.app
2. Conecta tu GitHub
3. New Project > Deploy from GitHub
4. Sube el código
5. Railway auto-detecta Docker y despliega
6. Te da URLs públicas automáticamente

### Render
1. Ve a https://render.com
2. New > PostgreSQL (DB gratis)
3. New > Web Service > Docker (Copilot API)
4. Conectar con n8n Cloud

---

## Test de Conexión

### PostgreSQL
```bash
# Desde tu PC local
psql -h <IP_O_HOST> -U n8n -d n8n_db -p 5432
# Password: n8npass

# Test query
SELECT * FROM clientes;
```

### Copilot API
```bash
# Desde tu PC local
curl http://<IP_O_HOST>:8000/api/tags

# Debería retornar: {"models": [{"name": "gpt-4"}, ...]}
```

---

## Seguridad (Después de probar)

1. **PostgreSQL:**
   - Cambiar password
   - Restringir firewall a IPs de n8n Cloud
   - Habilitar SSL

2. **Copilot API:**
   - Agregar autenticación
   - Usar HTTPS con certificado
   - Restringir CORS

3. **Secrets:**
   - Usar Google Secret Manager
   - No dejar tokens en código
