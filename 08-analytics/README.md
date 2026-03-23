# EP08 — Analytics: Umami self-hosted

Analytics privacy-first para todos os sites da série. Sem cookies, sem Google, sem banner LGPD.

## Stack

- **Umami** — analytics open source, leve (~2KB script)
- **PostgreSQL** — banco incluído no docker-compose do Umami (gerenciado pelo próprio recurso)
- **Domínio:** `umami.vpslab.com.br`

## Deploy no Coolify

O Umami é deployado direto do repo oficial via Public Repository:

1. New Resource → Git → Public Repository
2. URL: `https://github.com/umami-software/umami.git`
3. Build Pack: Docker Compose
4. Domínio: `https://umami.vpslab.com.br:3000`

Ver [deploy-notes.md](deploy-notes.md) para o passo a passo completo.

## Tracking

Adicionar no `<head>` de cada site Astro:

```html
<script async defer
  src="https://umami.vpslab.com.br/script.js"
  data-website-id="SEU_WEBSITE_ID"
  data-do-not-track="true"
></script>
```

Uma instância do Umami monitora múltiplos sites — cada site tem seu próprio `data-website-id`.
