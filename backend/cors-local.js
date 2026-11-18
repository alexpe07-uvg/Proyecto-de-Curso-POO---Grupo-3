// Permisos de navegador para desarrollo local.
const permitidos = new Set([
  'http://localhost:5173',
  'http://127.0.0.1:5173',
]);

module.exports = function corsLocal(req, res, next) {
  const origen = req.headers.origin;
  if (!origen) return next();
  res.vary('Origin');
  if (!permitidos.has(origen)) {
    return res.status(403).json({ error: 'Origen del navegador no permitido' });
  }
  res.setHeader('Access-Control-Allow-Origin', origen);
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
};
