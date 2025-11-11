import psycopg2
from datetime import datetime, timedelta

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
    
    print("="*70)
    print("🎭 CREANDO DATOS DE PRUEBA PARA CLIENTE C-0036")
    print("="*70)
    
    # Obtener información actual del cliente
    cur.execute("""
        SELECT id_cliente, nombre_completo, email, telegram_id, tipo_cliente
        FROM clientes
        WHERE id_cliente = 'C-0036'
    """)
    
    cliente = cur.fetchone()
    print(f"\n👤 Cliente: {cliente[1]}")
    print(f"   Email: {cliente[2]}")
    print(f"   Telegram: {cliente[3]}")
    print(f"   Tipo: {cliente[4]}")
    
    # 1. CREAR RESERVAS VARIADAS (diferentes estados y tipos)
    print("\n" + "="*70)
    print("✈️ CREANDO RESERVAS DE PRUEBA")
    print("="*70)
    
    reservas = [
        {
            'id': 'R-TEST-001',
            'tipo': 'vuelo',
            'origen': 'Bogotá',
            'destino': 'Miami',
            'fecha_salida': (datetime.now() + timedelta(days=30)).date(),
            'fecha_regreso': (datetime.now() + timedelta(days=37)).date(),
            'precio': 650.00,
            'estado': 'confirmado',
            'aerolinea': 'American Airlines',
            'numero_vuelo': 'AA1234',
            'num_adultos': 2,
            'clase': 'economica'
        },
        {
            'id': 'R-TEST-002',
            'tipo': 'hotel',
            'origen': 'Bogotá',
            'destino': 'Cartagena',
            'fecha_salida': (datetime.now() + timedelta(days=15)).date(),
            'fecha_regreso': (datetime.now() + timedelta(days=18)).date(),
            'precio': 450.00,
            'estado': 'pendiente',
            'hotel_nombre': 'Hotel Charleston Santa Teresa',
            'num_adultos': 2,
            'num_ninos': 0
        },
        {
            'id': 'R-TEST-003',
            'tipo': 'paquete',
            'origen': 'Bogotá',
            'destino': 'Cancún',
            'fecha_salida': (datetime.now() + timedelta(days=60)).date(),
            'fecha_regreso': (datetime.now() + timedelta(days=65)).date(),
            'precio': 1200.00,
            'estado': 'cotizacion',
            'aerolinea': 'Avianca',
            'hotel_nombre': 'Hotel Riu Cancun',
            'num_adultos': 2,
            'num_ninos': 1
        },
        {
            'id': 'R-TEST-004',
            'tipo': 'vuelo',
            'origen': 'Cali',
            'destino': 'Bogotá',
            'fecha_salida': (datetime.now() - timedelta(days=30)).date(),
            'fecha_regreso': (datetime.now() - timedelta(days=28)).date(),
            'precio': 180.00,
            'estado': 'completado',
            'aerolinea': 'LATAM',
            'num_adultos': 1,
            'clase': 'ejecutiva'
        },
        {
            'id': 'R-TEST-005',
            'tipo': 'paquete',
            'origen': 'Bogotá',
            'destino': 'San Andrés',
            'fecha_salida': (datetime.now() + timedelta(days=7)).date(),
            'fecha_regreso': (datetime.now() + timedelta(days=10)).date(),
            'precio': 800.00,
            'estado': 'pendiente_pago',
            'aerolinea': 'Avianca',
            'hotel_nombre': 'Decameron San Luis',
            'num_adultos': 2
        }
    ]
    
    for reserva in reservas:
        try:
            cur.execute("""
                INSERT INTO reservas (
                    id_reserva, id_cliente, tipo, origen, destino, 
                    fecha_salida, fecha_regreso, precio, estado,
                    aerolinea, numero_vuelo, hotel_nombre,
                    num_adultos, num_ninos, clase
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                )
                ON CONFLICT (id_reserva) DO NOTHING
            """, (
                reserva['id'], 'C-0036', reserva['tipo'], reserva.get('origen'), reserva['destino'],
                reserva['fecha_salida'], reserva['fecha_regreso'], reserva['precio'], reserva['estado'],
                reserva.get('aerolinea'), reserva.get('numero_vuelo'), reserva.get('hotel_nombre'),
                reserva.get('num_adultos', 1), reserva.get('num_ninos', 0), reserva.get('clase')
            ))
            conn.commit()
            print(f"   ✅ {reserva['id']}: {reserva['tipo']} a {reserva['destino']} - {reserva['estado']}")
        except Exception as e:
            if 'duplicate key' not in str(e):
                print(f"   ⚠️  {reserva['id']}: {e}")
            conn.rollback()
    
    # 2. CREAR PAGOS ASOCIADOS
    print("\n" + "="*70)
    print("💳 CREANDO PAGOS DE PRUEBA")
    print("="*70)
    
    pagos = [
        {'id': 'P-TEST-001', 'reserva': 'R-TEST-001', 'monto': 650.00, 'metodo': 'tarjeta', 'estado': 'completado'},
        {'id': 'P-TEST-002', 'reserva': 'R-TEST-002', 'monto': 450.00, 'metodo': 'transferencia', 'estado': 'pendiente'},
        {'id': 'P-TEST-003', 'reserva': 'R-TEST-004', 'monto': 180.00, 'metodo': 'tarjeta', 'estado': 'completado'},
        {'id': 'P-TEST-004', 'reserva': 'R-TEST-005', 'monto': 400.00, 'metodo': 'efectivo', 'estado': 'parcial'},
    ]
    
    for pago in pagos:
        try:
            cur.execute("""
                INSERT INTO pagos (
                    id_reserva, monto, metodo, estado, fecha
                ) VALUES (
                    %s, %s, %s, %s, CURRENT_DATE
                )
                RETURNING id_pago
            """, (pago['reserva'], pago['monto'], pago['metodo'], pago['estado']))
            
            result = cur.fetchone()
            if result:
                conn.commit()
                print(f"   ✅ Pago {result[0]}: ${pago['monto']} - {pago['metodo']} ({pago['estado']})")
        except Exception as e:
            print(f"   ⚠️  {pago['id']}: {e}")
            conn.rollback()
    
    # 3. CREAR CONVERSACIONES (historial de chat)
    print("\n" + "="*70)
    print("💬 CREANDO HISTORIAL DE CONVERSACIONES")
    print("="*70)
    
    conversaciones = [
        {'canal': 'telegram', 'mensaje': 'Hola, quiero información sobre mis reservas', 'tipo': 'recibido', 'es_bot': False},
        {'canal': 'telegram', 'mensaje': '¡Hola Jeyler! 👋 Claro, te muestro tus reservas activas...', 'tipo': 'enviado', 'es_bot': True},
        {'canal': 'telegram', 'mensaje': 'Quiero ver la de Miami', 'tipo': 'recibido', 'es_bot': False},
        {'canal': 'telegram', 'mensaje': 'Tu vuelo a Miami está confirmado ✈️\nSalida: en 30 días\nAerolínea: American Airlines', 'tipo': 'enviado', 'es_bot': True},
        {'canal': 'telegram', 'mensaje': '¿Cuánto debo de la reserva de San Andrés?', 'tipo': 'recibido', 'es_bot': False},
        {'canal': 'telegram', 'mensaje': 'De tu paquete a San Andrés ($800 USD) has pagado $400. Quedan $400 por pagar.', 'tipo': 'enviado', 'es_bot': True},
    ]
    
    for conv in conversaciones:
        try:
            cur.execute("""
                INSERT INTO conversaciones (
                    id_cliente, canal, chat_id, mensaje, tipo, es_bot, fecha_hora
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, NOW() - INTERVAL '1 hour' * %s
                )
            """, (
                'C-0036', conv['canal'], '1557475089', conv['mensaje'], 
                conv['tipo'], conv['es_bot'], len(conversaciones) - conversaciones.index(conv)
            ))
            conn.commit()
            print(f"   ✅ {conv['tipo']}: {conv['mensaje'][:50]}...")
        except Exception as e:
            print(f"   ⚠️  Error: {e}")
            conn.rollback()
    
    # 4. ACTUALIZAR ESTADO DE CONVERSACIÓN
    print("\n" + "="*70)
    print("🔄 ACTUALIZANDO ESTADO DEL CLIENTE")
    print("="*70)
    
    cur.execute("""
        UPDATE clientes
        SET 
            estado_conversacion = 'menu_mostrado',
            ultimo_contacto = NOW(),
            total_gastado = (
                SELECT COALESCE(SUM(precio), 0) 
                FROM reservas 
                WHERE id_cliente = 'C-0036' AND estado IN ('confirmado', 'completado')
            ),
            num_viajes = (
                SELECT COUNT(*) 
                FROM reservas 
                WHERE id_cliente = 'C-0036' AND estado = 'completado'
            )
        WHERE id_cliente = 'C-0036'
        RETURNING estado_conversacion, total_gastado, num_viajes
    """)
    
    resultado = cur.fetchone()
    conn.commit()
    print(f"   ✅ Estado conversación: {resultado[0]}")
    print(f"   ✅ Total gastado: ${resultado[1]:.2f}")
    print(f"   ✅ Viajes completados: {resultado[2]}")
    
    # 5. CREAR NOTIFICACIONES PENDIENTES
    print("\n" + "="*70)
    print("🔔 CREANDO NOTIFICACIONES DE PRUEBA")
    print("="*70)
    
    notificaciones = [
        {
            'tipo': 'recordatorio_pago',
            'asunto': 'Pago pendiente - San Andrés',
            'mensaje': 'Hola Jeyler, recuerda que tienes un saldo pendiente de $400 USD para tu viaje a San Andrés.',
            'programada': datetime.now() + timedelta(days=2)
        },
        {
            'tipo': 'confirmacion_vuelo',
            'asunto': 'Confirma tu vuelo a Miami',
            'mensaje': 'Tu vuelo a Miami sale en 30 días. ¿Todo listo para tu viaje?',
            'programada': datetime.now() + timedelta(days=28)
        }
    ]
    
    for notif in notificaciones:
        try:
            cur.execute("""
                INSERT INTO notificaciones (
                    id_cliente, tipo, asunto, mensaje, canal, 
                    destinatario, programada_para, prioridad
                ) VALUES (
                    %s, %s, %s, %s, 'telegram', %s, %s, 2
                )
            """, (
                'C-0036', notif['tipo'], notif['asunto'], notif['mensaje'],
                '1557475089', notif['programada']
            ))
            conn.commit()
            print(f"   ✅ {notif['tipo']}: {notif['asunto']}")
        except Exception as e:
            print(f"   ⚠️  Error: {e}")
            conn.rollback()
    
    # 6. RESUMEN FINAL
    print("\n" + "="*70)
    print("📊 RESUMEN DE DATOS DE PRUEBA CREADOS")
    print("="*70)
    
    # Contar todo
    cur.execute("SELECT COUNT(*) FROM reservas WHERE id_cliente = 'C-0036'")
    total_reservas = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM pagos p JOIN reservas r ON p.id_reserva = r.id_reserva WHERE r.id_cliente = 'C-0036'")
    total_pagos = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM conversaciones WHERE id_cliente = 'C-0036'")
    total_conversaciones = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM notificaciones WHERE id_cliente = 'C-0036'")
    total_notificaciones = cur.fetchone()[0]
    
    print(f"\n✅ Total de reservas: {total_reservas}")
    print(f"   - 1 confirmado (Miami)")
    print(f"   - 1 pendiente (Cartagena)")
    print(f"   - 1 cotización (Cancún)")
    print(f"   - 1 completado (Bogotá)")
    print(f"   - 1 pendiente_pago (San Andrés)")
    
    print(f"\n✅ Total de pagos: {total_pagos}")
    print(f"   - 2 completados")
    print(f"   - 1 pendiente")
    print(f"   - 1 parcial")
    
    print(f"\n✅ Total de conversaciones: {total_conversaciones}")
    print(f"\n✅ Total de notificaciones: {total_notificaciones}")
    
    print("\n" + "="*70)
    print("🎯 ESCENARIOS DE PRUEBA DISPONIBLES")
    print("="*70)
    
    print("""
    📋 Condicionales que puedes probar:

    1. ESTADO DE CONVERSACIÓN:
       ✓ estado_conversacion = 'menu_mostrado'
       - Probar cambiar a: 'viendo_reservas', 'buscando_vuelos', etc.

    2. TIPO DE CLIENTE:
       ✓ tipo_cliente = 'admin'
       - Mensajes especiales para admin

    3. ESTADOS DE RESERVAS:
       ✓ confirmado (Miami)
       ✓ pendiente (Cartagena)
       ✓ cotizacion (Cancún)
       ✓ completado (Bogotá)
       ✓ pendiente_pago (San Andrés)

    4. ESTADOS DE PAGOS:
       ✓ completado (2 pagos)
       ✓ pendiente (1 pago)
       ✓ parcial (1 pago - $400 de $800)

    5. TIPOS DE SERVICIO:
       ✓ vuelo (Miami, Bogotá)
       ✓ hotel (Cartagena)
       ✓ paquete (Cancún, San Andrés)

    6. HISTORIAL DE CONVERSACIÓN:
       ✓ 6 mensajes previos
       ✓ Mezcla de recibido/enviado
       ✓ Bot + Usuario

    7. NOTIFICACIONES PROGRAMADAS:
       ✓ Recordatorio de pago (en 2 días)
       ✓ Confirmación de vuelo (en 28 días)

    8. MÉTRICAS:
       ✓ total_gastado = $830 (solo confirmados)
       ✓ num_viajes = 1 (solo completados)
       ✓ telegram_id = 1557475089
    """)
    
    print("\n" + "="*70)
    print("💡 QUERIES ÚTILES PARA TU FLUJO N8N")
    print("="*70)
    
    print("""
    -- Buscar cliente por Telegram ID:
    SELECT * FROM clientes 
    WHERE telegram_id = '{{$json.message.chat.id}}'

    -- Ver reservas activas:
    SELECT * FROM reservas 
    WHERE id_cliente = '{{$json.id_cliente}}' 
    AND estado IN ('confirmado', 'pendiente', 'pendiente_pago')
    ORDER BY fecha_viaje

    -- Ver saldo pendiente:
    SELECT 
        r.id_reserva, r.destino, r.precio,
        COALESCE(SUM(p.monto), 0) as pagado,
        r.precio - COALESCE(SUM(p.monto), 0) as saldo
    FROM reservas r
    LEFT JOIN pagos p ON r.id_reserva = p.id_reserva
    WHERE r.id_cliente = '{{$json.id_cliente}}'
    GROUP BY r.id_reserva

    -- Actualizar estado de conversación:
    UPDATE clientes 
    SET estado_conversacion = 'viendo_reservas'
    WHERE telegram_id = '{{$json.message.chat.id}}'

    -- Registrar conversación:
    INSERT INTO conversaciones (id_cliente, canal, chat_id, mensaje, tipo, es_bot)
    VALUES ('{{$json.id_cliente}}', 'telegram', '{{$json.chat_id}}', 
            '{{$json.text}}', 'recibido', false)
    """)
    
    print("\n" + "="*70)
    print("🎉 DATOS DE PRUEBA CREADOS EXITOSAMENTE!")
    print("="*70)
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
    if 'conn' in locals():
        conn.rollback()
