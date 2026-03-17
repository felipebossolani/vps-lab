---
title: "EP03 — Site estático: push no GitHub = live em 60 segundos"
description: "Deploy de site Astro via Coolify com CI/CD automático. Build Pack Static, domínio customizado e SSL."
date: 2026-03-16
tags: ["astro", "deploy", "coolify", "cicd"]
---

## O problema

Quero um site índice para a série vps-lab. Precisa estar no ar em `site.vpslab.com.br` com HTTPS, e atualizar automaticamente a cada push no GitHub.

## Stack

- **Astro** com `output: 'static'` — gera HTMLs puros em `dist/`
- **Coolify** com Build Pack Static — serve os HTMLs gerados
- **GitHub App** — webhook para auto deploy

## Configuração no Coolify

| Campo | Valor |
|-------|-------|
| Build Pack | Static |
| Base Directory | `/03-static-sites/example-astro` |
| Build Command | `npm run build` |
| Publish Directory | `dist` |

Sem configuração de porta. O Build Pack Static serve os HTMLs diretamente via Traefik — não roda nenhum server Node.

## Perrengues

### Build Pack errado

O padrão do Coolify é Nixpacks. Com Astro estático, o Nixpacks tenta rodar um server Node — deploy completa sem erro, mas dá 404.

Fix: usar Build Pack **Static** com Publish Directory `dist`.

### Domínio com certificado inválido

Configurei o domínio no painel, salvei, acessei. Certificado inválido.

O Coolify gera as rotas do Traefik **durante o deploy**, não quando salva o domínio. Sem redeploy, as rotas ainda apontam pro sslip.io.

Fix: **Redeploy obrigatório** após mudar o domínio.

### Base Directory

Base Directory precisa apontar para onde está o `package.json`, não para a raiz do repo. Parece óbvio. Errei mesmo assim.

## Resultado

Push no GitHub → Coolify detecta → build → site no ar em ~60 segundos com HTTPS.

## Código

[github.com/felipebossolani/vps-lab/tree/main/03-static-sites](https://github.com/felipebossolani/vps-lab/tree/main/03-static-sites)
