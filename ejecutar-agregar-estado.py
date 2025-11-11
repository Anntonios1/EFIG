import psycopg2
from psycopg2 import sql

# Configuración de conexión
config = {
    'host': '34.66.86.207',
    'port': 5433,
    'database': 'n8n_db',
    'user': 'n8n',
    'password': 'n8npass'
}

try:
    print("🔗 Conectando a PostgreSQL...")
    conn = psycopg2.connect(**config)
    cur = conn.cursor()
    print("✅ Conexión establecida\n")
    
    # Leer el script SQL
    print("📂 Ejecutando actualización de tabla clientes...")
    with open('agregar-estado-conversacion.sql', 'r', encoding='utf-8') as f:
        sql_script = f.read()
    
    # Ejecutar script
    cur.execute(sql_script)
    conn.commit()
    
    print("\n" + "="*60)
    print("✅ ACTUALIZACIÓN COMPLETADA EXITOSAMENTE!")
    print("="*60)
    
    # Verificar la columna creada
    print("\n📊 Verificando estructura de la columna...")
    cur.execute("""
        SELECT 
            column_name,
            data_type,
            column_default,
            is_nullable
        FROM information_schema.columns
        WHERE table_name = 'clientes' 
        AND column_name = 'estado_conversacion'
    """)
    
    result = cur.fetchone()
    if result:
        print(f"\n✅ Columna encontrada:")
        print(f"   Nombre: {result[0]}")
        print(f"   Tipo: {result[1]}")
        print(f"   Valor por defecto: {result[2]}")
        print(f"   Permite NULL: {result[3]}")
    
    # Verificar clientes existentes
    print("\n📋 Verificando clientes existentes...")
    cur.execute("""
        SELECT 
            id_cliente,
            nombre_completo,
            estado_conversacion
        FROM clientes
        ORDER BY fecha_registro DESC
        LIMIT 5
    """)
    
    clientes = cur.fetchall()
    print(f"\n✅ Primeros 5 clientes (total en DB):")
    for cliente in clientes:
        print(f"   {cliente[0]}: {cliente[1]} - Estado: '{cliente[2]}'")
    
    # Estadísticas por estado
    print("\n📊 Distribución de estados:")
    cur.execute("""
        SELECT 
            estado_conversacion,
            COUNT(*) as total
        FROM clientes
        GROUP BY estado_conversacion
        ORDER BY total DESC
    """)
    
    estados = cur.fetchall()
    for estado in estados:
        print(f"   {estado[0]}: {estado[1]} clientes")
    
    print("\n" + "="*60)
    print("🎉 TABLA ACTUALIZADA Y LISTA PARA USAR!")
    print("="*60)
    print("\n💡 Ahora puedes actualizar el estado desde n8n con:")
    print("   UPDATE clientes")
    print("   SET estado_conversacion = 'menu_mostrado'")
    print("   WHERE telegram_id = '{{$json.chat_id}}'")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    if 'conn' in locals():
        conn.rollback()
