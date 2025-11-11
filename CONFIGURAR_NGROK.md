# Configuración de ngrok - Guía paso a paso

## El contenedor ngrok está corriendo pero necesita configuración

### ¿Por qué?
ngrok gratuito requiere un authtoken para funcionar correctamente.

---

## OPCIÓN 1: Configurar ngrok con authtoken (Recomendado - Gratis)

### Paso 1: Crear cuenta en ngrok (gratis)
1. Ve a https://dashboard.ngrok.com/signup
2. Crea una cuenta (puedes usar Google/GitHub)
3. Una vez dentro, ve a: https://dashboard.ngrok.com/get-started/your-authtoken
4. Copia tu authtoken (algo como: `2abc...xyz123`)

### Paso 2: Añadir el token al docker-compose.yml

Edita el archivo `docker-compose.yml` y descomenta estas líneas:

```yaml
  ngrok:
    image: ngrok/ngrok:latest
    container_name: n8n_ngrok
    command: http host.docker.internal:5678
    ports:
      - "4040:4040"
    restart: unless-stopped
    environment:           # ← Descomenta desde aquí
      NGROK_AUTHTOKEN: 2abc...xyz123  # ← Pega tu token aquí
```

### Paso 3: Reiniciar ngrok

```powershell
docker-compose restart ngrok
```

### Paso 4: Obtener la URL pública

Espera 5 segundos y ejecuta:

```powershell
.\scripts\start_ngrok.ps1
```

O manualmente:

```powershell
Start-Sleep -Seconds 5
$response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels"
$url = $response.tunnels[0].public_url
Write-Host "URL publica: $url"
```

---

## OPCIÓN 2: Usar ngrok desde línea de comandos (alternativa)

Si prefieres no usar Docker:

```powershell
# Descargar ngrok (si no lo tienes)
Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile "ngrok.zip"
Expand-Archive -Path "ngrok.zip" -DestinationPath "."

# Configurar authtoken (solo la primera vez)
.\ngrok.exe config add-authtoken TU_TOKEN_AQUI

# Ejecutar ngrok
.\ngrok.exe http 5678
```

La URL pública aparecerá en la terminal.

---

## OPCIÓN 3: Acceso solo local (sin ngrok)

Si solo necesitas acceder desde tu red local (WiFi):

**Ya está funcionando:**
- Desde tu PC: http://localhost:5678
- Desde tu móvil (misma WiFi): http://192.168.100.1:5678

**Webhooks locales:**
- http://192.168.100.1:5678/webhook/agente
- http://192.168.100.1:5678/webhook/nuevo-cliente

---

## Dashboard de ngrok

Siempre puedes ver el estado y la URL en:
http://localhost:4040

Este dashboard muestra:
- URL pública actual
- Requests en tiempo real
- Estadísticas de uso

---

## Verificar que ngrok está corriendo

```powershell
docker ps --filter name=n8n_ngrok
```

Debería mostrar:
```
CONTAINER ID   IMAGE               STATUS
xxxxx          ngrok/ngrok:latest  Up X minutes
```

---

## ¿Qué prefieres hacer?

1. **Configurar ngrok con authtoken** (gratis, recomendado) → Sigue Opción 1
2. **Usar solo acceso local** (sin internet) → Usa Opción 3
3. **Necesitas ayuda** → Dime y te guío paso a paso

---

## Troubleshooting

### "ERR_NGROK_108: You must sign up for an ngrok account"
- **Causa**: ngrok requiere authtoken
- **Solución**: Sigue Opción 1 arriba

### Dashboard muestra "No tunnels online"
- **Causa**: Falta authtoken o n8n no está en localhost:5678
- **Solución**: 
  1. Verifica que n8n está corriendo: `docker ps | findstr n8n` o abre http://localhost:5678
  2. Añade authtoken (Opción 1)

### "Connection refused" en localhost:4040
- **Causa**: Contenedor ngrok no está corriendo
- **Solución**: `docker-compose up -d ngrok`
