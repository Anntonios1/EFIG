#!/usr/bin/env python3
"""
GitHub Copilot API Server - Versión Simple
"""

import os
import json
import time
import uuid
import hashlib
import urllib.request
import urllib.error
from flask import Flask, request, Response, jsonify
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

class CopilotClient:
    def __init__(self, api_key):
        self.api_key = api_key
        self.token = None
        self.token_expires = 0
        
    def get_token(self):
        """Obtener token de Copilot"""
        if self.token and time.time() < self.token_expires - 120:
            return self.token
            
        url = "https://api.github.com/copilot_internal/v2/token"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Accept": "application/json",
            "User-Agent": "GitHubCopilotChat/0.27.1"
        }
        
        req = urllib.request.Request(url, headers=headers)
        response = urllib.request.urlopen(req, timeout=15)
        data = json.loads(response.read().decode())
        
        self.token = data["token"]
        self.token_expires = data["expires_at"]
        print(f"✅ Token obtenido, expira en {self.token_expires - time.time():.0f}s")
        return self.token
    
    def chat(self, messages):
        """Chat con Copilot"""
        token = self.get_token()
        
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "copilot-integration-id": "vscode-chat",
            "editor-version": "vscode/1.95.3",
            "editor-plugin-version": "copilot-chat/0.27.1",
            "user-agent": "GitHubCopilotChat/0.27.1",
            "openai-intent": "conversation-panel",
            "vscode-sessionid": str(uuid.uuid4()),
            "vscode-machineid": hashlib.sha256(os.urandom(32)).hexdigest()[:32],
            "x-request-id": str(uuid.uuid4())
        }
        
        # Determinar X-Initiator
        is_agent = any(msg.get("role") in ["assistant", "tool"] for msg in messages)
        headers["X-Initiator"] = "agent" if is_agent else "user"
        
        payload = {
            "messages": messages,
            "model": "gpt-4",
            "temperature": 0.7,
            "max_tokens": 4000,
            "stream": True,
            "intent": True,
            "n": 1
        }
        
        url = "https://api.githubcopilot.com/chat/completions"
        data = json.dumps(payload).encode()
        
        print(f"📤 Enviando a Copilot: {len(messages)} mensajes, X-Initiator={headers['X-Initiator']}")
        
        req = urllib.request.Request(url, data=data, headers=headers)
        response = urllib.request.urlopen(req, timeout=45)
        
        # Leer streaming
        buffer = ""
        while True:
            chunk = response.read(8192)
            if not chunk:
                break
                
            buffer += chunk.decode("utf-8", errors="ignore")
            
            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                line = line.strip()
                
                if line.startswith("data: "):
                    yield line + "\n\n"

# Cliente global
client = None

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/v1/models")
def models():
    return jsonify({
        "object": "list",
        "data": [
            {"id": "gpt-4", "object": "model", "owned_by": "github-copilot"}
        ]
    })

@app.route("/api/tags")
def ollama_tags():
    """Ollama: Listar modelos"""
    return jsonify({
        "models": [
            {
                "name": "gpt-4",
                "modified_at": "2025-11-04T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt4",
                "details": {
                    "format": "gguf",
                    "family": "gpt-4",
                    "parameter_size": "unknown",
                    "quantization_level": "unknown"
                }
            }
        ]
    })

@app.route("/api/generate", methods=["POST"])
def ollama_generate():
    """Ollama: Generar texto simple"""
    try:
        data = request.get_json()
        prompt = data.get("prompt", "")
        stream = data.get("stream", False)
        
        # Convertir prompt a formato de mensajes
        messages = [{"role": "user", "content": prompt}]
        
        if stream:
            def generate_ollama():
                for line in client.chat(messages):
                    if line.startswith("data: "):
                        chunk_data = line[6:].strip()
                        if chunk_data and chunk_data != "[DONE]":
                            try:
                                obj = json.loads(chunk_data)
                                if "choices" in obj and len(obj["choices"]) > 0:
                                    delta = obj["choices"][0].get("delta", {})
                                    content = delta.get("content", "")
                                    if content:
                                        # Formato Ollama streaming
                                        ollama_chunk = {
                                            "model": "gpt-4",
                                            "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                                            "response": content,
                                            "done": False
                                        }
                                        yield json.dumps(ollama_chunk) + "\n"
                            except:
                                pass
                
                # Chunk final
                final_chunk = {
                    "model": "gpt-4",
                    "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "response": "",
                    "done": True
                }
                yield json.dumps(final_chunk) + "\n"
            
            return Response(generate_ollama(), mimetype="application/x-ndjson")
        else:
            # Non-streaming
            full_text = ""
            for line in client.chat(messages):
                if line.startswith("data: "):
                    chunk_data = line[6:].strip()
                    if chunk_data and chunk_data != "[DONE]":
                        try:
                            obj = json.loads(chunk_data)
                            if "choices" in obj and len(obj["choices"]) > 0:
                                delta = obj["choices"][0].get("delta", {})
                                content = delta.get("content", "")
                                if content:
                                    full_text += content
                        except:
                            pass
            
            return jsonify({
                "model": "gpt-4",
                "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "response": full_text,
                "done": True
            })
    
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route("/api/chat", methods=["POST"])
def ollama_chat():
    """Ollama: Chat con mensajes"""
    try:
        data = request.get_json()
        messages = data.get("messages", [])
        stream = data.get("stream", False)
        
        if stream:
            def generate_ollama():
                for line in client.chat(messages):
                    if line.startswith("data: "):
                        chunk_data = line[6:].strip()
                        if chunk_data and chunk_data != "[DONE]":
                            try:
                                obj = json.loads(chunk_data)
                                if "choices" in obj and len(obj["choices"]) > 0:
                                    delta = obj["choices"][0].get("delta", {})
                                    content = delta.get("content", "")
                                    role = delta.get("role", "assistant")
                                    if content or role:
                                        # Formato Ollama streaming
                                        ollama_chunk = {
                                            "model": "gpt-4",
                                            "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                                            "message": {
                                                "role": "assistant",
                                                "content": content
                                            },
                                            "done": False
                                        }
                                        yield json.dumps(ollama_chunk) + "\n"
                            except:
                                pass
                
                # Chunk final
                final_chunk = {
                    "model": "gpt-4",
                    "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "message": {
                        "role": "assistant",
                        "content": ""
                    },
                    "done": True
                }
                yield json.dumps(final_chunk) + "\n"
            
            return Response(generate_ollama(), mimetype="application/x-ndjson")
        else:
            # Non-streaming
            full_text = ""
            for line in client.chat(messages):
                if line.startswith("data: "):
                    chunk_data = line[6:].strip()
                    if chunk_data and chunk_data != "[DONE]":
                        try:
                            obj = json.loads(chunk_data)
                            if "choices" in obj and len(obj["choices"]) > 0:
                                delta = obj["choices"][0].get("delta", {})
                                content = delta.get("content", "")
                                if content:
                                    full_text += content
                        except:
                            pass
            
            return jsonify({
                "model": "gpt-4",
                "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "message": {
                    "role": "assistant",
                    "content": full_text
                },
                "done": True
            })
    
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route("/v1/chat/completions", methods=["POST"])
def chat():
    try:
        data = request.get_json()
        print(f"📨 Request: {json.dumps(data, ensure_ascii=False)}")
        
        messages = data.get("messages", [])
        stream = data.get("stream", False)
        
        if stream:
            return Response(
                client.chat(messages),
                mimetype="text/event-stream"
            )
        else:
            # Acumular respuesta
            full_text = ""
            for line in client.chat(messages):
                if line.startswith("data: "):
                    chunk_data = line[6:].strip()
                    if chunk_data and chunk_data != "[DONE]":
                        try:
                            obj = json.loads(chunk_data)
                            if "choices" in obj and len(obj["choices"]) > 0:
                                delta = obj["choices"][0].get("delta", {})
                                content = delta.get("content", "")
                                if content:
                                    full_text += content
                        except:
                            pass
            
            return jsonify({
                "id": f"chatcmpl-{uuid.uuid4().hex[:8]}",
                "object": "chat.completion",
                "created": int(time.time()),
                "model": "gpt-4",
                "choices": [{
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": full_text
                    },
                    "finish_reason": "stop"
                }]
            })
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    token = os.getenv("GITHUB_COPILOT_TOKEN")
    if not token:
        print("❌ GITHUB_COPILOT_TOKEN no configurado")
        exit(1)
    
    client = CopilotClient(token)
    
    print("\n" + "="*60)
    print("🚀 GitHub Copilot API Server")
    print("="*60)
    print("📡 Base: http://localhost:8000")
    print()
    print("OpenAI API Compatible:")
    print("  � POST /v1/chat/completions")
    print("  📚 GET  /v1/models")
    print()
    print("Ollama API Compatible:")
    print("  💬 POST /api/chat")
    print("  📝 POST /api/generate")
    print("  📚 GET  /api/tags")
    print()
    print("Health:")
    print("  💊 GET  /health")
    print("="*60 + "\n")
    
    app.run(host="0.0.0.0", port=8000)
