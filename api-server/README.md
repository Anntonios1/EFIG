# API Server para n8n - EFIG Vuelos & Travel

API REST intermediaria para gestionar la base de datos PostgreSQL desde n8n.

## 🚀 Instalación y Ejecución

### Opción 1: Ejecutar Localmente (Windows)

```powershell
# Instalar dependencias
cd "C:\Users\teamp\Documents\N8N FINAL\api-server"
npm install

# Iniciar el servidor
npm start
```

El servidor estará disponible en: `http://localhost:3000`

### Opción 2: Ejecutar en el Servidor GCP

```bash
# Conectar al servidor
gcloud compute ssh openwebui-server --zone=us-central1-a --project=open-webui-472400

# Crear directorio
mkdir -p /home/teamp/api-server
cd /home/teamp/api-server

# Copiar los archivos (desde tu máquina local)
gcloud compute scp server.js openwebui-server:/home/teamp/api-server/ --zone=us-central1-a --project=open-webui-472400
gcloud compute scp package.json openwebui-server:/home/teamp/api-server/ --zone=us-central1-a --project=open-webui-472400

# En el servidor, instalar Node.js si no está instalado
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar dependencias
npm install

# Instalar PM2 para ejecutar como servicio
sudo npm install -g pm2

# Iniciar el servidor
pm2 start server.js --name efig-api

# Hacer que inicie automáticamente al reiniciar
pm2 startup
pm2 save
```

### Opción 3: Ejecutar como Contenedor Docker en GCP

```bash
# Crear Dockerfile
cat > Dockerfile << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
EOF

# Construir imagen
docker build -t efig-api-server .

# Ejecutar contenedor
docker run -d \
  --name efig_api \
  --restart unless-stopped \
  -p 3000:3000 \
  efig-api-server

# Ver logs
docker logs -f efig_api
```

## 📋 Endpoints Disponibles

### Clientes

- **GET** `/clientes` - Obtener todos los clientes
- **GET** `/clientes/:id_cliente` - Obtener un cliente específico
- **POST** `/clientes` - Crear un cliente
  ```json
  {
    "nombre_completo": "Juan Pérez",
    "email": "juan@mail.com",
    "telefono": "310-5555555",
    "documento": "12345678",
    "tipo_cliente": "nuevo"
  }
  ```
- **PUT** `/clientes/:id_cliente` - Actualizar un cliente

### Reservas

- **GET** `/reservas` - Obtener todas las reservas
- **GET** `/reservas/cliente/:id_cliente` - Obtener reservas de un cliente
- **POST** `/reservas` - Crear una reserva
  ```json
  {
    "id_cliente": "C-0001",
    "tipo": "vuelo",
    "destino": "Cartagena",
    "fecha_salida": "2025-12-15",
    "fecha_regreso": "2025-12-20",
    "precio": 450000,
    "notas": "Ventana preferida"
  }
  ```
- **PATCH** `/reservas/:id_reserva/estado` - Actualizar estado
  ```json
  {
    "estado": "confirmada"
  }
  ```

### Pagos

- **GET** `/pagos` - Obtener todos los pagos
- **GET** `/pagos/reserva/:id_reserva` - Obtener pagos de una reserva
- **POST** `/pagos` - Crear un pago
  ```json
  {
    "id_reserva": "R-0001",
    "monto": 450000,
    "metodo": "tarjeta",
    "estado": "completado"
  }
  ```
- **PATCH** `/pagos/:id_pago/estado` - Actualizar estado

### Health Check

- **GET** `/health` - Verificar estado del servidor

## 🔧 Configuración en n8n

Usa el nodo **HTTP Request** con estos parámetros:

### Ejemplo: Crear Cliente

- **Method:** POST
- **URL:** `http://localhost:3000/clientes` (o la IP del servidor)
- **Body:** JSON
- **JSON:**
  ```json
  {
    "nombre_completo": "{{ $json.nombre_completo }}",
    "email": "{{ $json.email }}",
    "telefono": "{{ $json.telefono }}",
    "tipo_cliente": "{{ $json.tipo_cliente }}"
  }
  ```

### Ejemplo: Obtener Clientes

- **Method:** GET
- **URL:** `http://localhost:3000/clientes`

## 🌐 Abrir Puerto en GCP (si ejecutas en el servidor)

```bash
gcloud compute firewall-rules create allow-api-3000 \
  --project=open-webui-472400 \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:3000 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=openwebui-server
```

Luego la API estará disponible en: `http://34.66.86.207:3000`

## ✅ Probar la API

```powershell
# Health check
Invoke-RestMethod -Uri "http://localhost:3000/health"

# Crear cliente
$body = @{
    nombre_completo = "Pedro Morales"
    email = "pedro@mail.com"
    telefono = "320-9876543"
    tipo_cliente = "VIP"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/clientes" -Method POST -Body $body -ContentType "application/json"

# Obtener clientes
Invoke-RestMethod -Uri "http://localhost:3000/clientes"
```

## 🔒 Seguridad (Opcional)

Para producción, considera agregar:
- API Key authentication
- Rate limiting
- HTTPS con certificado SSL
- Validación de datos más estricta
- Logs estructurados

## 📝 Notas

- Los IDs (id_cliente, id_reserva, id_pago) se generan automáticamente por los triggers de PostgreSQL
- Todas las respuestas incluyen `{ success: true/false, data/error }`
- El servidor usa CORS para permitir llamadas desde n8n Cloud
