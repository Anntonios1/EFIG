import psycopg2
import sys

print("🔗 Conectando a PostgreSQL en Google Cloud...")

try:
    # Conectar a la base de datos
    conn = psycopg2.connect(
        host="34.66.86.207",
        port=5433,
        database="n8n_db",
        user="n8n",
        password="n8npass"
    )
    
    cur = conn.cursor()
    
    print("✅ Conexión establecida")
    print("📂 Leyendo script SQL...\n")
    
    # Leer el script SQL
    with open('upgrade-database.sql', 'r', encoding='utf-8') as f:
        sql_script = f.read()
    
    print("⚡ Ejecutando script de upgrade...")
    print("=" * 60)
    
    # Ejecutar el script
    cur.execute(sql_script)
    conn.commit()
    
    print("=" * 60)
    print("\n✅ Script ejecutado exitosamente!\n")
    
    # Verificar tablas creadas
    print("📊 Verificando tablas creadas...\n")
    
    cur.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_name IN ('auditoria', 'conversaciones', 'leads', 'notificaciones', 
                             'promociones', 'uso_promociones', 'documentos', 
                             'metricas_diarias', 'integraciones')
        ORDER BY table_name
    """)
    
    tables = cur.fetchall()
    print(f"✅ Tablas nuevas creadas: {len(tables)}")
    for i, (table,) in enumerate(tables, 1):
        print(f"   {i}. {table}")
    
    # Verificar triggers
    cur.execute("""
        SELECT trigger_name, event_object_table
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
        ORDER BY event_object_table, trigger_name
    """)
    
    triggers = cur.fetchall()
    print(f"\n✅ Triggers creados: {len(triggers)}")
    for i, (trigger, table) in enumerate(triggers[:10], 1):  # Mostrar solo primeros 10
        print(f"   {i}. {trigger} → {table}")
    if len(triggers) > 10:
        print(f"   ... y {len(triggers) - 10} más")
    
    # Verificar vistas
    cur.execute("""
        SELECT table_name
        FROM information_schema.views
        WHERE table_schema = 'public'
        ORDER BY table_name
    """)
    
    views = cur.fetchall()
    print(f"\n✅ Vistas creadas: {len(views)}")
    for i, (view,) in enumerate(views, 1):
        print(f"   {i}. {view}")
    
    # Verificar promociones
    cur.execute("SELECT codigo, descripcion FROM promociones")
    promociones = cur.fetchall()
    print(f"\n✅ Promociones disponibles: {len(promociones)}")
    for i, (codigo, desc) in enumerate(promociones, 1):
        print(f"   {i}. {codigo} - {desc}")
    
    # Verificar columnas en clientes
    cur.execute("""
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'clientes'
        ORDER BY ordinal_position
    """)
    
    columns = cur.fetchall()
    print(f"\n✅ Columnas en tabla 'clientes': {len(columns)}")
    
    print("\n" + "=" * 60)
    print("🎉 DATABASE UPGRADE COMPLETADO EXITOSAMENTE! 🎉")
    print("=" * 60)
    
    cur.close()
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    sys.exit(1)
