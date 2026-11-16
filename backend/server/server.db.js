// Conexión compartida con MySQL.
const mysql = require('mysql2/promise');

const esLocal = !process.env.DB_HOST ||
  process.env.DB_HOST === '127.0.0.1' ||
  process.env.DB_HOST === 'localhost';

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 4000),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ...(esLocal ? {} : {
    ssl: {
      rejectUnauthorized: true,
    },
  }),
  waitForConnections: true,
  connectionLimit: 5,
  timezone: 'Z',
});

module.exports = pool;
