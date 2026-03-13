# EP05 — Deploy: API Node.js + PostgreSQL no Coolify

O ponto central desse episódio: **o banco de dados não fica exposto publicamente**.
Ele existe apenas na rede interna Docker — só a API consegue falar com ele.

---

## Passo 1: Criar o banco PostgreSQL no Coolify

1. No painel Coolify: **Databases → New Database → PostgreSQL**
2. Configurar:
   - **Name:** `shortener-db`
   - **PostgreSQL User:** `vpslab`
   - **PostgreSQL Password:** (gere uma senha forte)
   - **PostgreSQL DB:** `shortener`
3. **Importante — NÃO habilite "Publicly Accessible"**
   - Isso garante que o banco só é acessível na rede interna do Coolify
4. Salvar e aguardar o container subir

### Obtendo a connection string interna

Após criar o banco, Coolify mostra duas connection strings:
- **Internal:** `postgres://vpslab:SENHA@shortener-db:5432/shortener` ← use essa
- **External:** `postgres://vpslab:SENHA@SEU_IP:PORT/shortener` ← NÃO use em produção

A URL interna funciona porque a API e o banco estão na mesma rede Docker gerenciada pelo Coolify.

---

## Passo 2: Deploy da API

1. **Projects → New Application → GitHub**
2. Repositório: `felipebossolani/vps-lab`
3. Branch: `main`
4. **Base Directory:** `/05-backend-with-db/example-api`
5. **Build Pack:** `Dockerfile` (Coolify detecta automaticamente)

### Variáveis de ambiente

Na aba **Environment Variables** da aplicação:

| Variável | Valor |
|----------|-------|
| `DATABASE_URL` | `postgres://vpslab:SENHA@shortener-db:5432/shortener` |
| `BASE_URL` | `https://api.vpslab.com.br` |
| `NODE_ENV` | `production` |
| `PORT` | `3000` |

### Domínio

- Aba **Domains** → `https://api.vpslab.com.br`
- SSL automático via Let's Encrypt

---

## Passo 3: Verificar isolamento do banco

Após o deploy, confirme que o banco NÃO está acessível externamente:

```bash
# Da sua máquina local — deve FALHAR (timeout ou connection refused)
psql postgres://vpslab:SENHA@SEU_IP:5432/shortener

# Do servidor, dentro da rede Docker — deve FUNCIONAR
docker exec -it shortener-db psql -U vpslab -d shortener
```

---

## Testando a API em produção

```bash
# Health check
curl https://api.vpslab.com.br/health

# Encurtar uma URL
curl -X POST https://api.vpslab.com.br/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com/felipebossolani/vps-lab"}'

# Resposta esperada:
# {
#   "slug": "abc1234",
#   "short_url": "https://api.vpslab.com.br/abc1234",
#   "original_url": "https://github.com/...",
#   "created_at": "2025-01-01T00:00:00Z"
# }

# Testar redirect
curl -L https://api.vpslab.com.br/abc1234

# Listar URLs criadas
curl https://api.vpslab.com.br/api/urls
```

---

## Testando localmente com Docker Compose

```bash
cd 05-backend-with-db/example-api

# Sobe API + banco local
docker compose up -d

# Testa
curl -X POST http://localhost:3000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com"}'

# Para tudo
docker compose down
```

---

## Arquitetura de rede no Coolify

```
Internet
    │
    ▼
[Traefik] → api.vpslab.com.br
    │
    ▼
[Container: vpslab-shortener]    ← porta 3000, sem exposição externa
    │  (rede interna Docker)
    ▼
[Container: shortener-db]        ← PostgreSQL, zero porta exposta
```

O Coolify coloca ambos os containers na mesma rede Docker interna.
A comunicação entre eles usa o nome do serviço como hostname (`shortener-db`).
Nenhuma porta do banco chega no host ou na internet.
