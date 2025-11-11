const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Configuración de PostgreSQL
const pool = new Pool({
  host: '34.66.86.207',
  port: 5433,
  database: 'n8n_db',
  user: 'n8n',
  password: 'n8npass'
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ==================== MODELOS AI ====================

// Listar modelos disponibles
app.get('/models', (req, res) => {
  const workingModels = [
    { id: "gpt-4o-2024-11-20", name: "GPT-4 Omni" },
    { id: "gpt-4", name: "GPT-4 2025" },
    { id: "gpt-5-mini", name: "GPT-5 Mini" },
    { id: "gpt-4.1-2025-04-14", name: "GPT-4.1" }
  ];
  
  res.json({ 
    success: true, 
    data: workingModels,
    count: workingModels.length 
  });
});

// ==================== CLIENTES ====================

// Obtener todos los clientes
app.get('/clientes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM clientes ORDER BY id DESC');
    res.json({ success: true, data: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Obtener un cliente por id_cliente
app.get('/clientes/:id_cliente', async (req, res) => {
  try {
    const { id_cliente } = req.params;
    const result = await pool.query('SELECT * FROM clientes WHERE id_cliente = $1', [id_cliente]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Cliente no encontrado' });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Crear un cliente
app.post('/clientes', async (req, res) => {
  try {
    const { nombre_completo, email, telefono, documento, tipo_cliente } = req.body;
    
    if (!nombre_completo || !email || !telefono) {
      return res.status(400).json({ 
        success: false, 
        error: 'Faltan campos requeridos: nombre_completo, email, telefono' 
      });
    }

    const query = `
      INSERT INTO clientes (nombre_completo, email, telefono, documento, tipo_cliente)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;
    
    const values = [
      nombre_completo,
      email,
      telefono,
      documento || null,
      tipo_cliente || 'nuevo'
    ];

    const result = await pool.query(query, values);
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Actualizar un cliente
app.put('/clientes/:id_cliente', async (req, res) => {
  try {
    const { id_cliente } = req.params;
    const { nombre_completo, email, telefono, documento, tipo_cliente } = req.body;

    const query = `
      UPDATE clientes 
      SET nombre_completo = COALESCE($1, nombre_completo),
          email = COALESCE($2, email),
          telefono = COALESCE($3, telefono),
          documento = COALESCE($4, documento),
          tipo_cliente = COALESCE($5, tipo_cliente)
      WHERE id_cliente = $6
      RETURNING *
    `;

    const values = [nombre_completo, email, telefono, documento, tipo_cliente, id_cliente];
    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Cliente no encontrado' });
    }

    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== RESERVAS ====================

// Obtener todas las reservas
app.get('/reservas', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM reservas ORDER BY id DESC');
    res.json({ success: true, data: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Obtener reservas de un cliente
app.get('/reservas/cliente/:id_cliente', async (req, res) => {
  try {
    const { id_cliente } = req.params;
    const result = await pool.query('SELECT * FROM reservas WHERE id_cliente = $1 ORDER BY id DESC', [id_cliente]);
    res.json({ success: true, data: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Crear una reserva
app.post('/reservas', async (req, res) => {
  try {
    const { id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, precio, notas } = req.body;

    if (!id_cliente || !destino || !fecha_salida || !precio) {
      return res.status(400).json({ 
        success: false, 
        error: 'Faltan campos requeridos: id_cliente, destino, fecha_salida, precio' 
      });
    }

    const query = `
      INSERT INTO reservas (id_cliente, tipo, origen, destino, fecha_salida, fecha_regreso, precio, estado, notas)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `;

    const values = [
      id_cliente,
      tipo || 'vuelo',
      origen || null,
      destino,
      fecha_salida,
      fecha_regreso || null,
      parseFloat(precio),
      'pendiente',
      notas || null
    ];

    const result = await pool.query(query, values);
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Actualizar estado de reserva
app.patch('/reservas/:id_reserva/estado', async (req, res) => {
  try {
    const { id_reserva } = req.params;
    const { estado } = req.body;

    if (!['pendiente', 'confirmada', 'cancelada', 'completada'].includes(estado)) {
      return res.status(400).json({ 
        success: false, 
        error: 'Estado inválido. Valores permitidos: pendiente, confirmada, cancelada, completada' 
      });
    }

    const result = await pool.query(
      'UPDATE reservas SET estado = $1 WHERE id_reserva = $2 RETURNING *',
      [estado, id_reserva]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Reserva no encontrada' });
    }

    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== PAGOS ====================

// Obtener todos los pagos
app.get('/pagos', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM pagos ORDER BY id DESC');
    res.json({ success: true, data: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Obtener pagos de una reserva
app.get('/pagos/reserva/:id_reserva', async (req, res) => {
  try {
    const { id_reserva } = req.params;
    const result = await pool.query('SELECT * FROM pagos WHERE id_reserva = $1 ORDER BY id DESC', [id_reserva]);
    res.json({ success: true, data: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Crear un pago
app.post('/pagos', async (req, res) => {
  try {
    const { id_reserva, monto, metodo, estado } = req.body;

    if (!id_reserva || !monto || !metodo) {
      return res.status(400).json({ 
        success: false, 
        error: 'Faltan campos requeridos: id_reserva, monto, metodo' 
      });
    }

    const query = `
      INSERT INTO pagos (id_reserva, monto, metodo, estado)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;

    const values = [
      id_reserva,
      parseFloat(monto),
      metodo,
      estado || 'completado'
    ];

    const result = await pool.query(query, values);
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Actualizar estado de pago
app.patch('/pagos/:id_pago/estado', async (req, res) => {
  try {
    const { id_pago } = req.params;
    const { estado } = req.body;

    if (!['pendiente', 'completado', 'fallido', 'reembolsado'].includes(estado)) {
      return res.status(400).json({ 
        success: false, 
        error: 'Estado inválido. Valores permitidos: pendiente, completado, fallido, reembolsado' 
      });
    }

    const result = await pool.query(
      'UPDATE pagos SET estado = $1 WHERE id_pago = $2 RETURNING *',
      [estado, id_pago]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Pago no encontrado' });
    }

    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Manejo de errores 404
app.use((req, res) => {
  res.status(404).json({ success: false, error: 'Endpoint no encontrado' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 API Server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🤖 AI Models: http://localhost:${PORT}/models`);
  console.log(`\n📋 Endpoints disponibles:`);
  console.log(`  GET    /models         - Listar modelos AI`);
  console.log(`  GET    /clientes       - Listar clientes`);
  console.log(`  POST   /clientes       - Crear cliente`);
  console.log(`  GET    /reservas       - Listar reservas`);
  console.log(`  POST   /reservas       - Crear reserva`);
  console.log(`  GET    /pagos          - Listar pagos`);
  console.log(`  POST   /pagos          - Crear pago`);
});
