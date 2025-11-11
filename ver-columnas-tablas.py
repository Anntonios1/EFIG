import psycopg2

config = {
    'host': '34.66.86.207',
    'port': 5433,
    'database': 'n8n_db',
    'user': 'n8n',
    'password': 'n8npass'
}

try:
    conn = psycopg2.connect(**config)
    cur = conn.cursor()
    
    # Ver columnas de reservas
    print("📋 COLUMNAS DE LA TABLA RESERVAS:")
    print("="*60)
    cur.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'reservas'
        ORDER BY ordinal_position
    """)
    for col in cur.fetchall():
        print(f"   {col[0]} ({col[1]})")
    
    # Ver columnas de pagos
    print("\n💳 COLUMNAS DE LA TABLA PAGOS:")
    print("="*60)
    cur.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'pagos'
        ORDER BY ordinal_position
    """)
    for col in cur.fetchall():
        print(f"   {col[0]} ({col[1]})")
    
    # Ver columnas de notificaciones
    print("\n🔔 COLUMNAS DE LA TABLA NOTIFICACIONES:")
    print("="*60)
    cur.execute("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'notificaciones'
        ORDER BY ordinal_position
    """)
    for col in cur.fetchall():
        print(f"   {col[0]} ({col[1]})")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"Error: {e}")
