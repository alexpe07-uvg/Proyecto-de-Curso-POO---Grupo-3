// Categorías, creación de eventos y feed.
const fs = require('node:fs/promises');
const path = require('node:path');

const archivoRespaldo = path.join(__dirname, '..', 'uploads', 'interacciones.json');
let modoTablaMySQL = null;

async function asegurarTablas(pool) {
  if (modoTablaMySQL !== null) return modoTablaMySQL;
  try {
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS inscripciones (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        publicacion_id BIGINT UNSIGNED NOT NULL,
        usuario_id BIGINT UNSIGNED NOT NULL,
        creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT uq_inscripciones_evento_usuario UNIQUE(publicacion_id, usuario_id),
        FOREIGN KEY(publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
      ) ENGINE=InnoDB
    `);
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS comentarios (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        publicacion_id BIGINT UNSIGNED NOT NULL,
        usuario_id BIGINT UNSIGNED NOT NULL,
        padre_id BIGINT UNSIGNED NULL,
        texto TEXT NOT NULL,
        creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY(padre_id) REFERENCES comentarios(id) ON DELETE CASCADE
      ) ENGINE=InnoDB
    `);
    modoTablaMySQL = true;
  } catch {
    try {
      await pool.execute('SELECT 1 FROM inscripciones LIMIT 1');
      await pool.execute('SELECT 1 FROM comentarios LIMIT 1');
      modoTablaMySQL = true;
    } catch {
      modoTablaMySQL = false;
    }
  }
  return modoTablaMySQL;
}

async function leerRespaldo() {
  try {
    const contenido = await fs.readFile(archivoRespaldo, 'utf8');
    const datos = JSON.parse(contenido);
    return {
      inscripciones: Array.isArray(datos.inscripciones) ? datos.inscripciones : [],
      comentarios: Array.isArray(datos.comentarios) ? datos.comentarios : [],
      ultimoId: Number(datos.ultimoId || 0),
    };
  } catch {
    return { inscripciones: [], comentarios: [], ultimoId: 0 };
  }
}

async function guardarRespaldo(datos) {
  await fs.mkdir(path.dirname(archivoRespaldo), { recursive: true });
  await fs.writeFile(archivoRespaldo, JSON.stringify(datos, null, 2), 'utf8');
}

function armarArbolComentarios(filas) {
  const porPublicacion = new Map();
  const porId = new Map();

  for (const f of filas) {
    const nodo = {
      id: String(f.id),
      publicacionId: String(f.publicacionId),
      padreId: f.padreId != null ? String(f.padreId) : null,
      autor: f.autor || 'Usuario',
      texto: f.texto || '',
      fecha: f.fecha,
      respuestas: [],
    };
    porId.set(nodo.id, nodo);
  }

  for (const nodo of porId.values()) {
    const limpio = {
      id: nodo.id,
      autor: nodo.autor,
      texto: nodo.texto,
      fecha: nodo.fecha,
      respuestas: nodo.respuestas,
    };
    nodo._limpio = limpio;
  }

  for (const nodo of porId.values()) {
    if (nodo.padreId && porId.has(nodo.padreId)) {
      porId.get(nodo.padreId)._limpio.respuestas.push(nodo._limpio);
    } else {
      if (!porPublicacion.has(nodo.publicacionId)) {
        porPublicacion.set(nodo.publicacionId, []);
      }
      porPublicacion.get(nodo.publicacionId).push(nodo._limpio);
    }
  }

  return porPublicacion;
}

async function mapaUsuariosPorId(pool, ids) {
  const unicos = [...new Set(ids.map((x) => Number(x)).filter((x) => Number.isInteger(x) && x > 0))];
  const mapa = new Map();
  if (unicos.length === 0) return mapa;
  const marcadores = unicos.map(() => '?').join(',');
  const [filas] = await pool.execute(
    `SELECT id, nombre FROM usuarios WHERE id IN (${marcadores})`,
    unicos
  );
  for (const f of filas) {
    mapa.set(String(f.id), f.nombre);
  }
  return mapa;
}

async function consultarInteracciones(pool, usuarioIdActual) {
  const usaMySQL = await asegurarTablas(pool);
  if (usaMySQL) {
    const [filasInsc] = await pool.execute(`
      SELECT
        i.publicacion_id AS publicacionId,
        i.usuario_id AS usuarioId,
        u.nombre AS autor
      FROM inscripciones i
      JOIN usuarios u ON u.id = i.usuario_id
      ORDER BY i.creado_en ASC, i.id ASC
    `);
    const [filasCom] = await pool.execute(`
      SELECT
        c.id,
        c.publicacion_id AS publicacionId,
        c.padre_id AS padreId,
        c.texto,
        DATE_FORMAT(c.creado_en, '%Y-%m-%dT%H:%i:%sZ') AS fecha,
        u.nombre AS autor
      FROM comentarios c
      JOIN usuarios u ON u.id = c.usuario_id
      ORDER BY c.creado_en ASC, c.id ASC
    `);
    const inscripcionesPorPub = new Map();
    for (const r of filasInsc) {
      const pid = String(r.publicacionId);
      if (!inscripcionesPorPub.has(pid)) {
        inscripcionesPorPub.set(pid, { cupoOcupado: 0, inscrito: false, inscritosNombres: [] });
      }
      const info = inscripcionesPorPub.get(pid);
      info.cupoOcupado += 1;
      info.inscritosNombres.push(r.autor);
      if (String(r.usuarioId) === String(usuarioIdActual)) {
        info.inscrito = true;
      }
    }
    const comentariosPorPub = armarArbolComentarios(filasCom);
    return { inscripcionesPorPub, comentariosPorPub };
  }

  const respaldo = await leerRespaldo();
  const idsUsuarios = [
    ...respaldo.inscripciones.map((i) => i.usuarioId),
    ...respaldo.comentarios.map((c) => c.usuarioId),
  ];
  const nombres = await mapaUsuariosPorId(pool, idsUsuarios);

  const inscripcionesPorPub = new Map();
  for (const r of respaldo.inscripciones) {
    const pid = String(r.publicacionId);
    if (!inscripcionesPorPub.has(pid)) {
      inscripcionesPorPub.set(pid, { cupoOcupado: 0, inscrito: false, inscritosNombres: [] });
    }
    const info = inscripcionesPorPub.get(pid);
    info.cupoOcupado += 1;
    info.inscritosNombres.push(nombres.get(String(r.usuarioId)) || r.autor || 'Usuario');
    if (String(r.usuarioId) === String(usuarioIdActual)) {
      info.inscrito = true;
    }
  }

  const filasCom = respaldo.comentarios.map((c) => ({
    id: c.id,
    publicacionId: c.publicacionId,
    padreId: c.padreId,
    texto: c.texto,
    fecha: c.fecha,
    autor: nombres.get(String(c.usuarioId)) || c.autor || 'Usuario',
  }));
  const comentariosPorPub = armarArbolComentarios(filasCom);
  return { inscripcionesPorPub, comentariosPorPub };
}

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

  app.get('/eventos/:id/inscripciones', verificarSesion, async (req, res) => {
    const publicacionId = Number(req.params.id);
    if (!Number.isInteger(publicacionId) || publicacionId < 1) {
      return res.status(400).json({ error: 'Identificador de evento inválido' });
    }
    try {
      const [eventos] = await pool.execute(
        'SELECT cupo_maximo AS cupoMaximo FROM eventos WHERE publicacion_id = ? LIMIT 1',
        [publicacionId]
      );
      if (eventos.length === 0) {
        return res.status(404).json({ error: 'El evento no existe' });
      }
      const { inscripcionesPorPub } = await consultarInteracciones(pool, req.usuarioId);
      const info = inscripcionesPorPub.get(String(publicacionId)) || {
        cupoOcupado: 0,
        inscrito: false,
        inscritosNombres: [],
      };
      return res.json({
        inscrito: info.inscrito,
        cupoOcupado: info.cupoOcupado,
        cupoMaximo: Number(eventos[0].cupoMaximo),
        inscritosNombres: info.inscritosNombres,
      });
    } catch (error) {
      console.error('Error consultando inscripciones:', error.code || error.name);
      return res.status(500).json({ error: 'No se pudieron consultar las inscripciones' });
    }
  });

  app.post('/eventos/:id/inscripcion', verificarSesion, async (req, res) => {
    const publicacionId = Number(req.params.id);
    if (!Number.isInteger(publicacionId) || publicacionId < 1) {
      return res.status(400).json({ error: 'Identificador de evento inválido' });
    }
    try {
      const [eventos] = await pool.execute(
        `SELECT e.cupo_maximo AS cupoMaximo, p.usuario_id AS organizadorId
         FROM eventos e
         JOIN publicaciones p ON p.id = e.publicacion_id
         WHERE e.publicacion_id = ?
         LIMIT 1`,
        [publicacionId]
      );
      if (eventos.length === 0) {
        return res.status(404).json({ error: 'El evento no existe' });
      }
      const cupoMaximo = Number(eventos[0].cupoMaximo);
      const usaMySQL = await asegurarTablas(pool);

      if (usaMySQL) {
        const [existentes] = await pool.execute(
          'SELECT id FROM inscripciones WHERE publicacion_id = ? AND usuario_id = ? LIMIT 1',
          [publicacionId, req.usuarioId]
        );
        if (existentes.length > 0) {
          await pool.execute(
            'DELETE FROM inscripciones WHERE publicacion_id = ? AND usuario_id = ?',
            [publicacionId, req.usuarioId]
          );
        } else {
          const [conteo] = await pool.execute(
            'SELECT COUNT(*) AS total FROM inscripciones WHERE publicacion_id = ?',
            [publicacionId]
          );
          if (Number(conteo[0].total) >= cupoMaximo) {
            return res.status(409).json({
              error: 'Lo sentimos, este evento ya alcanzó su cupo máximo.',
            });
          }
          await pool.execute(
            'INSERT INTO inscripciones (publicacion_id, usuario_id) VALUES (?, ?)',
            [publicacionId, req.usuarioId]
          );
        }
      } else {
        const respaldo = await leerRespaldo();
        const idx = respaldo.inscripciones.findIndex(
          (i) =>
            String(i.publicacionId) === String(publicacionId) &&
            String(i.usuarioId) === String(req.usuarioId)
        );
        if (idx >= 0) {
          respaldo.inscripciones.splice(idx, 1);
        } else {
          const actuales = respaldo.inscripciones.filter(
            (i) => String(i.publicacionId) === String(publicacionId)
          );
          if (actuales.length >= cupoMaximo) {
            return res.status(409).json({
              error: 'Lo sentimos, este evento ya alcanzó su cupo máximo.',
            });
          }
          respaldo.inscripciones.push({
            publicacionId: String(publicacionId),
            usuarioId: String(req.usuarioId),
            creadoEn: new Date().toISOString(),
          });
        }
        await guardarRespaldo(respaldo);
      }

      const { inscripcionesPorPub } = await consultarInteracciones(pool, req.usuarioId);
      const info = inscripcionesPorPub.get(String(publicacionId)) || {
        cupoOcupado: 0,
        inscrito: false,
        inscritosNombres: [],
      };
      return res.json({
        inscrito: info.inscrito,
        cupoOcupado: info.cupoOcupado,
        cupoMaximo,
        inscritosNombres: info.inscritosNombres,
      });
    } catch (error) {
      console.error('Error actualizando inscripción:', error.code || error.name);
      return res.status(500).json({ error: 'No se pudo actualizar la inscripción' });
    }
  });

  app.get('/eventos/:id/comentarios', verificarSesion, async (req, res) => {
    const publicacionId = Number(req.params.id);
    if (!Number.isInteger(publicacionId) || publicacionId < 1) {
      return res.status(400).json({ error: 'Identificador de publicación inválido' });
    }
    try {
      const { comentariosPorPub } = await consultarInteracciones(pool, req.usuarioId);
      return res.json(comentariosPorPub.get(String(publicacionId)) || []);
    } catch (error) {
      console.error('Error consultando comentarios:', error.code || error.name);
      return res.status(500).json({ error: 'No se pudieron cargar los comentarios' });
    }
  });

  app.post('/eventos/:id/comentarios', verificarSesion, async (req, res) => {
    const publicacionId = Number(req.params.id);
    const { texto, padreId } = req.body ?? {};

    if (!Number.isInteger(publicacionId) || publicacionId < 1) {
      return res.status(400).json({ error: 'Identificador de publicación inválido' });
    }
    if (typeof texto !== 'string' || texto.trim().length === 0 || texto.trim().length > 2000) {
      return res.status(400).json({ error: 'Escribe un comentario válido (máximo 2000 caracteres)' });
    }

    const padreIdNum =
      padreId !== undefined && padreId !== null && String(padreId).trim() !== ''
        ? Number(padreId)
        : null;
    if (padreIdNum !== null && (!Number.isInteger(padreIdNum) || padreIdNum < 1)) {
      return res.status(400).json({ error: 'Comentario padre inválido' });
    }

    try {
      const [pubs] = await pool.execute(
        'SELECT id FROM publicaciones WHERE id = ? LIMIT 1',
        [publicacionId]
      );
      if (pubs.length === 0) {
        return res.status(404).json({ error: 'La publicación no existe' });
      }

      const usaMySQL = await asegurarTablas(pool);
      if (usaMySQL) {
        if (padreIdNum !== null) {
          const [padres] = await pool.execute(
            'SELECT id FROM comentarios WHERE id = ? AND publicacion_id = ? LIMIT 1',
            [padreIdNum, publicacionId]
          );
          if (padres.length === 0) {
            return res.status(404).json({ error: 'El comentario a responder no existe' });
          }
        }
        await pool.execute(
          'INSERT INTO comentarios (publicacion_id, usuario_id, padre_id, texto) VALUES (?, ?, ?, ?)',
          [publicacionId, req.usuarioId, padreIdNum, texto.trim()]
        );
      } else {
        const respaldo = await leerRespaldo();
        if (padreIdNum !== null) {
          const existePadre = respaldo.comentarios.some(
            (c) =>
              String(c.id) === String(padreIdNum) &&
              String(c.publicacionId) === String(publicacionId)
          );
          if (!existePadre) {
            return res.status(404).json({ error: 'El comentario a responder no existe' });
          }
        }
        const nuevoId = respaldo.ultimoId + 1;
        respaldo.ultimoId = nuevoId;
        respaldo.comentarios.push({
          id: String(nuevoId),
          publicacionId: String(publicacionId),
          usuarioId: String(req.usuarioId),
          padreId: padreIdNum !== null ? String(padreIdNum) : null,
          texto: texto.trim(),
          fecha: new Date().toISOString(),
        });
        await guardarRespaldo(respaldo);
      }

      const { comentariosPorPub } = await consultarInteracciones(pool, req.usuarioId);
      return res.status(201).json({
        comentarios: comentariosPorPub.get(String(publicacionId)) || [],
      });
    } catch (error) {
      console.error('Error guardando comentario:', error.code || error.name);
      return res.status(500).json({ error: 'No se pudo guardar el comentario' });
    }
  });
}

module.exports = { registrarCategorias, registrarContenido };
