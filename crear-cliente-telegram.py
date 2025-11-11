import psycopg2

print("🔗 Conectando a PostgreSQL...")

try:
    conn = psycopg2.connect(
        host="34.66.86.207",
        port=5433,
        database="n8n_db",
        user="n8n",
        password="n8npass"
    )
    
    cur = conn.cursor()
    print("✅ Conexión establecida\n")
    
    # Datos del cliente de prueba
    telegram_id = "7132d28de59a44d8809fb7c205f58d5a"
    
    print(f"👤 Creando cliente de prueba con telegram_id: {telegram_id}\n")
    
    # Insertar cliente
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
    
    # Crear una reserva de prueba para este cliente
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
    
    print("✅ Reserva creada exitosamente!")
    print("=" * 60)
    print(f"ID Reserva: {reserva[0]}")
    print(f"Destino: {reserva[1]}")
    print(f"Precio: ${reserva[2]} USD")
    print(f"Estado: {reserva[3]}")
    print("=" * 60)
    
    # Crear un pago de prueba
    print("\n💳 Creando pago de prueba...\n")
    
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
        ) RETURNING id_pago, monto, metodo, estado
    """, (reserva[0],))
    
    pago = cur.fetchone()
    conn.commit()
    
    print("✅ Pago registrado exitosamente!")
    print("=" * 60)
    print(f"ID Pago: {pago[0]}")
    print(f"Monto: ${pago[1]} USD")
    print(f"Método: {pago[2]}")
    print(f"Estado: {pago[3]}")
    print("=" * 60)
    
    # Verificar que se creó correctamente
    print("\n🔍 Verificando datos completos del cliente...\n")
    
    cur.execute("""
        SELECT 
            c.id_cliente,
            c.nombre_completo,
            c.email,
            c.telefono,
            c.telegram_id,
            c.tipo_cliente,
            c.total_gastado,
            c.num_viajes,
            COUNT(r.id_reserva) as reservas_count,
            COUNT(p.id_pago) as pagos_count
        FROM clientes c
        LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
        LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
        WHERE c.telegram_id = %s
        GROUP BY c.id_cliente
    """, (telegram_id,))
    
    verificacion = cur.fetchone()
    
    print("📊 RESUMEN DEL CLIENTE DE PRUEBA")
    print("=" * 60)
    print(f"ID: {verificacion[0]}")
    print(f"Nombre: {verificacion[1]}")
    print(f"Email: {verificacion[2]}")
    print(f"Teléfono: {verificacion[3]}")
    print(f"Telegram ID: {verificacion[4]}")
    print(f"Tipo: {verificacion[5]}")
    print(f"Total gastado: ${verificacion[6]}")
    print(f"Número de viajes: {verificacion[7]}")
    print(f"Reservas: {verificacion[8]}")
    print(f"Pagos: {verificacion[9]}")
    print("=" * 60)
    
    print("\n🎉 ¡Todo listo para probar el workflow de Telegram!")
    print("\n📝 Para probar, envía un mensaje desde tu Telegram bot")
    print(f"   El sistema debería reconocer al usuario con ID: {telegram_id}")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import sys
    sys.exit(1)
