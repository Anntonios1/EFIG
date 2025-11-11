import psycopg2

print("🔍 Verificando tipo de columna telegram_id...")

try:
    conn = psycopg2.connect(
        host="34.66.86.207",
        port=5433,
        database="n8n_db",
        user="n8n",
        password="n8npass"
    )
    
    cur = conn.cursor()
    
    # Verificar tipo actual de la columna
    cur.execute("""
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_name = 'clientes' 
        AND column_name = 'telegram_id'
    """)
    
    result = cur.fetchone()
    
    if result:
        print(f"✅ Columna encontrada: {result[0]}")
        print(f"   Tipo actual: {result[1]}")
        print(f"   Longitud: {result[2]}")
        
        # Si es VARCHAR, procedemos
        if result[1] == 'character varying':
            print("\n✅ Tipo correcto (VARCHAR). Creando cliente...\n")
            
            telegram_id = "7132d28de59a44d8809fb7c205f58d5a"
            
            cur.execute("""
                INSERT INTO clientes (
                    nombre_completo,
                    email,
                    telefono,
                    documento,
                    tipo_cliente,
                    telegram_id,
                    whatsapp,
                    canal_preferido,
                    idioma,
                    pais,
                    ciudad,
                    activo,
                    notas
                ) VALUES (
                    'Juan Pérez (Prueba Telegram)',
                    'juan.prueba@efig.com',
                    '+57 300 123 4567',
                    '1234567890',
                    'nuevo',
                    %s,
                    '+573001234567',
                    'telegram',
                    'es',
                    'Colombia',
                    'Bogotá',
                    true,
                    'Cliente de prueba para testing de workflow Telegram'
                ) RETURNING id_cliente, nombre_completo
            """, (telegram_id,))
            
            cliente = cur.fetchone()
            conn.commit()
            
            print("✅ Cliente creado exitosamente!")
            print("=" * 60)
            print(f"ID Cliente: {cliente[0]}")
            print(f"Nombre: {cliente[1]}")
            print(f"Telegram ID: {telegram_id}")
            print("=" * 60)
            
    else:
        print("❌ Columna telegram_id no encontrada. Creándola...")
        
        cur.execute("""
            ALTER TABLE clientes 
            ADD COLUMN IF NOT EXISTS telegram_id VARCHAR(100)
        """)
        conn.commit()
        
        print("✅ Columna creada. Ejecuta el script de nuevo.")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()

