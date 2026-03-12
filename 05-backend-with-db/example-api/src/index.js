// src/index.js
import express from 'express';
import { pool } from './db.js';
import { nanoid } from 'nanoid';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Criar URL encurtada
// POST /shorten  { "url": "https://exemplo.com" }
app.post('/shorten', async (req, res) => {
  const { url } = req.body;

  if (!url) {
    return res.status(400).json({ error: 'Campo url é obrigatório' });
  }

  try {
    new URL(url); // valida formato da URL
  } catch {
    return res.status(400).json({ error: 'URL inválida' });
  }

  const slug = nanoid(7);

  try {
    const result = await pool.query(
      'INSERT INTO urls (slug, original_url) VALUES ($1, $2) RETURNING *',
      [slug, url]
    );

    const base = process.env.BASE_URL || `http://localhost:${PORT}`;
    res.status(201).json({
      slug,
      short_url: `${base}/${slug}`,
      original_url: url,
      created_at: result.rows[0].created_at,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro interno' });
  }
});

// Redirecionar slug → URL original
// GET /:slug
app.get('/:slug', async (req, res) => {
  const { slug } = req.params;

  try {
    const result = await pool.query(
      'UPDATE urls SET clicks = clicks + 1 WHERE slug = $1 RETURNING original_url',
      [slug]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'URL não encontrada' });
    }

    res.redirect(301, result.rows[0].original_url);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro interno' });
  }
});

// Listar URLs (para demo)
// GET /api/urls
app.get('/api/urls', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT slug, original_url, clicks, created_at FROM urls ORDER BY created_at DESC LIMIT 20'
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro interno' });
  }
});

// Inicializa servidor
app.listen(PORT, () => {
  console.log(`vps-lab shortener rodando na porta ${PORT}`);
});
