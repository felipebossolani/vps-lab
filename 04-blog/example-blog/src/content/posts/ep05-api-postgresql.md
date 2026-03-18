---
title: "EP05 — API + PostgreSQL: banco isolado na rede interna"
description: "Encurtador de URLs com Express e PostgreSQL no Coolify. O banco não tem nenhuma porta exposta na internet."
date: 2026-03-18
tags: ["nodejs", "postgresql", "docker", "coolify", "api"]
---

## O problema

Preciso subir uma API com banco de dados na VPS. O banco **não pode** ficar acessível pela internet — só a API fala com ele, pela rede interna Docker.

## Stack

- **Express** (Node.js 20) — API do encurtador de URLs
- **PostgreSQL 16** — banco de dados
- **Docker multi-stage build** — imagem final sem devDependencies, usuário não-root
- **Coolify** — orquestra os containers e gerencia a rede interna

## Como funciona

A API recebe uma URL, gera um slug curto (nanoid), salva no PostgreSQL e retorna o link encurtado. Ao acessar o link curto, redireciona para a URL original.

```
POST /shorten  { "url": "https://exemplo.com" }
→ { "short_url": "https://api.vpslab.com.br/abc1234" }

GET /abc1234
→ 301 redirect para https://exemplo.com
```

## Configuração no Coolify

### Banco de dados

1. Databases → New → PostgreSQL
2. **"Publicly Accessible": desabilitado** — essa é a decisão central
3. Na configuração do banco, seção Network, o Coolify mostra a **Postgres URL (internal)**: `postgres://user:pass@shortener-db:5432/db`
4. A URL externa só aparece se habilitar "Make it publicly available" — não habilite

A URL interna usa o nome do container como hostname. Funciona porque API e banco estão na mesma rede Docker gerenciada pelo Coolify.

### API

- **Build Pack:** Dockerfile (Coolify detecta automaticamente)
- **Base Directory:** `/05-backend-with-db/example-api`
- **Variáveis de ambiente:** `DATABASE_URL` (connection string interna), `BASE_URL`, `NODE_ENV`, `PORT`

## Isolamento de rede

```
Internet
    │
    ▼
[Traefik] → api.vpslab.com.br
    │
    ▼
[Container: API]          ← porta 3000
    │  (rede interna Docker)
    ▼
[Container: PostgreSQL]   ← zero porta exposta
```

Para confirmar o isolamento:
- Da internet → timeout (banco inacessível) ✅
- Da API → conecta normalmente ✅

O Coolify coloca ambos os containers na mesma rede Docker interna. A comunicação entre eles usa o nome do serviço como hostname. Nenhuma porta do banco chega no host ou na internet.

## Pontos de atenção

### Publicly Accessible

A opção existe no Coolify para facilitar debug. Se precisar conectar no banco com um client local (pgAdmin, DBeaver), habilita temporariamente e desliga depois. Em produção: sempre desabilitado.

### Connection string interna vs externa

A interna usa o hostname do container (`shortener-db`). A externa usa o IP da VPS com uma porta mapeada. Se você usa a externa na variável `DATABASE_URL`, o tráfego sai do container, passa pelo host e volta — desnecessário e menos seguro.

### Healthcheck no Dockerfile

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
```

Sem o healthcheck, o Coolify sabe que o container está rodando, mas não se a aplicação está saudável. Com ele, o dashboard mostra o status real e pode reiniciar containers que falharem.

## Código

[github.com/felipebossolani/vps-lab/tree/main/05-backend-with-db](https://github.com/felipebossolani/vps-lab/tree/main/05-backend-with-db)
