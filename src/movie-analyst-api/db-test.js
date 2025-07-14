// Create a test file db-test.js
const mysql = require('mysql2/promise');

(async () =>
{
    try
    {
        const conn = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASS,
            database: process.env.DB_NAME,
            ssl: { rejectUnauthorized: true }
        });
        const [rows] = await conn.query('SELECT * FROM movies LIMIT 1');
        console.log(rows);
        conn.end();
    } catch (err)
    {
        console.error('Connection failed:', err);
    }
})();