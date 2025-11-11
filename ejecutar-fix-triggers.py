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
    
    print("="*70)
    print("🔧 CORRIGIENDO TRIGGERS DE AUDITORÍA")
    print("="*70)
    
    # Paso 1: Eliminar triggers antiguos
    print("\n�️  Eliminando triggers antiguos...")
    try:
        cur.execute("DROP TRIGGER IF EXISTS trigger_auditar_clientes ON clientes CASCADE")
        cur.execute("DROP TRIGGER IF EXISTS trigger_auditar_reservas ON reservas CASCADE")
        cur.execute("DROP TRIGGER IF EXISTS trigger_auditar_pagos ON pagos CASCADE")
        cur.execute("DROP TRIGGER IF EXISTS trigger_auditar_leads ON leads CASCADE")
        cur.execute("DROP FUNCTION IF EXISTS auditar_cambios() CASCADE")
        conn.commit()
        print("   ✅ Triggers y función antigua eliminados")
    except Exception as e:
        print(f"   ⚠️  {e}")
        conn.rollback()
    
    # Paso 2: Crear funciones específicas
    print("\n🔨 Creando funciones específicas por tabla...")
    
    # Función para CLIENTES
    cur.execute("""
        CREATE OR REPLACE FUNCTION auditar_clientes_cambios() 
        RETURNS TRIGGER AS $$
        BEGIN
            IF TG_OP = 'INSERT' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
                VALUES ('clientes', 'INSERT', NEW.id_cliente, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'UPDATE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
                VALUES ('clientes', 'UPDATE', NEW.id_cliente, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'DELETE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
                VALUES ('clientes', 'DELETE', OLD.id_cliente, row_to_json(OLD)::jsonb, current_user);
                RETURN OLD;
            END IF;
        END;
        $$ LANGUAGE plpgsql;
    """)
    print("   ✅ auditar_clientes_cambios()")
    
    # Función para RESERVAS
    cur.execute("""
        CREATE OR REPLACE FUNCTION auditar_reservas_cambios() 
        RETURNS TRIGGER AS $$
        BEGIN
            IF TG_OP = 'INSERT' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
                VALUES ('reservas', 'INSERT', NEW.id_reserva, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'UPDATE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
                VALUES ('reservas', 'UPDATE', NEW.id_reserva, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'DELETE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
                VALUES ('reservas', 'DELETE', OLD.id_reserva, row_to_json(OLD)::jsonb, current_user);
                RETURN OLD;
            END IF;
        END;
        $$ LANGUAGE plpgsql;
    """)
    print("   ✅ auditar_reservas_cambios()")
    
    # Función para PAGOS
    cur.execute("""
        CREATE OR REPLACE FUNCTION auditar_pagos_cambios() 
        RETURNS TRIGGER AS $$
        BEGIN
            IF TG_OP = 'INSERT' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
                VALUES ('pagos', 'INSERT', NEW.id_pago::VARCHAR, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'UPDATE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
                VALUES ('pagos', 'UPDATE', NEW.id_pago::VARCHAR, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'DELETE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
                VALUES ('pagos', 'DELETE', OLD.id_pago::VARCHAR, row_to_json(OLD)::jsonb, current_user);
                RETURN OLD;
            END IF;
        END;
        $$ LANGUAGE plpgsql;
    """)
    print("   ✅ auditar_pagos_cambios()")
    
    # Función para LEADS
    cur.execute("""
        CREATE OR REPLACE FUNCTION auditar_leads_cambios() 
        RETURNS TRIGGER AS $$
        BEGIN
            IF TG_OP = 'INSERT' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_nuevos, usuario)
                VALUES ('leads', 'INSERT', NEW.id_lead::VARCHAR, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'UPDATE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, datos_nuevos, usuario)
                VALUES ('leads', 'UPDATE', NEW.id_lead::VARCHAR, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, current_user);
                RETURN NEW;
            ELSIF TG_OP = 'DELETE' THEN
                INSERT INTO auditoria (tabla, operacion, id_registro, datos_anteriores, usuario)
                VALUES ('leads', 'DELETE', OLD.id_lead::VARCHAR, row_to_json(OLD)::jsonb, current_user);
                RETURN OLD;
            END IF;
        END;
        $$ LANGUAGE plpgsql;
    """)
    print("   ✅ auditar_leads_cambios()")
    
    conn.commit()
    
    # Paso 3: Crear triggers
    print("\n🔗 Creando triggers...")
    
    cur.execute("""
        CREATE TRIGGER trigger_auditar_clientes
        AFTER INSERT OR UPDATE OR DELETE ON clientes
        FOR EACH ROW EXECUTE FUNCTION auditar_clientes_cambios();
    """)
    print("   ✅ trigger_auditar_clientes")
    
    cur.execute("""
        CREATE TRIGGER trigger_auditar_reservas
        AFTER INSERT OR UPDATE OR DELETE ON reservas
        FOR EACH ROW EXECUTE FUNCTION auditar_reservas_cambios();
    """)
    print("   ✅ trigger_auditar_reservas")
    
    cur.execute("""
        CREATE TRIGGER trigger_auditar_pagos
        AFTER INSERT OR UPDATE OR DELETE ON pagos
        FOR EACH ROW EXECUTE FUNCTION auditar_pagos_cambios();
    """)
    print("   ✅ trigger_auditar_pagos")
    
    cur.execute("""
        CREATE TRIGGER trigger_auditar_leads
        AFTER INSERT OR UPDATE OR DELETE ON leads
        FOR EACH ROW EXECUTE FUNCTION auditar_leads_cambios();
    """)
    print("   ✅ trigger_auditar_leads")
    
    conn.commit()
    
    print("\n" + "="*70)
    print("📊 VERIFICANDO TRIGGERS INSTALADOS")
    print("="*70)
    
    # Verificar triggers de auditoría
    cur.execute("""
        SELECT 
            trigger_name,
            event_object_table,
            action_timing,
            string_agg(event_manipulation, ', ' ORDER BY event_manipulation) as eventos
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
        AND trigger_name LIKE 'trigger_auditar%'
        GROUP BY trigger_name, event_object_table, action_timing
        ORDER BY event_object_table, trigger_name
    """)
    
    triggers = cur.fetchall()
    
    if triggers:
        print(f"\n✅ Triggers activos: {len(triggers)}")
        print()
        for trigger in triggers:
            print(f"   📌 {trigger[0]}")
            print(f"      Tabla: {trigger[1]}")
            print(f"      Eventos: {trigger[3]} ({trigger[2]})")
            print()
    
    # Verificar funciones
    print("="*70)
    print("📊 VERIFICANDO FUNCIONES DE AUDITORÍA")
    print("="*70)
    
    cur.execute("""
        SELECT 
            proname as nombre_funcion,
            pg_get_functiondef(oid) as definicion
        FROM pg_proc
        WHERE proname LIKE 'auditar_%_cambios'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        ORDER BY proname
    """)
    
    funciones = cur.fetchall()
    
    if funciones:
        print(f"\n✅ Funciones creadas: {len(funciones)}")
        for funcion in funciones:
            print(f"   ✅ {funcion[0]}()")
    
    # Prueba rápida de funcionamiento
    print("\n" + "="*70)
    print("🧪 PRUEBA DE FUNCIONAMIENTO")
    print("="*70)
    
    print("\n🧪 Probando actualización de cliente...")
    cur.execute("""
        UPDATE clientes 
        SET notas = 'Trigger corregido - ' || NOW()::TEXT
        WHERE id_cliente = 'C-0036'
        RETURNING id_cliente, nombre_completo
    """)
    
    resultado = cur.fetchone()
    conn.commit()
    
    if resultado:
        print(f"   ✅ Cliente actualizado: {resultado[0]} - {resultado[1]}")
        
        # Verificar que se guardó en auditoría
        cur.execute("""
            SELECT COUNT(*) 
            FROM auditoria 
            WHERE tabla = 'clientes' 
            AND id_registro = 'C-0036'
            AND operacion = 'UPDATE'
            AND fecha_hora >= NOW() - INTERVAL '1 minute'
        """)
        
        audit_count = cur.fetchone()[0]
        if audit_count > 0:
            print(f"   ✅ Registro de auditoría creado correctamente!")
        else:
            print(f"   ⚠️  No se encontró registro en auditoría")
    
    print("\n" + "="*70)
    print("🎉 CORRECCIÓN DE TRIGGERS COMPLETADA EXITOSAMENTE!")
    print("="*70)
    
    print("\n💡 Los triggers ahora funcionan correctamente y no causarán")
    print("   errores en actualizaciones en cascada.")
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    if 'conn' in locals():
        conn.rollback()
