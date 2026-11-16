// Categorías, creación de eventos y feed.
function registrarCategorias(app, pool) {
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
}

function registrarContenido(app, pool, verificarSesion) {
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
          e.ubicacion,
          e.cupo_maximo AS cupoMaximo
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
}

module.exports = { registrarCategorias, registrarContenido };
