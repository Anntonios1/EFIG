import psycopg2

print("🔧 Modificando columna telegram_id de BIGINT a VARCHAR...")

try:
    conn = psycopg2.connect(
        host="34.66.86.207",
        port=5433,
        database="n8n_db",
        user="n8n",
        password="n8npass"
    )
    
    cur = conn.cursor()
    
    # Alterar la columna a VARCHAR
    print("⚡ Ejecutando ALTER TABLE...\n")
    
    cur.execute("""
        ALTER TABLE clientes 
        ALTER COLUMN telegram_id TYPE VARCHAR(100) USING telegram_id::VARCHAR
    """)
    
    conn.commit()
    
    print("✅ Columna modificada exitosamente!")
    print("   telegram_id: BIGINT → VARCHAR(100)\n")
    
    # Ahora crear el cliente
    telegram_id = "7132d28de59a44d8809fb7c205f58d5a"
    
    print(f"👤 Creando cliente con telegram_id: {telegram_id}\n")
    
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
    
    # Crear reserva de prueba
    print("\n✈️ Creando reserva de prueba...\n")
    
    cur.execute("""
        INSERT INTO reservas (
            id_cliente,
            tipo,
            origen,
            destino,
            fecha_salida,
            fecha_regreso,
            precio,
            estado,
            aerolinea,
            numero_vuelo,
            num_adultos,
            clase,
            equipaje,
            notas,
            creado_por
        ) VALUES (
            %s,
            'paquete',
            'Bogotá',
            'Cartagena',
            NOW() + INTERVAL '15 days',
            NOW() + INTERVAL '18 days',
            850.00,
            'confirmado',
            'Avianca',
            'AV123',
            1,
            'economica',
            '1_maleta',
            'Reserva de prueba para testing',
            'sistema'
        ) RETURNING id_reserva, destino, precio, estado
    """, (cliente[0],))
    
    reserva = cur.fetchone()
    conn.commit()
    
    print("✅ Reserva creada!")
    print(f"   ID: {reserva[0]}")
    print(f"   Destino: {reserva[1]}")
    print(f"   Precio: ${reserva[2]} USD")
    print(f"   Estado: {reserva[3]}")
    
    # Crear pago
    print("\n💳 Creando pago...\n")
    
    cur.execute("""
        INSERT INTO pagos (
            id_reserva,
            monto,
            metodo,
            estado,
            referencia_transaccion,
            moneda
        ) VALUES (
            %s,
            850.00,
            'tarjeta',
            'completado',
            'TEST-' || EXTRACT(EPOCH FROM NOW())::TEXT,
            'USD'
        ) RETURNING id_pago, monto, estado
    """, (reserva[0],))
    
    pago = cur.fetchone()
    conn.commit()
    
    print("✅ Pago registrado!")
    print(f"   ID: {pago[0]}")
    print(f"   Monto: ${pago[1]} USD")
    print(f"   Estado: {pago[2]}")
    
    # Crear conversación de prueba
    print("\n💬 Creando historial de conversación...\n")
    
    cur.execute("""
        INSERT INTO conversaciones (
            id_cliente,
            canal,
            chat_id,
            mensaje,
            tipo,
            sentimiento,
            intencion,
            es_bot
        ) VALUES 
        (%s, 'telegram', %s, '¡Hola! Quiero información sobre mi reserva', 'recibido', 'neutral', 'consulta', false),
        (%s, 'telegram', %s, 'Claro, déjame consultar tu reserva...', 'enviado', 'positivo', 'consulta', true)
        RETURNING id_conversacion
    """, (cliente[0], telegram_id, cliente[0], telegram_id))
    
    conversaciones = cur.fetchall()
    conn.commit()
    
    print(f"✅ {len(conversaciones)} conversaciones creadas!")
    
    # Resumen final
    print("\n" + "=" * 60)
    print("🎉 CLIENTE DE PRUEBA CREADO EXITOSAMENTE")
    print("=" * 60)
    
    cur.execute("""
        SELECT 
            c.id_cliente,
            c.nombre_completo,
            c.telegram_id,
            c.email,
            c.telefono,
            c.tipo_cliente,
            COUNT(DISTINCT r.id_reserva) as reservas,
            COUNT(DISTINCT p.id_pago) as pagos,
            COUNT(DISTINCT co.id_conversacion) as conversaciones
        FROM clientes c
        LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
        LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
        LEFT JOIN conversaciones co ON c.id_cliente = co.id_cliente
        WHERE c.telegram_id = %s
        GROUP BY c.id_cliente
    """, (telegram_id,))
    
    resumen = cur.fetchone()
    
    print(f"\n📊 RESUMEN:")
    print(f"   ID Cliente: {resumen[0]}")
    print(f"   Nombre: {resumen[1]}")
    print(f"   Telegram ID: {resumen[2]}")
    print(f"   Email: {resumen[3]}")
    print(f"   Teléfono: {resumen[4]}")
    print(f"   Tipo: {resumen[5]}")
    print(f"   Reservas: {resumen[6]}")
    print(f"   Pagos: {resumen[7]}")
    print(f"   Conversaciones: {resumen[8]}")
    
    print("\n✅ ¡Listo para probar el workflow de Telegram!")
    print(f"   Usa el telegram_id: {telegram_id}")
    print("=" * 60)
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
