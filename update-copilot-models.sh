# Patch para agregar modelos al Copilot API Server

# Reemplazar el método list_models con la lista completa de modelos
cat > /tmp/models_patch.py << 'EOF'
    def list_models(self) -> list:
        """Listar modelos disponibles - Lista completa actualizada"""
        return [
            {"id": "gpt-4o-2024-11-20", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 Omni"},
            {"id": "gpt-4", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 2025"},
            {"id": "gpt-5-mini", "object": "model", "owned_by": "github-copilot", "name": "GPT-5 Mini"},
            {"id": "gpt-4.1-2025-04-14", "object": "model", "owned_by": "github-copilot", "name": "GPT-4.1"},
            {"id": "gpt-4o", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 Omni Standard"},
            {"id": "gpt-4o-mini", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 Omni Mini"},
            {"id": "gpt-3.5-turbo", "object": "model", "owned_by": "github-copilot", "name": "GPT-3.5 Turbo"},
            {"id": "claude-3.5-sonnet", "object": "model", "owned_by": "github-copilot", "name": "Claude 3.5 Sonnet"},
            {"id": "o1-preview", "object": "model", "owned_by": "github-copilot", "name": "GPT-o1 Preview"},
            {"id": "o1-mini", "object": "model", "owned_by": "github-copilot", "name": "GPT-o1 Mini"}
        ]
EOF

# Buscar y reemplazar en el archivo server.py
python3 << 'PYTHON'
import re

# Leer archivo
with open('/home/teamp/n8n-backend/copilot-api-server/server.py', 'r', encoding='utf-8') as f:
    content = f.read()

# Buscar el método list_models actual
old_pattern = r'def list_models\(self\) -> list:.*?return \[.*?\]'

# Nuevo método con lista completa
new_method = '''def list_models(self) -> list:
        """Listar modelos disponibles - Lista completa actualizada"""
        return [
            {"id": "gpt-4o-2024-11-20", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 Omni"},
            {"id": "gpt-4", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 2025"},
            {"id": "gpt-5-mini", "object": "model", "owned_by": "github-copilot", "name": "GPT-5 Mini"},
            {"id": "gpt-4.1-2025-04-14", "object": "model", "owned_by": "github-copilot", "name": "GPT-4.1"},
            {"id": "gpt-4o", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 Omni Standard"},
            {"id": "gpt-4o-mini", "object": "model", "owned_by": "github-copilot", "name": "GPT-4 Omni Mini"},
            {"id": "gpt-3.5-turbo", "object": "model", "owned_by": "github-copilot", "name": "GPT-3.5 Turbo"},
            {"id": "claude-3.5-sonnet", "object": "model", "owned_by": "github-copilot", "name": "Claude 3.5 Sonnet"},
            {"id": "o1-preview", "object": "model", "owned_by": "github-copilot", "name": "GPT-o1 Preview"},
            {"id": "o1-mini", "object": "model", "owned_by": "github-copilot", "name": "GPT-o1 Mini"}
        ]'''

# Reemplazar
content_updated = re.sub(old_pattern, new_method, content, flags=re.DOTALL)

# Guardar archivo modificado
with open('/home/teamp/n8n-backend/copilot-api-server/server.py', 'w', encoding='utf-8') as f:
    f.write(content_updated)

print("✅ Modelos actualizados en server.py")
PYTHON

# Reiniciar contenedor
docker restart copilot_api_cloud

echo "🎉 Actualización completada!"
echo "Esperando que el contenedor se reinicie..."
sleep 3
docker logs --tail 20 copilot_api_cloud
