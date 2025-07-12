// Get our dependencies
const express = require('express');
const app = express();
const mysql = require('mysql');
const util = require('util');

// Database connection
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'applicationuser',
  password: process.env.DB_PASS || 'applicationuser',
  database: process.env.DB_NAME || 'movie_db',
  port: 3306,
  ssl: { rejectUnauthorized: true },  // Required for Azure MySQL
  connectionLimit: 10
});
pool.query = util.promisify(pool.query);

// Routes
app.get('/movies', async (req, res) =>
{
  try
  {
    const rows = await pool.query(
      `SELECT m.title, m.release_year, m.score, 
       r.name as reviewer, p.name as publication 
       FROM movies m, reviewers r, publications p 
       WHERE r.publication=p.name AND m.reviewer=r.name`
    );
    res.json(rows);
  } catch (err)
  {
    console.error('API Error:', err);
    res.status(500).send({ msg: 'Internal server error' });
  }
});

app.get('/reviewers', async (req, res) =>
{
  try
  {
    const rows = await pool.query(
      'SELECT name, publication, avatar FROM reviewers'
    );
    res.json(rows);
  } catch (err)
  {
    console.error('API Error:', err);
    res.status(500).send({ msg: 'Internal server error' });
  }
});

app.get('/publications', async (req, res) =>
{
  try
  {
    const rows = await pool.query(
      'SELECT name, avatar FROM publications'  // Fixed query
    );
    res.json(rows);
  } catch (err)
  {
    console.error('API Error:', err);
    res.status(500).send({ msg: 'Internal server error' });
  }
});

app.get('/pending', async (req, res) =>
{
  try
  {
    const rows = await pool.query(
      `SELECT m.title, m.release_year, m.score, 
       r.name as reviewer, p.name as publication
       FROM movies m, reviewers r, publications p 
       WHERE r.publication=p.name AND m.reviewer=r.name 
       AND m.release_year>=2017`
    );
    res.json(rows);
  } catch (err)
  {
    console.error('API Error:', err);
    res.status(500).send({ msg: 'Internal server error' });
  }
});

app.get('/health', (req, res) =>
{
  res.status(200).send('OK');
});

app.get('/', (req, res) =>
{
  res.status(200).send({ service_status: 'Up' });
});

// Start server
const port = process.env.PORT || 8080;
app.listen(port, '0.0.0.0', () =>
{
  console.log(`Server running on port ${port}`);
});

module.exports = app;