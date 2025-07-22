require('dotenv').config();
const express = require('express');
const path = require('path');
const request = require('superagent'); // o puedes usar fetch si prefieres
const app = express();

// Set EJS as templating engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Serve static assets if needed
// app.use(express.static(path.join(__dirname, 'public')));

let backend_url = process.env.BACKEND_URL || "http://localhost:8080";

// Home
app.get('/', (req, res) =>
{
  res.render('index');
});

// Movies
app.get('/movies', (req, res) =>
{
  request
    .get(`${backend_url}/movies`)
    .end((err, data) =>
    {
      if (err || data.status === 403)
      {
        res.status(403).send('403 Forbidden');
      } else
      {
        res.render('movies', { movies: data.body });
      }
    });
});

// Authors
app.get('/authors', (req, res) =>
{
  request
    .get(`${backend_url}/reviewers`)
    .end((err, data) =>
    {
      if (err || data.status === 403)
      {
        res.status(403).send('403 Forbidden');
      } else
      {
        res.render('authors', { authors: data.body });
      }
    });
});

// Publications
app.get('/publications', (req, res) =>
{
  request
    .get(`${backend_url}/publications`)
    .end((err, data) =>
    {
      if (err || data.status === 403)
      {
        res.status(403).send('403 Forbidden');
      } else
      {
        res.render('publications', { publications: data.body });
      }
    });
});

// Pending (admin-only)
app.get('/pending', (req, res) =>
{
  request
    .get(`${backend_url}/pending`)
    .end((err, data) =>
    {
      res.status(403).send('403 Forbidden'); // Always forbidden
    });
});

// Start server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () =>
{
  console.log(`Frontend listening on port ${PORT}`);
});
