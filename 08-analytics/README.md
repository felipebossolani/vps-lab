# EP08 — Analytics: Umami self-hosted

Analytics privacy-first para todos os sites da série. Sem cookies, sem Google, sem banner LGPD.

## Stack

- **Umami** — analytics open source, leve (~2KB script)
- **PostgreSQL 16** — banco gerenciado pelo Coolify (rede interna, sem porta exposta)
- **Domínio:** `umami.vpslab.com.br`

## Uso local

```bash
docker compose -f docker-compose.local.yml up -d
# http://localhost:3000 — login: admin / umami
docker compose -f docker-compose.local.yml down
```

## Deploy no Coolify

1. Criar banco PostgreSQL no Coolify (mesmo padrão EP05)
2. Deploy via Docker Compose + GitHub (Base Directory: `/08-analytics`)
3. Variáveis: `DATABASE_URL` (connection string interna) + `APP_SECRET`
4. Domínio: `https://umami.vpslab.com.br`

Ver [deploy-notes.md](deploy-notes.md) para o passo a passo completo.

## Tracking

Adicionar no `<head>` de cada site Astro:

```html
<script defer src="https://umami.vpslab.com.br/script.js" data-website-id="SEU_WEBSITE_ID"></script>
```

Uma instância do Umami monitora múltiplos sites — cada site tem seu próprio `data-website-id`.

## Arquitetura

```
[Sites Astro] → script.js → [Umami] → [PostgreSQL interno]
                                ↑
                        umami.vpslab.com.br
```
