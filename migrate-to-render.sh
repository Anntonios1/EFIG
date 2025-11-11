#!/bin/bash

# =====================================================
# Script de migración automática n8n: ngrok → Render
# EFIG Travel Agency
# =====================================================

echo "🚀 INICIANDO MIGRACIÓN N8N: ngrok → Render"
echo "==========================================="

# Variables
BACKUP_DIR="./backup-$(date +%Y%m%d)"
RENDER_SERVICE_NAME="efig-n8n"
REPO_NAME="n8n-efig-render"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funciones auxiliares
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# PASO 1: Crear directorio de backup
echo -e "\n📂 PASO 1: Preparando backup..."
mkdir -p $BACKUP_DIR
success "Directorio $BACKUP_DIR creado"

# PASO 2: Backup de workflows desde n8n
echo -e "\n💾 PASO 2: Respaldando workflows..."
read -p "Ingresa la URL de tu n8n actual (ej: https://abc123.ngrok.io): " N8N_URL
read -p "Usuario de n8n: " N8N_USER
read -s -p "Password de n8n: " N8N_PASS
echo

# Exportar workflows
curl -u "$N8N_USER:$N8N_PASS" \
     "$N8N_URL/rest/workflows" \
     -H "Accept: application/json" \
     -o "$BACKUP_DIR/workflows-backup.json" \
     2>/dev/null

if [ $? -eq 0 ]; then
    success "Workflows exportados a $BACKUP_DIR/workflows-backup.json"
else
    error "Error exportando workflows. Verifica URL y credenciales."
    exit 1
fi

# PASO 3: Crear estructura del repositorio
echo -e "\n📁 PASO 3: Creando estructura del proyecto..."
mkdir -p data

# Verificar que los archivos de configuración existen
required_files=("Dockerfile" "render.yaml" ".env.example" "README-RENDER.md")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        success "$file ✓"
    else
        error "$file no encontrado"
        exit 1
    fi
done

# PASO 4: Inicializar repositorio Git (si no existe)
if [ ! -d ".git" ]; then
    echo -e "\n🔧 PASO 4: Inicializando repositorio Git..."
    git init
    git add .
    git commit -m "Initial commit: n8n migration to Render"
    success "Repositorio Git inicializado"
else
    warning "Repositorio Git ya existe"
fi

# PASO 5: Configurar repositorio remoto
echo -e "\n🌐 PASO 5: Configurando repositorio remoto..."
read -p "¿Ya creaste el repositorio en GitHub? (y/n): " github_ready

if [ "$github_ready" = "y" ]; then
    read -p "URL del repositorio GitHub (ej: https://github.com/user/n8n-efig-render.git): " GITHUB_URL
    
    # Verificar si ya existe remote origin
    if git remote get-url origin >/dev/null 2>&1; then
        warning "Remote 'origin' ya existe. Actualizando..."
        git remote set-url origin $GITHUB_URL
    else
        git remote add origin $GITHUB_URL
    fi
    
    git branch -M main
    git push -u origin main
    success "Código subido a GitHub"
else
    warning "Crea el repositorio en GitHub y ejecuta:"
    echo "  git remote add origin <URL_DEL_REPO>"
    echo "  git push -u origin main"
fi

# PASO 6: Guía para Render
echo -e "\n🚀 PASO 6: Configuración en Render"
echo "================================="
echo
echo "Sigue estos pasos en render.com:"
echo
echo "1. 📊 CREAR BASE DE DATOS:"
echo "   • New → PostgreSQL"
echo "   • Name: efig-postgres"
echo "   • Database: n8n_db"
echo "   • Plan: Free (o Starter si necesitas más recursos)"
echo
echo "2. 🌐 CREAR WEB SERVICE:"
echo "   • New → Web Service"
echo "   • Connect Repository: $GITHUB_URL"
echo "   • Name: $RENDER_SERVICE_NAME"
echo "   • Environment: Docker"
echo "   • Plan: Starter (\$7/mes)"
echo
echo "3. ⚙️  CONFIGURACIÓN AUTOMÁTICA:"
echo "   • render.yaml se aplicará automáticamente"
echo "   • Variables de entorno se configurarán solas"
echo "   • SSL se habilitará automáticamente"
echo

# PASO 7: Información de migración de datos
echo -e "\n📋 PASO 7: Migrar datos existentes"
echo "=================================="
echo
echo "Cuando tu servicio esté desplegado:"
echo
echo "1. 🔗 NUEVA URL:"
echo "   https://$RENDER_SERVICE_NAME.onrender.com"
echo
echo "2. 📥 IMPORTAR WORKFLOWS:"
echo "   • Accede a la nueva URL"
echo "   • Settings → Import/Export"
echo "   • Import desde: $BACKUP_DIR/workflows-backup.json"
echo
echo "3. 🔄 ACTUALIZAR WEBHOOKS:"
echo "   • Telegram: setWebhook a nueva URL"
echo "   • APIs: actualizar configuraciones"
echo

# PASO 8: Scripts útiles
echo -e "\n🛠️  PASO 8: Creando scripts útiles..."

# Script para actualizar webhook de Telegram
cat > update-telegram-webhook.sh << EOF
#!/bin/bash
# Script para actualizar webhook de Telegram

read -p "Bot Token de Telegram: " BOT_TOKEN
NEW_URL="https://$RENDER_SERVICE_NAME.onrender.com/webhook/telegram"

curl -X POST "https://api.telegram.org/bot\$BOT_TOKEN/setWebhook" \\
     -H "Content-Type: application/json" \\
     -d "{\"url\":\"\$NEW_URL\"}"

echo
echo "✅ Webhook actualizado a: \$NEW_URL"
EOF

chmod +x update-telegram-webhook.sh
success "Script update-telegram-webhook.sh creado"

# Script para monitorear logs
cat > monitor-logs.sh << EOF
#!/bin/bash
# Script para monitorear logs de Render

echo "📊 Monitoreando logs de $RENDER_SERVICE_NAME..."
echo "Presiona Ctrl+C para salir"
echo

# Requiere Render CLI instalado
if command -v render >/dev/null 2>&1; then
    render logs -s $RENDER_SERVICE_NAME --tail
else
    echo "❌ Render CLI no instalado"
    echo "Instala con: npm install -g @render/cli"
    echo "O visita: https://dashboard.render.com/web/$RENDER_SERVICE_NAME"
fi
EOF

chmod +x monitor-logs.sh
success "Script monitor-logs.sh creado"

# PASO 9: Información final
echo -e "\n🎉 MIGRACIÓN PREPARADA EXITOSAMENTE!"
echo "===================================="
echo
echo "📋 CHECKLIST DE MIGRACIÓN:"
echo "[ ] 1. Subir código a GitHub ✓"
echo "[ ] 2. Crear base de datos en Render"
echo "[ ] 3. Crear web service en Render"  
echo "[ ] 4. Verificar despliegue exitoso"
echo "[ ] 5. Importar workflows"
echo "[ ] 6. Actualizar webhooks (usar: ./update-telegram-webhook.sh)"
echo "[ ] 7. Probar todas las integraciones"
echo "[ ] 8. Cerrar ngrok tunnel"
echo
echo "📁 ARCHIVOS IMPORTANTES:"
echo "• Backup: $BACKUP_DIR/"
echo "• Dockerfile: Configuración del contenedor"
echo "• render.yaml: Configuración de Render"
echo "• README-RENDER.md: Documentación completa"
echo
echo "🔗 PRÓXIMOS PASOS:"
echo "1. Ve a https://render.com y crea tu servicio"
echo "2. Espera el despliegue (5-10 minutos)"
echo "3. Importa tus workflows"
echo "4. Actualiza webhooks con: ./update-telegram-webhook.sh"
echo
echo "🚀 ¡Tu n8n estará listo en producción!"

# Resumen final
echo -e "\n📊 RESUMEN:"
echo "URL antigua (ngrok): $N8N_URL"
echo "URL nueva (Render): https://$RENDER_SERVICE_NAME.onrender.com"
echo "Backup guardado en: $BACKUP_DIR/"

success "Migración preparada exitosamente. ¡Ahora ve a Render!"