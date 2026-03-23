---
title: "EP08 — Analytics: Umami self-hosted, sem cookies e sem Google"
description: "Analytics privacy-first para todos os sites da série. Sem cookies, sem banner LGPD, script de 2KB. Uma instância monitora múltiplos sites."
date: 2026-03-22
tags: ["umami", "analytics", "privacy", "coolify", "docker"]
---

## O problema

Quero saber quantas pessoas acessam os sites da série, quais páginas visitam, de onde vêm. Mas não quero mandar esses dados para o Google, não quero cookies, e não quero banner de consentimento LGPD.

## Por que Umami

| | Google Analytics | Umami |
|---|---|---|
| Dados | Google | Seu servidor |
| Cookies | Sim | Não |
| Banner LGPD | Obrigatório | Desnecessário |
| Custo | "Grátis" (seus dados são o produto) | Grátis (open source) |
| Script | ~45KB | ~2KB |

Uma instância do Umami monitora múltiplos sites — cada site tem seu próprio `data-website-id`.

## Deploy no Coolify

Mesmo padrão do EP05: banco PostgreSQL gerenciado pelo Coolify (rede interna, sem porta exposta), aplicação deployada via Docker Compose + GitHub.

### Banco de dados

1. Databases → New → PostgreSQL 16
2. "Make it publicly available": desabilitado
3. Copiar a Postgres URL (internal)

### Umami

Docker Compose via GitHub, Base Directory `/08-analytics`. Duas variáveis de ambiente:

- `DATABASE_URL` — connection string interna do Coolify
- `APP_SECRET` — string aleatória (`openssl rand -hex 32`)

Domínio: `https://umami.vpslab.com.br`

O Umami cria as tabelas automaticamente no primeiro boot. Login padrão: `admin` / `umami` — trocar imediatamente.

## Tracking nos sites Astro

Um script no `<head>` de cada Layout:

```html
<script defer src="https://umami.vpslab.com.br/script.js" data-website-id="SEU_WEBSITE_ID"></script>
```

O `data-website-id` é gerado pelo Umami ao adicionar cada site em Settings → Websites. O script é leve (~2KB), não usa cookies, e respeita "Do Not Track" do browser.

## Múltiplos sites, uma instância

No painel do Umami, cada site é cadastrado separadamente:

- `vpslab.com.br`
- `blog.vpslab.com.br`
- `api.vpslab.com.br`

O dashboard mostra pageviews, visitantes únicos, referrers, países, dispositivos — tudo por site, tudo no seu servidor.

## Pontos de atenção

### Primeiro login

Login padrão é `admin` / `umami`. Se não trocar, qualquer pessoa que acessar `umami.vpslab.com.br` consegue fazer login.

### APP_SECRET

O `APP_SECRET` é usado para assinar tokens de sessão. Se não definir, o Umami usa um valor padrão — inseguro em produção. Gere com `openssl rand -hex 32`.

### Script bloqueado por adblockers

Alguns adblockers bloqueiam o script do Umami. É esperado — os números mostram quem não usa adblocker. Para a maioria dos sites, a diferença é pequena.

## Código

[github.com/felipebossolani/vps-lab/tree/main/08-analytics](https://github.com/felipebossolani/vps-lab/tree/main/08-analytics)
