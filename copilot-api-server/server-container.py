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
    
    def chat(self, messages, tools=None, model="gpt-4", temperature=0.7, max_tokens=4000):
        """Chat con Copilot con soporte para tools"""
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
            "model": model,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": True,
            "intent": True,
            "n": 1
        }
        
        # Agregar tools si están presentes
        if tools:
            payload["tools"] = tools
            print(f"🔧 Tools incluidos: {len(tools)}")
        
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
    })

@app.route("/api/tags")
def ollama_tags():
    """Ollama: Listar modelos"""
    return jsonify({
        "models": [
            {
                "name": "gpt-4o-2024-11-20",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt4o-2024",
                "details": {
                    "format": "gguf",
                    "family": "gpt-4",
                    "parameter_size": "175B",
                    "quantization_level": "F16"
                }
            },
            {
                "name": "gpt-4",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt4",
                "details": {
                    "format": "gguf",
                    "family": "gpt-4",
                    "parameter_size": "175B",
                    "quantization_level": "F16"
                }
            },
            {
                "name": "gpt-5-mini",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt5-mini",
                "details": {
                    "format": "gguf",
                    "family": "gpt-5",
                    "parameter_size": "7B",
                    "quantization_level": "Q8"
                }
            },
            {
                "name": "gpt-4.1-2025-04-14",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt4.1",
                "details": {
                    "format": "gguf",
                    "family": "gpt-4",
                    "parameter_size": "200B",
                    "quantization_level": "F16"
                }
            },
            {
                "name": "gpt-4o",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt4o",
                "details": {
                    "format": "gguf",
                    "family": "gpt-4",
                    "parameter_size": "175B",
                    "quantization_level": "F16"
                }
            },
            {
                "name": "gpt-4o-mini",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt4o-mini",
                "details": {
                    "format": "gguf",
                    "family": "gpt-4",
                    "parameter_size": "8B",
                    "quantization_level": "Q8"
                }
            },
            {
                "name": "gpt-3.5-turbo",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-gpt35-turbo",
                "details": {
                    "format": "gguf",
                    "family": "gpt-3.5",
                    "parameter_size": "20B",
                    "quantization_level": "Q8"
                }
            },
            {
                "name": "claude-3.5-sonnet",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-claude35-sonnet",
                "details": {
                    "format": "gguf",
                    "family": "claude",
                    "parameter_size": "unknown",
                    "quantization_level": "F16"
                }
            },
            {
                "name": "o1-preview",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-o1-preview",
                "details": {
                    "format": "gguf",
                    "family": "o1",
                    "parameter_size": "unknown",
                    "quantization_level": "F16"
                }
            },
            {
                "name": "o1-mini",
                "modified_at": "2025-11-06T00:00:00Z",
                "size": 0,
                "digest": "copilot-o1-mini",
                "details": {
                    "format": "gguf",
                    "family": "o1",
                    "parameter_size": "8B",
                    "quantization_level": "Q8"
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
    """Ollama: Chat con mensajes y soporte para tools"""
    try:
        data = request.get_json()
        messages = data.get("messages", [])
        stream = data.get("stream", False)
        tools = data.get("tools")
        model = data.get("model", "gpt-4")
        
        if stream:
            def generate_ollama():
                tool_calls = []
                for line in client.chat(messages, tools=tools, model=model):
                    if line.startswith("data: "):
                        chunk_data = line[6:].strip()
                        if chunk_data and chunk_data != "[DONE]":
                            try:
                                obj = json.loads(chunk_data)
                                if "choices" in obj and len(obj["choices"]) > 0:
                                    delta = obj["choices"][0].get("delta", {})
                                    content = delta.get("content", "")
                                    role = delta.get("role", "assistant")
                                    
                                    # Capturar tool_calls
                                    if "tool_calls" in delta:
                                        for tc in delta["tool_calls"]:
                                            idx = tc.get("index", 0)
                                            while len(tool_calls) <= idx:
                                                tool_calls.append({"id": "", "type": "function", "function": {"name": "", "arguments": ""}})
                                            if "id" in tc:
                                                tool_calls[idx]["id"] = tc["id"]
                                            if "function" in tc:
                                                func = tc["function"]
                                                if "name" in func:
                                                    tool_calls[idx]["function"]["name"] = func["name"]
                                                if "arguments" in func:
                                                    tool_calls[idx]["function"]["arguments"] += func["arguments"]
                                    
                                    if content or role:
                                        # Formato Ollama streaming
                                        ollama_chunk = {
                                            "model": model,
                                            "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                                            "message": {
                                                "role": "assistant",
                                                "content": content
                                            },
                                            "done": False
                                        }
                                        if tool_calls:
                                            ollama_chunk["message"]["tool_calls"] = tool_calls
                                        yield json.dumps(ollama_chunk) + "\n"
                            except:
                                pass
                
                # Chunk final
                final_chunk = {
                    "model": model,
                    "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "message": {
                        "role": "assistant",
                        "content": ""
                    },
                    "done": True
                }
                if tool_calls:
                    final_chunk["message"]["tool_calls"] = tool_calls
                yield json.dumps(final_chunk) + "\n"
            
            return Response(generate_ollama(), mimetype="application/x-ndjson")
        else:
            # Non-streaming
            full_text = ""
            tool_calls = []
            
            for line in client.chat(messages, tools=tools, model=model):
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
                                
                                # Capturar tool_calls
                                if "tool_calls" in delta:
                                    for tc in delta["tool_calls"]:
                                        idx = tc.get("index", 0)
                                        while len(tool_calls) <= idx:
                                            tool_calls.append({"id": "", "type": "function", "function": {"name": "", "arguments": ""}})
                                        if "id" in tc:
                                            tool_calls[idx]["id"] = tc["id"]
                                        if "function" in tc:
                                            func = tc["function"]
                                            if "name" in func:
                                                tool_calls[idx]["function"]["name"] = func["name"]
                                            if "arguments" in func:
                                                tool_calls[idx]["function"]["arguments"] += func["arguments"]
                        except:
                            pass
            
            response_data = {
                "model": model,
                "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "message": {
                    "role": "assistant",
                    "content": full_text
                },
                "done": True
            }
            
            # Agregar tool_calls si existen
            if tool_calls:
                response_data["message"]["tool_calls"] = tool_calls
                print(f"🔧 Tool calls (Ollama): {len(tool_calls)}")
            
            return jsonify(response_data)
    
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route("/v1/chat/completions", methods=["POST"])
def chat():
    try:
        # Intentar parsear JSON con manejo de errores
        try:
            data = request.get_json(force=True)
        except Exception as json_error:
            print(f"❌ Error parsing JSON: {json_error}")
            print(f"Raw data: {request.data[:500]}")
            return jsonify({"error": f"Invalid JSON: {str(json_error)}"}), 400
        
        if not data:
            return jsonify({"error": "Empty request body"}), 400
            
        print(f"📨 Request: {json.dumps(data, ensure_ascii=False)[:200]}...")
        
        messages = data.get("messages", [])
        if not messages:
            return jsonify({"error": "messages field is required"}), 400
            
        stream = data.get("stream", False)
        tools = data.get("tools")
        model = data.get("model", "gpt-4")
        temperature = data.get("temperature", 0.7)
        max_tokens = data.get("max_tokens", 4000)
        
        print(f"🔍 Model: {model}, Messages: {len(messages)}, Tools: {len(tools) if tools else 0}, Stream: {stream}")
        
        if stream:
            return Response(
                client.chat(messages, tools=tools, model=model, temperature=temperature, max_tokens=max_tokens),
                mimetype="text/event-stream"
            )
        else:
            # Acumular respuesta y tool_calls
            full_text = ""
            tool_calls = []
            
            for line in client.chat(messages, tools=tools, model=model, temperature=temperature, max_tokens=max_tokens):
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
                                
                                # Capturar tool_calls
                                if "tool_calls" in delta:
                                    for tc in delta["tool_calls"]:
                                        # Buscar o crear tool_call
                                        idx = tc.get("index", 0)
                                        while len(tool_calls) <= idx:
                                            tool_calls.append({"id": "", "type": "function", "function": {"name": "", "arguments": ""}})
                                        
                                        if "id" in tc:
                                            tool_calls[idx]["id"] = tc["id"]
                                        if "function" in tc:
                                            func = tc["function"]
                                            if "name" in func:
                                                tool_calls[idx]["function"]["name"] = func["name"]
                                            if "arguments" in func:
                                                tool_calls[idx]["function"]["arguments"] += func["arguments"]
                        except Exception as e:
                            print(f"⚠️  Error parsing chunk: {e}")
                            pass
            
            # Construir respuesta
            response_data = {
                "id": f"chatcmpl-{uuid.uuid4().hex[:8]}",
                "object": "chat.completion",
                "created": int(time.time()),
                "model": model,
                "choices": [{
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": full_text if full_text else None
                    },
                    "finish_reason": "tool_calls" if tool_calls else "stop"
                }]
            }
            
            # Agregar tool_calls si existen
            if tool_calls:
                response_data["choices"][0]["message"]["tool_calls"] = tool_calls
                print(f"🔧 Tool calls detectados: {len(tool_calls)}")
            
            return jsonify(response_data)
            
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
