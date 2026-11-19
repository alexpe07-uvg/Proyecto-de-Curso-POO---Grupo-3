// Manejo de categorías, creación de eventos, feed principal y eliminación de eventos.
const { consultarInteracciones, limpiarInteraccionesEvento } = require('./server.interacciones');

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
      nombre,
      ubicacion,
      categoria,
      dificultad,
      fechaHora,
      cupoMaximo,
      descripcion,
    } = req.body ?? {};

    if (
      typeof nombre !== 'string' ||
      typeof ubicacion !== 'string' ||
      typeof categoria !== 'string' ||
      typeof descripcion !== 'string' ||
      typeof fechaHora !== 'string' ||
      !['Casual', 'Intermedio', 'Avanzado'].includes(dificultad) ||
      !Number.isInteger(cupoMaximo) ||
      cupoMaximo < 1
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
          u.foto_url AS autorFotoUrl,
          p.creado_en AS fecha,
          CASE
            WHEN e.id IS NULL THEN 'publicacion'
            ELSE 'evento'
          END AS tipo,
          DATE_FORMAT(
            e.fecha_hora, '%Y-%m-%dT%H:%i:%sZ'
          ) AS fechaEvento,
          e.ubicacion,
          e.dificultad,
          (p.usuario_id = ?) AS esCreador,
          e.cupo_maximo AS cupoMaximo
        FROM publicaciones p
        JOIN categorias c ON c.id = p.categoria_id
        JOIN usuarios u ON u.id = p.usuario_id
        LEFT JOIN eventos e ON e.publicacion_id = p.id

        -- Solo eventos futuros se muestran en el feed, los expirados se ocultan
        WHERE e.id IS NULL OR e.fecha_hora >= UTC_TIMESTAMP()
        ORDER BY p.creado_en DESC, p.id DESC
        LIMIT 100
      `, [req.usuarioId]);

      const { inscripcionesPorPub, comentariosPorPub } = await consultarInteracciones(
        pool,
        req.usuarioId
      );

      const enriquecidos = items.map((item) => {
        const pid = String(item.id);
        const infoInsc = inscripcionesPorPub.get(pid) || {
          cupoOcupado: 0,
          inscrito: false,
          inscritosNombres: [],
        };
        return {
          ...item,
          cupoOcupado: infoInsc.cupoOcupado,
          inscrito: infoInsc.inscrito,
          inscritosNombres: infoInsc.inscritosNombres,
          comentarios: comentariosPorPub.get(pid) || [],
        };
      });

      res.json(enriquecidos);
    } catch (error) {
      console.error('Error consultando feed:', error.code || error.name);
      res.status(500).json({
        error: 'No se pudieron cargar las publicaciones',
      });
    }
  });

  app.delete('/eventos/:id', verificarSesion, async (req, res) => {
    const publicacionId = Number(req.params.id);
    if (!Number.isInteger(publicacionId) || publicacionId < 1) {
      return res.status(400).json({ error: 'Identificador de evento inválido' });
    }
    let conexion;
    try {
      conexion = await pool.getConnection();
      const [filas] = await conexion.execute(
        `SELECT p.id
         FROM publicaciones p
         INNER JOIN eventos e ON e.publicacion_id = p.id
         WHERE p.id = ? AND p.usuario_id = ?
         LIMIT 1`,
        [publicacionId, req.usuarioId]
      );
      if (filas.length === 0) {
        return res.status(404).json({ error: 'El evento no existe o no eres su creador' });
      }
      await conexion.beginTransaction();
      
      // Limpiar inscripciones y comentarios asociados
      await limpiarInteraccionesEvento(pool, publicacionId, conexion);

      await conexion.execute('DELETE FROM eventos WHERE publicacion_id = ?', [publicacionId]);
      await conexion.execute('DELETE FROM publicaciones WHERE id = ? AND usuario_id = ?', [publicacionId, req.usuarioId]);
      await conexion.commit();

      return res.json({ mensaje: 'Evento eliminado correctamente' });
    } catch (error) {
      if (conexion) {
        try {
          await conexion.rollback();
        } catch {}
      }
      console.error('Error eliminando evento:', error.code || error.name);
      return res.status(500).json({ error: 'No se pudo eliminar el evento' });
    } finally {
      if (conexion) conexion.release();
    }
  });
}

module.exports = { registrarCategorias, registrarContenido };
