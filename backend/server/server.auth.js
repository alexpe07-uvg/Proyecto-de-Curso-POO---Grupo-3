// Registro, inicio de sesión y validación de JWT.
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

function registrarAuth(app, pool) {
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
}

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

module.exports = { registrarAuth, verificarSesion };
