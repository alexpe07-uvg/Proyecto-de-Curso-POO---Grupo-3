const test = require('node:test');
const assert = require('node:assert/strict');
const os = require('node:os');
const path = require('node:path');
const fs = require('node:fs/promises');
const { registrarPerfil, extensionImagen, MAX_FOTO } = require('./perfil');

const png = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jZ1kAAAAASUVORK5CYII=', 'base64');
async function entorno(t) {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'uvg-perfil-'));
  t.after(() => fs.rm(dir, { recursive: true, force: true }));
  const usuarios = new Map([
    ['1', { id: 1, nombre: 'Ana', correo: 'ana@uvg.edu.gt', carrera: 'Computación', foto_url: null }],
    ['2', { id: 2, nombre: 'Luis', correo: 'luis@uvg.edu.gt', carrera: 'Biología', foto_url: null }],
  ]);
  let fallo = false;
  const pool = {
    async execute(sql, args) {
      const usuario = usuarios.get(String(args.at(-1)));
      if (sql.startsWith('SELECT')) return [usuario ? [{ ...usuario }] : []];
      if (fallo) throw new Error('MySQL no disponible');
      if (!usuario) return [{ affectedRows: 0 }];
      if (sql.includes('SET nombre')) usuario.nombre = args[0];
      if (sql.includes('SET foto_url')) usuario.foto_url = args[0];
      return [{ affectedRows: 1 }];
    },
    async getConnection() { return this; },
    async beginTransaction() {}, async commit() {}, async rollback() {}, release() {},
  };
  const rutas = new Map();
  const app = { get(ruta, ...handlers) { rutas.set(ruta, handlers); }, post(ruta, ...handlers) { rutas.set(ruta, handlers); }, use() {} };
  // Middleware de sesión simulado: la integración usa verificarSesion de server.js.
  const auth = (req, res, next) => req.usuarioId ? next() : res.status(401).json({ error: 'Debes iniciar sesión' });
  const express = { raw: () => (req, res, next) => next(), static: () => () => {} };
  registrarPerfil(app, pool, auth, express, dir);
  async function llamar(ruta, body, usuarioId = '1') {
    const req = { body, usuarioId };
    const res = { statusCode: 200, status(n) { this.statusCode = n; return this; },
      set() { return this; }, json(datos) { this.body = datos; return this; } };
    const handlers = rutas.get(ruta);
    async function ejecutar(i) { if (i < handlers.length) await handlers[i](req, res, () => ejecutar(i + 1)); }
    await ejecutar(0);
    return res;
  }
  return { llamar, usuarios, dir, fallar: () => { fallo = true; } };
}
test('consulta y edición se limitan a la cuenta autenticada; correo y carrera no cambian', async t => {
  const e = await entorno(t);
  const r = await e.llamar('/perfil/nombre', { nombre: '  Ana nueva  ', id: 2, correo: 'otro@uvg.edu.gt', carrera: 'Otra' });
  assert.equal(r.statusCode, 200);
  assert.equal(r.body.nombre, 'Ana nueva');
  assert.equal(r.body.correo, 'ana@uvg.edu.gt');
  assert.equal(r.body.carrera, 'Computación');
  assert.equal(e.usuarios.get('2').nombre, 'Luis');
  assert.equal((await e.llamar('/perfil')).body.nombre, 'Ana nueva');
});
test('rechaza nombres vacíos, demasiado largos y cuentas inexistentes', async t => {
  const e = await entorno(t);
  for (const nombre of ['', '   ', 'x'.repeat(101), null, 12]) {
    assert.equal((await e.llamar('/perfil/nombre', { nombre })).statusCode, 400);
  }
  assert.equal((await e.llamar('/perfil', undefined, '99')).statusCode, 404);
  assert.equal((await e.llamar('/perfil/nombre', { nombre: 'Ana' }, '99')).statusCode, 404);
});
test('todas las operaciones requieren pasar el middleware de sesión', async t => {
  const e = await entorno(t);
  for (const ruta of ['/perfil', '/perfil/nombre', '/perfil/foto', '/perfil/foto/eliminar']) {
    assert.equal((await e.llamar(ruta, png, null)).statusCode, 401);
  }
});
test('subir, reemplazar y eliminar foto persiste la URL y limpia archivos anteriores', async t => {
  const e = await entorno(t);
  const primera = await e.llamar('/perfil/foto', png);
  assert.equal(primera.statusCode, 200);
  const anterior = primera.body.foto_url;
  assert.deepEqual(await fs.readFile(path.join(e.dir, path.basename(anterior))), png);
  const segunda = await e.llamar('/perfil/foto', png);
  assert.notEqual(segunda.body.foto_url, anterior);
  assert.equal((await fs.readdir(e.dir)).length, 1);
  assert.equal((await e.llamar('/perfil')).body.foto_url, segunda.body.foto_url);
  assert.equal((await e.llamar('/perfil/foto/eliminar')).body.foto_url, null);
  assert.deepEqual(await fs.readdir(e.dir), []);
});
test('rechaza contenido no permitido y limpia la imagen nueva si MySQL falla', async t => {
  const e = await entorno(t);
  assert.equal((await e.llamar('/perfil/foto', Buffer.from('<svg></svg>'))).statusCode, 400);
  assert.equal((await e.llamar('/perfil/foto', Buffer.alloc(0))).statusCode, 400);
  await e.llamar('/perfil/foto', png);
  const anterior = e.usuarios.get('1').foto_url;
  e.fallar();
  assert.equal((await e.llamar('/perfil/foto', png)).statusCode, 500);
  assert.equal(e.usuarios.get('1').foto_url, anterior);
  assert.equal((await fs.readdir(e.dir)).length, 1);
});
test('firmas de imagen y límite esperado', () => {
  assert.equal(extensionImagen(png), 'png');
  assert.equal(extensionImagen(Buffer.from([255, 216, 255])), 'jpg');
  assert.equal(extensionImagen(Buffer.from('RIFF0000WEBP')), 'webp');
  assert.equal(extensionImagen(Buffer.from('GIF89a')), null);
  assert.equal(MAX_FOTO, 5 * 1024 * 1024);
});
