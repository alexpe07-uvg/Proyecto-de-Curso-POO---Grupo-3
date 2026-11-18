const path = require('node:path');
const fs = require('node:fs/promises');
const { randomUUID } = require('node:crypto');

const MAX_FOTO = 5 * 1024 * 1024;
function extensionImagen(bytes) {
  if (bytes.length >= 8 && bytes.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) return 'png';
  if (bytes.length >= 3 && bytes[0] === 255 && bytes[1] === 216 && bytes[2] === 255) return 'jpg';
  if (bytes.length >= 12 && bytes.toString('ascii', 0, 4) === 'RIFF' && bytes.toString('ascii', 8, 12) === 'WEBP') return 'webp';
  return null;
}

function registrarPerfil(app, pool, verificarSesion, express, directorio) {
  async function consultar(id, conexion = pool) {
    const [filas] = await conexion.execute(
      'SELECT id, nombre, correo, carrera, foto_url FROM usuarios WHERE id = ?', [id]);
    return filas[0];
  }
  async function limpiar(url) {
    if (!url || !/^\/fotos-perfil\/[a-f0-9-]+\.(png|jpg|webp)$/.test(url)) return;
    try { await fs.unlink(path.join(directorio, path.basename(url))); }
    catch (error) { if (error.code !== 'ENOENT') console.error('No se pudo limpiar la foto anterior:', error.code); }
  }
  app.get('/perfil', verificarSesion, async (req, res) => {
    try {
      const usuario = await consultar(req.usuarioId);
      if (!usuario) return res.status(404).json({ error: 'La cuenta ya no existe' });
      res.set('Cache-Control', 'no-store').json(usuario);
    } catch { res.status(500).json({ error: 'No se pudo consultar el perfil' }); }
  });
  app.post('/perfil/nombre', verificarSesion, async (req, res) => {
    const { nombre } = req.body ?? {};
    if (typeof nombre !== 'string' || !nombre.trim() || nombre.trim().length > 100) {
      return res.status(400).json({ error: 'El nombre debe tener entre 1 y 100 caracteres' });
    }
    try {
      // Solo se modifica el usuario identificado por el token, nunca por el cuerpo.
      const [resultado] = await pool.execute('UPDATE usuarios SET nombre = ? WHERE id = ?', [nombre.trim(), req.usuarioId]);
      if (!resultado.affectedRows) return res.status(404).json({ error: 'La cuenta ya no existe' });
      res.json(await consultar(req.usuarioId));
    } catch { res.status(500).json({ error: 'No se pudo guardar el nombre' }); }
  });
  async function cambiarFoto(req, res, eliminar) {
    let nuevaUrl;
    let conexion;
    let confirmado = false;
    try {
      if (!eliminar) {
        if (!Buffer.isBuffer(req.body) || !req.body.length) return res.status(400).json({ error: 'Selecciona una imagen' });
        const extension = extensionImagen(req.body);
        if (!extension) return res.status(400).json({ error: 'Usa una imagen PNG, JPEG o WebP' });
        await fs.mkdir(directorio, { recursive: true });
        const archivo = `${randomUUID()}.${extension}`;
        nuevaUrl = `/fotos-perfil/${archivo}`;
        await fs.writeFile(path.join(directorio, archivo), req.body, { flag: 'wx' });
      }
      conexion = await pool.getConnection();
      await conexion.beginTransaction();
      const [filas] = await conexion.execute('SELECT foto_url FROM usuarios WHERE id = ? FOR UPDATE', [req.usuarioId]);
      if (!filas.length) {
        await conexion.rollback();
        await limpiar(nuevaUrl);
        return res.status(404).json({ error: 'La cuenta ya no existe' });
      }
      await conexion.execute('UPDATE usuarios SET foto_url = ? WHERE id = ?', [nuevaUrl ?? null, req.usuarioId]);
      const usuario = await consultar(req.usuarioId, conexion);
      await conexion.commit();
      confirmado = true;
      await limpiar(filas[0].foto_url);
      res.json(usuario);
    } catch {
      if (conexion && !confirmado) await conexion.rollback().catch(() => {});
      if (!confirmado) await limpiar(nuevaUrl);
      res.status(500).json({ error: 'No se pudo guardar la fotografía' });
    } finally { if (conexion) conexion.release(); }
  }
  app.post('/perfil/foto', verificarSesion,
    express.raw({ type: 'application/octet-stream', limit: MAX_FOTO }),
    (req, res) => cambiarFoto(req, res, false));
  app.post('/perfil/foto/eliminar', verificarSesion, (req, res) => cambiarFoto(req, res, true));
  app.use('/fotos-perfil', express.static(directorio, {
    dotfiles: 'deny', index: false,
    setHeaders(res) { res.setHeader('X-Content-Type-Options', 'nosniff'); },
  }));
}
module.exports = { registrarPerfil, extensionImagen, MAX_FOTO };
