const path = require('node:path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const express = require('express');
const cors = require('cors');
const pool = require('./server.db');
const { registrarAuth, verificarSesion } = require('./server.auth');
const { registrarCategorias, registrarContenido } = require('./server.contenido');

const app = express();
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'ngrok-skip-browser-warning'],
}));

app.use((req, res, next) => {
  res.setHeader('ngrok-skip-browser-warning', 'true');
  next();
});

app.use(express.json({ limit: '16kb' }));

registrarCategorias(app, pool);
registrarAuth(app, pool);

require('../perfil').registrarPerfil(app, pool, verificarSesion, express,
  path.resolve(process.env.PROFILE_UPLOAD_DIR || path.join(__dirname, '..', 'uploads', 'perfiles')));
  console.log('Rutas de perfil registradas exitosamente');
  
app.use((error, req, res, next) => {
  if (error.type === 'entity.too.large') return res.status(413).json({ error: 'La imagen no puede superar 5 MB' });
  if (error.type === 'entity.parse.failed') return res.status(400).json({ error: 'Datos inválidos' });
  next(error);
});


registrarContenido(app, pool, verificarSesion);

async function iniciar() {
  try {
    await pool.query('SELECT 1');
    const PORT = Number(process.env.PORT || 3000);

    const servidor = app.listen(PORT, '0.0.0.0', () => {
      console.log(`API lista en http://127.0.0.1:${PORT}`);
      console.log('Conexión con MySQL correcta');
    });

    servidor.on('error', (error) => {
      console.error('No se pudo iniciar la API:', error.code);
      process.exit(1);
    });
  } catch (error) {
    console.error('No se pudo conectar con MySQL:', error);
    await pool.end();
    process.exit(1);
  }
}

iniciar();
