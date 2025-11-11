// Prueba de conectividad PostgreSQL
const { Client } = require('pg');

const client = new Client({
  host: '34.66.86.207',
  port: 5433,
  database: 'n8n_db',
  user: 'n8n_user',
  password: 'n8npass',
  ssl: false
});

async function testConnection() {
  try {
    console.log('🔌 Intentando conectar a PostgreSQL...');
    await client.connect();
    console.log('✅ Conexión exitosa!');
    
    console.log('📊 Probando consulta...');
    const result = await client.query('SELECT version();');
    console.log('🏷️ Versión PostgreSQL:', result.rows[0].version);
    
    console.log('📋 Listando tablas...');
    const tables = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public';
    `);
    console.log('🔢 Tablas encontradas:', tables.rows.length);
    
    tables.rows.forEach(row => {
      console.log('  - ' + row.table_name);
    });
    
  } catch (error) {
    console.error('❌ Error de conexión:', error.message);
    console.error('🔍 Código de error:', error.code);
  } finally {
    await client.end();
  }
}

testConnection();