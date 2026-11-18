const path = require('node:path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const express = require('express');
const mysql = require('mysql2/promise');

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
app.use(require('./cors-local'));
app.use(express.json({ limit: '16kb' }));

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 5,
  timezone: 'Z',
});

app.get('/categorias', async (req, res) => {
  try {
    const [categorias] = await pool.execute(
      'SELECT id, nombre FROM categorias ORDER BY id'
    );
    res.json(categorias);
  } catch (error) {
    console.error('Error consultando categorías:', error.code);
    res.status(500).json({ error: 'No se pudieron consultar las categorías' });
  }
});

app.post('/auth/registro', async (req, res) => {
  const { email, password, alias, carrera } = req.body ?? {};

  if (
    typeof email !== 'string' ||
    typeof password !== 'string' ||
    typeof alias !== 'string' ||
    typeof carrera !== 'string'
  ) {
    return res.status(400).json({
      error: 'Completa correo, contraseña, alias y carrera',
    });
  }

  const correo = email.trim().toLowerCase();
  const nombre = alias.trim();
  const carreraLimpia = carrera.trim();

  if (
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo) ||
    correo.length > 254 ||
    password.length < 8 ||
    Buffer.byteLength(password, 'utf8') > 72 ||
    nombre.length === 0 ||
    nombre.length > 100 ||
    carreraLimpia.length === 0 ||
    carreraLimpia.length > 150
  ) {
    return res.status(400).json({
      error: 'Revisa los datos: usa una contraseña de al menos 8 caracteres, alias y carrera.',
    });
  }

  try {
    const hash = await bcrypt.hash(password, 12);

    await pool.execute(
      `INSERT INTO usuarios
       (nombre, correo, password_hash, carrera)
       VALUES (?, ?, ?, ?)`,
      [nombre, correo, hash, carreraLimpia]
    );

    return res.status(201).json({
      mensaje: 'Cuenta creada correctamente',
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        error: 'Ese correo ya está registrado',
      });
    }

    console.error('Error registrando usuario:', error.code);
    return res.status(500).json({
      error: 'No se pudo crear la cuenta',
    });
  }
});

app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body ?? {};

  if (
    typeof email !== 'string' ||
    typeof password !== 'string' ||
    email.trim().length > 254 ||
    password.length === 0 ||
    Buffer.byteLength(password, 'utf8') > 72
  ) {
    return res.status(400).json({
      error: 'Revisa el correo y la contraseña',
    });
  }

  if (!process.env.JWT_SECRET) {
    return res.status(500).json({
      error: 'Falta configurar la clave de sesión del servidor',
    });
  }

  try {
    const [usuarios] = await pool.execute(
      `SELECT id, nombre, correo, carrera, password_hash
       FROM usuarios WHERE correo = ? LIMIT 1`,
      [email.trim().toLowerCase()]
    );

    const usuario = usuarios[0];

    if (
      !usuario ||
      !(await bcrypt.compare(password, usuario.password_hash))
    ) {
      return res.status(401).json({
        error: 'Correo o contraseña incorrectos',
      });
    }

    const token = jwt.sign(
      {},
      process.env.JWT_SECRET,
      {
        subject: String(usuario.id),
        expiresIn: '2h',
        algorithm: 'HS256',
      }
    );

    return res.json({
      token,
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        correo: usuario.correo,
        carrera: usuario.carrera,
      },
    });
  } catch (error) {
    console.error('Error iniciando sesión:', error.code || error.name);
    return res.status(500).json({
      error: 'No se pudo iniciar sesión',
    });
  }
});

function verificarSesion(req, res, next) {
  const autorizacion = req.headers.authorization;

  if (
    typeof autorizacion !== 'string' ||
    !autorizacion.startsWith('Bearer ')
  ) {
    return res.status(401).json({
      error: 'Debes iniciar sesión',
    });
  }

  try {
    const token = autorizacion.slice(7);

    const sesion = jwt.verify(token, process.env.JWT_SECRET, {
      algorithms: ['HS256'],
    });

    if (
      typeof sesion !== 'object' ||
      typeof sesion.sub !== 'string' ||
      !/^[1-9]\d*$/.test(sesion.sub)
    ) {
      return res.status(401).json({
        error: 'Sesión inválida',
      });
    }

    req.usuarioId = sesion.sub;
    next();
  } catch {
    return res.status(401).json({
      error: 'Tu sesión expiró o es inválida. Inicia sesión nuevamente.',
    });
  }
}

app.post('/eventos', verificarSesion, async (req, res) => {
  const {
    nombre, ubicacion, categoria, dificultad,
    fechaHora, cupoMaximo, descripcion,
  } = req.body ?? {};

  if (
    typeof nombre !== 'string' ||
    typeof ubicacion !== 'string' ||
    typeof categoria !== 'string' ||
    typeof descripcion !== 'string' ||
    typeof fechaHora !== 'string' ||
    !['Casual', 'Intermedio', 'Avanzado'].includes(dificultad) ||
    !Number.isInteger(cupoMaximo) ||
    cupoMaximo < 1 ||
    cupoMaximo > 4294967295
  ) {
    return res.status(400).json({
      error: 'Revisa los campos y utiliza un cupo mayor que cero',
    });
  }

  const fecha = new Date(fechaHora);

  if (
    nombre.trim().length === 0 ||
    nombre.trim().length > 150 ||
    ubicacion.trim().length === 0 ||
    ubicacion.trim().length > 255 ||
    categoria.trim().length === 0 ||
    Buffer.byteLength(descripcion, 'utf8') > 65535 ||
    !/(Z|[+-]\d{2}:\d{2})$/.test(fechaHora) ||
    !Number.isFinite(fecha.getTime()) ||
    fecha.getTime() <= Date.now() ||
    fecha.getUTCFullYear() > 9999
  ) {
    return res.status(400).json({
      error: 'Revisa nombre, ubicación y fecha. El evento debe ser futuro.',
    });
  }

  let conexion;

  try {
    conexion = await pool.getConnection();

    const [categorias] = await conexion.execute(
      'SELECT id FROM categorias WHERE nombre = ?',
      [categoria.trim()]
    );

    if (categorias.length === 0) {
      return res.status(400).json({
        error: 'La categoría no existe',
      });
    }

    await conexion.beginTransaction();

    const [publicacion] = await conexion.execute(
      `INSERT INTO publicaciones
       (usuario_id, categoria_id, titulo, descripcion)
       VALUES (?, ?, ?, ?)`,
      [
        req.usuarioId,
        categorias[0].id,
        nombre.trim(),
        descripcion.trim(),
      ]
    );

    const fechaUTC = fecha.toISOString()
        .slice(0, 19)
        .replace('T', ' ');

    const [evento] = await conexion.execute(
      `INSERT INTO eventos
       (publicacion_id, ubicacion, fecha_hora, dificultad, cupo_maximo)
       VALUES (?, ?, ?, ?, ?)`,
      [
        publicacion.insertId,
        ubicacion.trim(),
        fechaUTC,
        dificultad,
        cupoMaximo,
      ]
    );

    await conexion.commit();

    return res.status(201).json({
      mensaje: 'Evento guardado correctamente',
      eventoId: evento.insertId,
      publicacionId: publicacion.insertId,
    });
  } catch (error) {
    if (conexion) {
      try {
        await conexion.rollback();
      } catch {
        console.error('No se pudo deshacer la operación');
      }
    }

    console.error('Error guardando evento:', error.code || error.name);

    return res.status(500).json({
      error: 'No se pudo guardar el evento',
    });
  } finally {
    if (conexion) conexion.release();
  }
});

app.get('/feed', verificarSesion, async (req, res) => {
  try {
    const [items] = await pool.execute(`
      SELECT
        p.id,
        p.titulo,
        p.descripcion,
        c.nombre AS categoria,
        u.nombre AS autor,
        p.creado_en AS fecha,
        CASE
          WHEN e.id IS NULL THEN 'publicacion'
          ELSE 'evento'
        END AS tipo,
        DATE_FORMAT(
          e.fecha_hora, '%Y-%m-%dT%H:%i:%sZ'
        ) AS fechaEvento,
        e.ubicacion
      FROM publicaciones p
      JOIN categorias c ON c.id = p.categoria_id
      JOIN usuarios u ON u.id = p.usuario_id
      LEFT JOIN eventos e ON e.publicacion_id = p.id
      ORDER BY p.creado_en DESC, p.id DESC
      LIMIT 100
    `);

    res.json(items);
  } catch (error) {
    console.error('Error consultando feed:', error.code || error.name);
    res.status(500).json({
      error: 'No se pudieron cargar las publicaciones',
    });
  }
});

async function iniciar() {
  try {
    await pool.query('SELECT 1');
    const puerto = Number(process.env.PORT || 3000);

    const servidor = app.listen(puerto, '127.0.0.1', () => {
      console.log(`API lista en http://127.0.0.1:${puerto}`);
      console.log('Conexión con MySQL correcta');
    });

    servidor.on('error', (error) => {
      console.error('No se pudo iniciar la API:', error.code);
      process.exit(1);
    });
  } catch (error) {
    console.error('No se pudo conectar con MySQL:', error.code);
    await pool.end();
    process.exit(1);
  }
}

iniciar();
