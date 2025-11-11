import psycopg2

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
    
    # Buscar cliente por nombre
    print("🔍 Buscando cliente 'Jeyler Antonio Martinez'...")
    cur.execute("""
        SELECT id_cliente, nombre_completo, telegram_id, email, tipo_cliente
        FROM clientes
        WHERE UPPER(nombre_completo) LIKE UPPER('%Jeyler%Martinez%')
        OR UPPER(nombre_completo) LIKE UPPER('%Martinez%Jeyler%')
    """)
    
    clientes = cur.fetchall()
    
    if not clientes:
        print("❌ No se encontró el cliente. Buscando nombres similares...")
        cur.execute("""
            SELECT id_cliente, nombre_completo, telegram_id, email
            FROM clientes
            WHERE UPPER(nombre_completo) LIKE UPPER('%Jeyler%')
            OR UPPER(nombre_completo) LIKE UPPER('%Martinez%')
            LIMIT 10
        """)
        similares = cur.fetchall()
        if similares:
            print("\n📋 Clientes encontrados con nombres similares:")
            for cliente in similares:
                print(f"   {cliente[0]}: {cliente[1]} - Telegram: {cliente[2] or 'No asignado'}")
    else:
        print(f"✅ Cliente encontrado!")
        for cliente in clientes:
            id_cliente = cliente[0]
            nombre = cliente[1]
            telegram_actual = cliente[2]
            email = cliente[3]
            tipo = cliente[4]
            
            print(f"\n📋 Datos actuales:")
            print(f"   ID: {id_cliente}")
            print(f"   Nombre: {nombre}")
            print(f"   Email: {email}")
            print(f"   Tipo: {tipo}")
            print(f"   Telegram ID actual: {telegram_actual or 'No asignado'}")
            
            # Deshabilitar trigger temporalmente
            print(f"\n⏸️ Deshabilitando trigger de auditoría...")
            cur.execute("ALTER TABLE clientes DISABLE TRIGGER trigger_auditar_clientes")
            
            # Actualizar Telegram ID
            print(f"🔄 Actualizando Telegram ID a: 1557475089")
            cur.execute("""
                UPDATE clientes
                SET telegram_id = %s
                WHERE id_cliente = %s
            """, ('1557475089', id_cliente))
            
            # Reactivar trigger
            print(f"▶️ Reactivando trigger de auditoría...")
            cur.execute("ALTER TABLE clientes ENABLE TRIGGER trigger_auditar_clientes")
            
            conn.commit()
            
            # Verificar actualización
            cur.execute("""
                SELECT id_cliente, nombre_completo, telegram_id, email
                FROM clientes
                WHERE id_cliente = %s
            """, (id_cliente,))
            
            resultado = cur.fetchone()
            print(f"\n✅ ACTUALIZACIÓN EXITOSA!")
            print(f"   ID: {resultado[0]}")
            print(f"   Nombre: {resultado[1]}")
            print(f"   Telegram ID: {resultado[2]}")
            print(f"   Email: {resultado[3]}")
            
            # Mostrar reservas si las tiene
            cur.execute("""
                SELECT COUNT(*)
                FROM reservas
                WHERE id_cliente = %s
            """, (id_cliente,))
            
            num_reservas = cur.fetchone()[0]
            if num_reservas > 0:
                print(f"\n✈️ El cliente tiene {num_reservas} reserva(s) registrada(s)")
    
    cur.close()
    conn.close()
    
    print("\n" + "="*60)
    print("🎉 PROCESO COMPLETADO")
    print("="*60)
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    if 'conn' in locals():
        conn.rollback()
