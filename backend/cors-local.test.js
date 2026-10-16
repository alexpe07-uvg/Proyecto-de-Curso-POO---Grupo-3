const test = require('node:test');
const assert = require('node:assert/strict');
const cors = require('./cors-local');
function probar(origin, method = 'GET') {
 const salida = { headers: {}, next: false };
 const res = {
  vary(v) { salida.vary = v; },
  setHeader(k,v) { salida.headers[k] = v; },
  status(v) { salida.status = v; return this; },
  json(v) { salida.body = v; return this; },
  sendStatus(v) { salida.status = v; return this; },
 };
 cors({headers: origin ? {origin} : {}, method}, res, () => {salida.next=true;});
 return salida;
}
test('Chrome local puede solicitar JSON y Authorization', () => {
 for (const origin of ['http://localhost:5173','http://127.0.0.1:5173']) {
  const r=probar(origin,'OPTIONS');
  assert.equal(r.status,204);
  assert.equal(r.headers['Access-Control-Allow-Origin'],origin);
  assert.match(r.headers['Access-Control-Allow-Headers'],/Authorization/);
 }
});
test('origen externo bloqueado', () => {
 const r=probar('https://example.com');
 assert.equal(r.status,403); assert.equal(r.next,false);
 assert.equal(r.headers['Access-Control-Allow-Origin'],undefined);
});
test('app de escritorio y solicitud GET local siguen funcionando', () => {
 assert.equal(probar().next,true);
 assert.equal(probar('http://localhost:5173').next,true);
});
