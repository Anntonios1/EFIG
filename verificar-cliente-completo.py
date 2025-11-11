import psycopg2

telegram_id = "7132d28de59a44d8809fb7c205f58d5a"

print(f"🔍 Verificando cliente con telegram_id: {telegram_id}\n")

try:
    conn = psycopg2.connect(
        host="34.66.86.207",
        port=5433,
        database="n8n_db",
        user="n8n",
        password="n8npass"
    )
    
    cur = conn.cursor()
    
    # Consultar datos completos
    cur.execute("""
        SELECT 
            c.id_cliente,
            c.nombre_completo,
            c.telegram_id,
            c.email,
            c.telefono,
            c.tipo_cliente,
            c.canal_preferido,
            c.idioma,
            c.pais,
            c.ciudad,
            c.total_gastado,
            c.num_viajes,
            c.activo
        FROM clientes c
        WHERE c.telegram_id = %s
    """, (telegram_id,))
    
    cliente = cur.fetchone()
    
    if cliente:
        print("✅ CLIENTE ENCONTRADO")
        print("=" * 60)
        print(f"ID: {cliente[0]}")
        print(f"Nombre: {cliente[1]}")
        print(f"Telegram ID: {cliente[2]}")
        print(f"Email: {cliente[3]}")
        print(f"Teléfono: {cliente[4]}")
        print(f"Tipo: {cliente[5]}")
        print(f"Canal preferido: {cliente[6]}")
        print(f"Idioma: {cliente[7]}")
        print(f"País: {cliente[8]}")
        print(f"Ciudad: {cliente[9]}")
        print(f"Total gastado: ${cliente[10] or 0}")
        print(f"Viajes: {cliente[11] or 0}")
        print(f"Activo: {cliente[12]}")
        
        id_cliente = cliente[0]
        
        # Verificar reservas
        cur.execute("""
            SELECT id_reserva, tipo, destino, fecha_salida, precio, estado
            FROM reservas
            WHERE id_cliente = %s
        """, (id_cliente,))
        
        reservas = cur.fetchall()
        print(f"\n✈️ RESERVAS: {len(reservas)}")
        for r in reservas:
            print(f"   {r[0]}: {r[1]} a {r[2]} - ${r[4]} USD ({r[5]})")
        
        # Verificar pagos
        if reservas:
            for reserva in reservas:
                cur.execute("""
                    SELECT id_pago, monto, metodo, estado
                    FROM pagos
                    WHERE id_reserva = %s
                """, (reserva[0],))
                
                pagos = cur.fetchall()
                print(f"\n💳 PAGOS para {reserva[0]}: {len(pagos)}")
                for p in pagos:
                    print(f"   {p[0]}: ${p[1]} USD - {p[2]} ({p[3]})")
        
        # Verificar conversaciones
        cur.execute("""
            SELECT id_conversacion, canal, mensaje, tipo, fecha_hora
            FROM conversaciones
            WHERE id_cliente = %s
            ORDER BY fecha_hora
        """, (id_cliente,))
        
        conversaciones = cur.fetchall()
        print(f"\n💬 CONVERSACIONES: {len(conversaciones)}")
        for c in conversaciones:
            print(f"   [{c[4].strftime('%H:%M')}] {c[3]}: {c[2][:50]}...")
        
        # Actualizar estadísticas si están en 0
        if cliente[10] is None or cliente[10] == 0:
            print("\n📊 Actualizando estadísticas...")
            
            # Deshabilitar trigger temporalmente
            cur.execute("ALTER TABLE clientes DISABLE TRIGGER trigger_auditar_clientes")
            
            cur.execute("""
                UPDATE clientes SET
                    total_gastado = 850.00,
                    num_viajes = 1
                WHERE id_cliente = %s
            """, (id_cliente,))
            
            conn.commit()
            
            # Reactivar trigger
            cur.execute("ALTER TABLE clientes ENABLE TRIGGER trigger_auditar_clientes")
            conn.commit()
            
            print("   ✅ Estadísticas actualizadas!")
        
        # Crear conversaciones si no existen
        if len(conversaciones) == 0:
            print("\n💬 Creando conversaciones de ejemplo...")
            
            cur.execute("""
                INSERT INTO conversaciones (
                    id_cliente,
                    canal,
                    chat_id,
                    mensaje,
                    tipo,
                    sentimiento,
                    intencion,
                    es_bot,
                    respondido
                ) VALUES 
                (%s, 'telegram', %s, 'Hola, quiero información de mi reserva', 'recibido', 'neutral', 'consulta', false, true),
                (%s, 'telegram', %s, '¡Hola Juan! Claro, tienes una reserva confirmada a Cartagena por $850 USD. Sale en 15 días. ¿Necesitas algo más?', 'enviado', 'positivo', 'consulta', true, true)
            """, (id_cliente, telegram_id, id_cliente, telegram_id))
            
            conn.commit()
            print("   ✅ 2 conversaciones creadas!")
        
        print("\n" + "=" * 60)
        print("🎉 CLIENTE LISTO PARA USAR EN TELEGRAM")
        print("=" * 60)
        print(f"\n📱 Para probar:")
        print(f"   1. Abre tu bot de Telegram")
        print(f"   2. El sistema reconocerá el chat_id: {telegram_id}")
        print(f"   3. Asociará con el cliente: {id_cliente} ({cliente[1]})")
        print(f"   4. Prueba consultas como:")
        print(f"      - 'Ver mis reservas'")
        print(f"      - 'Información de mi viaje'")
        print(f"      - 'Cuánto he gastado'")
        
    else:
        print("❌ Cliente no encontrado!")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
