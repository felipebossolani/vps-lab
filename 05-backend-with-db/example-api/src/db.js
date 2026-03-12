// src/db.js
import pg from 'pg';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // SSL necessário em alguns providers — descomente se precisar:
  // ssl: { rejectUnauthorized: false }
});

// Inicializa tabela se não existir
export async function migrate() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS urls (
      id         SERIAL PRIMARY KEY,
      slug       VARCHAR(20) UNIQUE NOT NULL,
      original_url TEXT NOT NULL,
      clicks     INTEGER DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE INDEX IF NOT EXISTS idx_urls_slug ON urls(slug);
  `);

  console.log('Banco de dados inicializado');
}

// Testa conexão e roda migrate ao iniciar
pool.connect()
  .then(client => {
    console.log('PostgreSQL conectado');
    client.release();
    return migrate();
  })
  .catch(err => {
    console.error('Erro ao conectar no PostgreSQL:', err.message);
    process.exit(1);
  });
