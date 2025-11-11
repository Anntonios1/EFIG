import socket
import sys

def test_tcp_connection(host, port):
    """Prueba conexión TCP al servidor"""
    try:
        print(f"🔌 Probando conexión TCP a {host}:{port}...")
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        result = sock.connect_ex((host, port))
        sock.close()
        
        if result == 0:
            print("✅ Puerto accesible - Conexión TCP exitosa")
            return True
        else:
            print(f"❌ Puerto no accesible - Error código: {result}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_postgres_protocol(host, port):
    """Prueba protocolo PostgreSQL básico"""
    try:
        print(f"🔗 Probando protocolo PostgreSQL en {host}:{port}...")
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((host, port))
        
        # Enviar mensaje de inicio PostgreSQL básico
        startup_message = bytearray()
        startup_message.extend([0, 0, 0, 8])  # Longitud
        startup_message.extend([0, 3, 0, 0])  # Versión protocolo 3.0
        
        sock.send(startup_message)
        response = sock.recv(1024)
        sock.close()
        
        if len(response) > 0:
            print(f"✅ Servidor PostgreSQL responde - Recibido: {len(response)} bytes")
            return True
        else:
            print("❌ Servidor no responde como PostgreSQL")
            return False
            
    except Exception as e:
        print(f"❌ Error de protocolo PostgreSQL: {e}")
        return False

if __name__ == "__main__":
    host = "34.66.86.207"
    port = 5433
    
    print("=" * 50)
    print("🧪 PRUEBA DE CONECTIVIDAD POSTGRESQL")
    print("=" * 50)
    print(f"🎯 Destino: {host}:{port}")
    print(f"🗄️ Base de datos: n8n_db")
    print(f"👤 Usuario: n8n_user")
    print()
    
    # Prueba 1: Conexión TCP
    tcp_ok = test_tcp_connection(host, port)
    print()
    
    # Prueba 2: Protocolo PostgreSQL
    if tcp_ok:
        postgres_ok = test_postgres_protocol(host, port)
    else:
        print("⏭️ Saltando prueba PostgreSQL (TCP falló)")
        postgres_ok = False
    
    print()
    print("=" * 50)
    print("📊 RESUMEN")
    print("=" * 50)
    print(f"TCP Connection: {'✅ OK' if tcp_ok else '❌ FAIL'}")
    print(f"PostgreSQL Protocol: {'✅ OK' if postgres_ok else '❌ FAIL'}")
    
    if tcp_ok and postgres_ok:
        print()
        print("🎉 ¡El servidor PostgreSQL está accesible!")
        print("🔧 El problema puede estar en:")
        print("   - Credenciales incorrectas")
        print("   - Configuración SSL en n8n")
        print("   - Variables de entorno en Render")
    elif tcp_ok:
        print()
        print("⚠️ Puerto accesible pero el protocolo PostgreSQL falla")
        print("🔧 Posibles causas:")
        print("   - Servidor no es PostgreSQL")
        print("   - Configuración de autenticación")
    else:
        print()
        print("💥 Servidor no accesible")
        print("🔧 Verifica:")
        print("   - IP y puerto correctos")
        print("   - Firewall de GCP")
        print("   - Estado del servidor")
    
    print("=" * 50)