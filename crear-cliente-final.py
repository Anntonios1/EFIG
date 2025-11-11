import psycopg2

print("🔧 Creando cliente sin triggers...")

try:
    conn = psycopg2.connect(
        host="34.66.86.207",
        port=5433,
        database="n8n_db",
        user="n8n",
        password="n8npass"
    )
    
    cur = conn.cursor()
    
    # Deshabilitar trigger temporalmente
    print("⏸️  Deshabilitando trigger de auditoría...\n")
    cur.execute("ALTER TABLE clientes DISABLE TRIGGER trigger_auditar_clientes")
    conn.commit()
    
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
    
    print("✅ Cliente creado!")
    print("=" * 60)
    print(f"ID Cliente: {cliente[0]}")
    print(f"Nombre: {cliente[1]}")
    print(f"Telegram ID: {telegram_id}")
    print("=" * 60)
    
    # Reactivar trigger
    print("\n▶️  Reactivando trigger de auditoría...")
    cur.execute("ALTER TABLE clientes ENABLE TRIGGER trigger_auditar_clientes")
    conn.commit()
    
    # Crear reserva (sin trigger también)
    print("\n✈️ Creando reserva...\n")
    cur.execute("ALTER TABLE reservas DISABLE TRIGGER trigger_auditar_reservas")
    cur.execute("ALTER TABLE reservas DISABLE TRIGGER trigger_estadisticas_cliente")
    cur.execute("ALTER TABLE reservas DISABLE TRIGGER trigger_fecha_limite")
    conn.commit()
    
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
            creado_por,
            fecha_limite_pago
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
            'Reserva de prueba',
            'sistema',
            NOW() + INTERVAL '7 days'
        ) RETURNING id_reserva, destino, precio
    """, (cliente[0],))
    
    reserva = cur.fetchone()
    conn.commit()
    
    print("✅ Reserva creada!")
    print(f"   ID: {reserva[0]}")
    print(f"   Destino: {reserva[1]}")
    print(f"   Precio: ${reserva[2]} USD")
    
    # Reactivar triggers de reservas
    cur.execute("ALTER TABLE reservas ENABLE TRIGGER trigger_auditar_reservas")
    cur.execute("ALTER TABLE reservas ENABLE TRIGGER trigger_estadisticas_cliente")
    cur.execute("ALTER TABLE reservas ENABLE TRIGGER trigger_fecha_limite")
    conn.commit()
    
    # Crear pago
    print("\n💳 Creando pago...\n")
    cur.execute("ALTER TABLE pagos DISABLE TRIGGER trigger_auditar_pagos")
    cur.execute("ALTER TABLE pagos DISABLE TRIGGER trigger_calcular_neto")
    conn.commit()
    
    cur.execute("""
        INSERT INTO pagos (
            id_reserva,
            monto,
            metodo,
            estado,
            referencia_transaccion,
            moneda,
            neto
        ) VALUES (
            %s,
            850.00,
            'tarjeta',
            'completado',
            'TEST-12345',
            'USD',
            850.00
        ) RETURNING id_pago, monto
    """, (reserva[0],))
    
    pago = cur.fetchone()
    conn.commit()
    
    print("✅ Pago registrado!")
    print(f"   ID: {pago[0]}")
    print(f"   Monto: ${pago[1]} USD")
    
    # Reactivar triggers de pagos
    cur.execute("ALTER TABLE pagos ENABLE TRIGGER trigger_auditar_pagos")
    cur.execute("ALTER TABLE pagos ENABLE TRIGGER trigger_calcular_neto")
    conn.commit()
    
    # Actualizar manualmente estadísticas del cliente
    print("\n📊 Actualizando estadísticas del cliente...")
    cur.execute("""
        UPDATE clientes SET
            total_gastado = 850.00,
            num_viajes = 1
        WHERE id_cliente = %s
    """, (cliente[0],))
    conn.commit()
    
    # Crear conversaciones
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
            es_bot,
            respondido
        ) VALUES 
        (%s, 'telegram', %s, 'Hola, quiero ver mi reserva', 'recibido', 'neutral', 'consulta', false, true),
        (%s, 'telegram', %s, 'Claro! Encontré tu reserva a Cartagena confirmada para dentro de 15 días', 'enviado', 'positivo', 'consulta', true, true)
    """, (cliente[0], telegram_id, cliente[0], telegram_id))
    
    conn.commit()
    
    print("✅ Conversaciones creadas!")
    
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
            c.tipo_cliente,
            c.total_gastado,
            c.num_viajes,
            r.id_reserva,
            r.destino,
            r.estado as reserva_estado,
            p.id_pago,
            p.estado as pago_estado
        FROM clientes c
        LEFT JOIN reservas r ON c.id_cliente = r.id_cliente
        LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
        WHERE c.telegram_id = %s
    """, (telegram_id,))
    
    datos = cur.fetchone()
    
    print(f"\n📊 DATOS COMPLETOS:")
    print(f"   Cliente ID: {datos[0]}")
    print(f"   Nombre: {datos[1]}")
    print(f"   Telegram ID: {datos[2]}")
    print(f"   Email: {datos[3]}")
    print(f"   Tipo: {datos[4]}")
    print(f"   Total gastado: ${datos[5]} USD")
    print(f"   Viajes: {datos[6]}")
    print(f"\n   Reserva ID: {datos[7]}")
    print(f"   Destino: {datos[8]}")
    print(f"   Estado reserva: {datos[9]}")
    print(f"\n   Pago ID: {datos[10]}")
    print(f"   Estado pago: {datos[11]}")
    
    print("\n✅ ¡Listo para probar en Telegram!")
    print("=" * 60)
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
