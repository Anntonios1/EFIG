// Script para ejecutar upgrade de database
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Configuración de conexión
const pool = new Pool({
    host: '34.66.86.207',
    port: 5433,
    database: 'n8n_db',
    user: 'n8n',
    password: 'Ef1g2025*'
});

async function executeUpgrade() {
    const client = await pool.connect();
    
    try {
        console.log('🔗 Conectado a PostgreSQL en Google Cloud');
        console.log('📂 Leyendo script SQL...\n');
        
        // Leer el script SQL
        const sqlScript = fs.readFileSync(path.join(__dirname, 'upgrade-database.sql'), 'utf8');
        
        console.log('⚡ Ejecutando script de upgrade...\n');
        console.log('=' .repeat(60));
        
        // Ejecutar el script completo
        await client.query(sqlScript);
        
        console.log('=' .repeat(60));
        console.log('\n✅ Script ejecutado exitosamente!\n');
        
        // Verificar tablas creadas
        console.log('📊 Verificando tablas creadas...\n');
        
        const result = await client.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
              AND table_name IN ('auditoria', 'conversaciones', 'leads', 'notificaciones', 
                                 'promociones', 'uso_promociones', 'documentos', 
                                 'metricas_diarias', 'integraciones')
            ORDER BY table_name
        `);
        
        console.log('✅ Tablas nuevas creadas:');
        result.rows.forEach((row, i) => {
            console.log(`   ${i + 1}. ${row.table_name}`);
        });
        
        // Verificar triggers
        const triggers = await client.query(`
            SELECT trigger_name, event_object_table
            FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            ORDER BY event_object_table, trigger_name
        `);
        
        console.log(`\n✅ Triggers creados: ${triggers.rows.length}`);
        triggers.rows.forEach((row, i) => {
            console.log(`   ${i + 1}. ${row.trigger_name} → ${row.event_object_table}`);
        });
        
        // Verificar vistas
        const views = await client.query(`
            SELECT table_name
            FROM information_schema.views
            WHERE table_schema = 'public'
            ORDER BY table_name
        `);
        
        console.log(`\n✅ Vistas creadas: ${views.rows.length}`);
        views.rows.forEach((row, i) => {
            console.log(`   ${i + 1}. ${row.table_name}`);
        });
        
        // Verificar columnas agregadas a clientes
        const clientesColumns = await client.query(`
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'clientes'
            ORDER BY ordinal_position
        `);
        
        console.log(`\n✅ Columnas en tabla 'clientes': ${clientesColumns.rows.length}`);
        
        // Verificar promociones insertadas
        const promociones = await client.query('SELECT codigo, descripcion FROM promociones');
        console.log(`\n✅ Promociones disponibles: ${promociones.rows.length}`);
        promociones.rows.forEach((row, i) => {
            console.log(`   ${i + 1}. ${row.codigo} - ${row.descripcion}`);
        });
        
        console.log('\n' + '='.repeat(60));
        console.log('🎉 DATABASE UPGRADE COMPLETADO EXITOSAMENTE! 🎉');
        console.log('='.repeat(60));
        
    } catch (error) {
        console.error('\n❌ Error ejecutando upgrade:', error.message);
        console.error('\n📍 Detalles del error:');
        console.error(error);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}

// Ejecutar
executeUpgrade().catch(err => {
    console.error('Error fatal:', err);
    process.exit(1);
});
