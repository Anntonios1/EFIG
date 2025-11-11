#!/usr/bin/env python3
"""
GitHub Copilot API Server
Compatible con OpenAI API - Para usar en n8n, Telegram bots, etc.
"""

import os
import sys
import json
import time
import uuid
import hashlib
import logging
import urllib.request
import urllib.error
from typing import Optional, Dict, Any, Iterator
from pathlib import Path
from flask import Flask, request, Response, jsonify, stream_with_context
from functools import lru_cache
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)


class TokenCache:
    """Cache de tokens de GitHub Copilot"""
    
    def __init__(self, cache_dir: Optional[str] = None):
        self.cache_dir = Path(cache_dir or os.path.expanduser("~/.copilot_cache"))
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.cache_file = self.cache_dir / "token_cache.json"
    
    def get_token(self, api_key_hash: str) -> Optional[Dict[str, Any]]:
        """Obtener token cacheado si es válido"""
        try:
            if not self.cache_file.exists():
                return None
            
            with open(self.cache_file, "r", encoding="utf-8") as f:
                cache_data = json.load(f)
            
            if cache_data.get("api_key_hash") != api_key_hash:
                return None
            
            token_data = cache_data.get("token_data", {})
            expires_at = token_data.get("expires_at", 0)
            
            # Token válido si expira en más de 2 minutos
            if time.time() < expires_at - 120:
                logger.debug("Usando token cacheado")
                return token_data
        
        except Exception as e:
            logger.warning(f"Error leyendo cache: {e}")
        
        return None
    
    def save_token(self, api_key_hash: str, token_data: Dict[str, Any]):
        """Guardar token en cache"""
        try:
            cache_data = {
                "api_key_hash": api_key_hash,
                "token_data": token_data,
                "cached_at": time.time()
            }
            
            temp_file = self.cache_file.with_suffix(".tmp")
            with open(temp_file, "w", encoding="utf-8") as f:
                json.dump(cache_data, f, indent=2)
            
            temp_file.replace(self.cache_file)
            logger.debug("Token guardado en cache")
        
        except Exception as e:
            logger.warning(f"Error guardando cache: {e}")


class GithubCopilotClient:
    """Cliente de GitHub Copilot API"""
    
    def __init__(self, api_key: str, timeout_token: int = 15, timeout_streaming: int = 60):
        self.github_token = api_key
        self.copilot_token = None
        self.token_expires_at = 0
        self.timeout_token = timeout_token
        self.timeout_streaming = timeout_streaming
        
        self.token_cache = TokenCache()
        self._api_key_hash = hashlib.sha256(api_key.encode()).hexdigest()
        
        # Headers que simulan VS Code (IMPORTANTE)
        self.base_headers = {
            "content-type": "application/json",
            "accept": "application/json",
            "copilot-integration-id": "vscode-chat",
            "editor-version": "vscode/1.95.3",
            "editor-plugin-version": "copilot-chat/0.27.1",
            "user-agent": "GitHubCopilotChat/0.27.1",
            "openai-intent": "conversation-panel",
            "x-github-api-version": "2025-04-01",
            "vscode-sessionid": str(uuid.uuid4()),
            "vscode-machineid": hashlib.sha256(api_key.encode()).hexdigest()[:32]
        }
        self.base_url = "https://api.githubcopilot.com/"
    
    def get_copilot_token(self) -> Optional[str]:
        """Obtener token de Copilot (con cache)"""
        current_time = time.time()
        
        # Verificar cache en memoria
        if self.copilot_token and current_time < self.token_expires_at - 120:
            return self.copilot_token
        
        # Verificar cache persistente
        cached_data = self.token_cache.get_token(self._api_key_hash)
        if cached_data:
            self.copilot_token = cached_data.get("token")
            self.token_expires_at = cached_data.get("expires_at", 0)
            return self.copilot_token
        
        # Obtener nuevo token
        try:
            headers = {"authorization": f"Bearer {self.github_token}"}
            headers.update(self.base_headers)
            
            req = urllib.request.Request(
                "https://api.github.com/copilot_internal/v2/token",
                headers=headers
            )
            
            with urllib.request.urlopen(req, timeout=self.timeout_token) as response:
                if response.getcode() == 200:
                    token_data = json.loads(response.read().decode("utf-8"))
                    self.copilot_token = token_data.get("token")
                    self.token_expires_at = token_data.get("expires_at", 0)
                    self.token_cache.save_token(self._api_key_hash, token_data)
                    logger.info("Token de Copilot obtenido exitosamente")
                    return self.copilot_token
        
        except Exception as e:
            logger.error(f"Error obteniendo token: {e}")
        
        return None
    
    def list_models(self) -> list:
        """Listar modelos disponibles"""
        return [
            {"id": "gpt-4o", "object": "model", "owned_by": "github-copilot"},
            {"id": "gpt-4", "object": "model", "owned_by": "github-copilot"},
            {"id": "gpt-4o-mini", "object": "model", "owned_by": "github-copilot"},
            {"id": "gpt-3.5-turbo", "object": "model", "owned_by": "github-copilot"}
        ]
    
    def chat_completions_create(self, **kwargs) -> Iterator[bytes]:
        """Crear chat completion (streaming)"""
        token = self.get_copilot_token()
        if not token:
            raise Exception("No se pudo obtener token de Copilot")
        
        headers = self.base_headers.copy()
        headers["Authorization"] = f"Bearer {token}"
        headers["x-request-id"] = str(uuid.uuid4())
        
        # Determinar tipo de request (user vs agent)
        messages = kwargs.get("messages", [])
        is_agent_call = any(msg.get("role") in ["assistant", "tool"] for msg in messages)
        headers["X-Initiator"] = "agent" if is_agent_call else "user"
        
        # Detectar si es request con imágenes
        is_vision = any(
            isinstance(msg.get("content"), list) and 
            any(part.get("type") == "image_url" for part in msg["content"])
            for msg in messages
        )
        if is_vision:
            headers["copilot-vision-request"] = "true"
        
        kwargs["stream"] = True
        kwargs["intent"] = True
        kwargs["n"] = 1
        
        url = f"{self.base_url}chat/completions"
        request_data = json.dumps(kwargs).encode("utf-8")
        
        logger.info(f"Solicitud a Copilot - Modelo: {kwargs.get('model', 'N/A')}, Mensajes: {len(messages)}, X-Initiator: {headers['X-Initiator']}")
        
        try:
            req = urllib.request.Request(url, data=request_data, headers=headers)
            response = urllib.request.urlopen(req, timeout=self.timeout_streaming)
            
            # Streaming de respuesta con buffer más grande
            buffer = ""
            while True:
                chunk = response.read(8192).decode("utf-8", errors="ignore")
                if not chunk:
                    break
                
                buffer += chunk
                while "\n" in buffer:
                    line, buffer = buffer.split("\n", 1)
                    line = line.strip()
                    
                    if line.startswith("data: "):
                        yield line.encode("utf-8") + b"\n\n"
                        
        except urllib.error.HTTPError as e:
            error_msg = f"Error HTTP {e.code}: {e.read().decode('utf-8', errors='ignore')}"
            logger.error(error_msg)
            raise Exception(error_msg)
        except Exception as e:
            logger.error(f"Error en streaming: {e}")
            raise


# Cliente global
copilot_client: Optional[GithubCopilotClient] = None


def initialize_client():
    """Inicializar cliente de Copilot"""
    global copilot_client
    
    api_key = os.getenv("GITHUB_COPILOT_TOKEN")
    if not api_key:
        logger.error("❌ GITHUB_COPILOT_TOKEN no configurado")
        return False
    
    if not api_key.startswith("ghu_"):
        logger.error("❌ Token inválido (debe empezar con ghu_)")
        return False
    
    try:
        copilot_client = GithubCopilotClient(api_key)
        logger.info("✅ Cliente de Copilot inicializado")
        return True
    except Exception as e:
        logger.error(f"❌ Error inicializando cliente: {e}")
        return False


# === RUTAS DE LA API ===

@app.route("/", methods=["GET"])
def index():
    """Página de inicio"""
    return jsonify({
        "service": "GitHub Copilot API Server",
        "version": "1.0.0",
        "status": "running",
        "compatible_with": "OpenAI API",
        "endpoints": {
            "models": "/v1/models",
            "chat": "/v1/chat/completions",
            "health": "/health"
        }
    })


@app.route("/health", methods=["GET"])
def health():
    """Health check"""
    if copilot_client is None:
        return jsonify({"status": "error", "message": "Cliente no inicializado"}), 503
    
    try:
        token = copilot_client.get_copilot_token()
        if token:
            return jsonify({"status": "healthy", "message": "API funcionando correctamente"})
        else:
            return jsonify({"status": "error", "message": "No se pudo obtener token"}), 503
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 503


@app.route("/v1/models", methods=["GET"])
def list_models():
    """Listar modelos disponibles (compatible con OpenAI API)"""
    if copilot_client is None:
        return jsonify({"error": "Cliente no inicializado"}), 503
    
    try:
        models = copilot_client.list_models()
        return jsonify({
            "object": "list",
            "data": models
        })
    except Exception as e:
        logger.error(f"Error listando modelos: {e}")
        return jsonify({"error": str(e)}), 500


@app.route("/v1/chat/completions", methods=["POST"])
def chat_completions():
    """Chat completions (compatible con OpenAI API)"""
    if copilot_client is None:
        return jsonify({"error": "Cliente no inicializado"}), 503
    
    try:
        # Log raw request
        logger.info("=== Nueva petición recibida ===")
        logger.info(f"Content-Type: {request.content_type}")
        logger.info(f"Is JSON: {request.is_json}")
        
        # Obtener datos del request
        if request.is_json:
            data = request.get_json()
        else:
            try:
                data = json.loads(request.data.decode('utf-8'))
            except Exception as e:
                logger.error(f"Error parsing JSON: {e}")
                return jsonify({"error": f"JSON inválido: {str(e)}"}), 400
        
        logger.info(f"Request recibido: {json.dumps(data, indent=2)}")
        
        # Validar request
        if "messages" not in data:
            return jsonify({"error": "Campo 'messages' requerido"}), 400
        
        # Parámetros por defecto
        kwargs = {
            "model": data.get("model", "gpt-4o"),
            "messages": data["messages"],
            "temperature": data.get("temperature", 0.7),
            "max_tokens": data.get("max_tokens", 4000),
            "top_p": data.get("top_p", 1.0),
            "stream": data.get("stream", False)
        }
        
        logger.info(f"Chat request - Modelo: {kwargs['model']}, Mensajes: {len(kwargs['messages'])}")
        
        # Si es streaming, usar generador
        if kwargs["stream"]:
            def generate():
                try:
                    for chunk in copilot_client.chat_completions_create(**kwargs):
                        yield chunk
                except Exception as e:
                    logger.error(f"Error en streaming: {e}")
                    error_data = json.dumps({"error": str(e)})
                    yield f"data: {error_data}\n\n".encode("utf-8")
            
            return Response(
                stream_with_context(generate()),
                mimetype="text/event-stream",
                headers={
                    "Cache-Control": "no-cache",
                    "X-Accel-Buffering": "no"
                }
            )
        else:
            # Non-streaming (acumular respuesta)
            full_response = ""
            for chunk in copilot_client.chat_completions_create(**kwargs):
                chunk_str = chunk.decode("utf-8").strip()
                if chunk_str.startswith("data: "):
                    data_part = chunk_str[6:]
                    if data_part != "[DONE]":
                        try:
                            chunk_data = json.loads(data_part)
                            if "choices" in chunk_data:
                                for choice in chunk_data["choices"]:
                                    if "delta" in choice and "content" in choice["delta"]:
                                        content = choice["delta"]["content"]
                                        if content:  # Solo agregar si no es None
                                            full_response += content
                        except json.JSONDecodeError:
                            pass
            
            # Formato de respuesta compatible con OpenAI
            return jsonify({
                "id": f"chatcmpl-{uuid.uuid4().hex[:8]}",
                "object": "chat.completion",
                "created": int(time.time()),
                "model": kwargs["model"],
                "choices": [{
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": full_response
                    },
                    "finish_reason": "stop"
                }],
                "usage": {
                    "prompt_tokens": 0,
                    "completion_tokens": 0,
                    "total_tokens": 0
                }
            })
    
    except Exception as e:
        import traceback
        logger.error(f"Error en chat completions: {e}")
        logger.error(f"Traceback: {traceback.format_exc()}")
        return jsonify({"error": str(e)}), 500


@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint no encontrado"}), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Error interno del servidor"}), 500


if __name__ == "__main__":
    print("=" * 60)
    print("🚀 GitHub Copilot API Server")
    print("=" * 60)
    print()
    
    # Inicializar cliente
    if not initialize_client():
        print("❌ No se pudo inicializar el servidor")
        print("Configura GITHUB_COPILOT_TOKEN en .env o como variable de entorno")
        sys.exit(1)
    
    # Configuración del servidor
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    print(f"✅ Servidor iniciado")
    print(f"📡 URL: http://{host}:{port}")
    print(f"📖 Docs: http://{host}:{port}/")
    print(f"💊 Health: http://{host}:{port}/health")
    print()
    print("Endpoints compatibles con OpenAI API:")
    print(f"  • GET  /v1/models")
    print(f"  • POST /v1/chat/completions")
    print()
    print("Presiona Ctrl+C para detener el servidor")
    print("=" * 60)
    print()
    
    # Iniciar servidor
    app.run(host=host, port=port, debug=debug, threaded=True)
