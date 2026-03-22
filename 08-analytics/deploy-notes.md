# EP08 — Deploy: Umami Analytics no Coolify

Analytics self-hosted, privacy-first. Sem cookies, sem banner de consentimento,
sem mandar dados para o Google. Uma instância monitora múltiplos sites.

---

## Passo 1: Criar o banco PostgreSQL no Coolify

1. No painel Coolify: **Databases → New Database → PostgreSQL 16**
2. Configurar:
   - **Image:** `postgres:16-alpine`
   - **Name:** `umami-db`
   - **PostgreSQL User:** `umami-user`
   - **PostgreSQL Password:** (gerar senha forte)
   - **PostgreSQL DB:** `umami`
3. **NÃO habilitar "Make it publicly available"**
4. Clicar **Start** e aguardar o container subir
5. Copiar a **Postgres URL (internal)** — seção Network, clicar no ícone do olho

---

## Passo 2: Deploy do Umami via Docker Compose

1. **Projects → VPS Lab (production) → + New → clicar no GitHub App**
2. Repositório: `vps-lab` → **Load Repository**
3. Configurar:
   - **Branch:** `main`
   - **Build Pack:** `Docker Compose`
   - **Base Directory:** `/08-analytics`
   - **Docker Compose Location:** `docker-compose.yml`
4. Clicar **Continue**

### Variáveis de ambiente

Na aba **Environment Variables**:

| Variável | Valor |
|----------|-------|
| `DATABASE_URL` | `postgres://umami-user:SENHA@umami-db:5432/umami` (Postgres URL interna) |
| `APP_SECRET` | (gerar string aleatória — `openssl rand -hex 32`) |

5. Clicar **Deploy**
6. Aguardar o container subir (Umami cria as tabelas automaticamente no primeiro boot)

---

## Passo 3: Domínio + SSL

1. Na **Configuration** da stack → seção de domínios do serviço **umami**
2. Domínio: `https://umami.vpslab.com.br`
3. Salvar + **Redeploy**
4. Acessar `https://umami.vpslab.com.br`

### Primeiro login

- **Usuário:** `admin`
- **Senha:** `umami`
- **Trocar a senha imediatamente** após o primeiro login

---

## Passo 4: Adicionar sites no Umami

O Umami suporta múltiplos sites na mesma instância.

1. No painel Umami: **Settings → Websites → Add website**
2. Adicionar cada site:

| Name | Domain |
|------|--------|
| VPS Lab Site | `site.vpslab.com.br` |
| VPS Lab Blog | `blog.vpslab.com.br` |
| VPS Lab API | `api.vpslab.com.br` |

3. Após criar, clicar em **Edit** → copiar o **Tracking code**

O script de tracking é o mesmo para todos os sites — o Umami diferencia pelo `data-website-id`.

---

## Passo 5: Adicionar tracking nos sites Astro

Colar o script no `<head>` do Layout.astro de cada site:

```html
<script defer src="https://umami.vpslab.com.br/script.js" data-website-id="SEU_WEBSITE_ID"></script>
```

Para o site principal (`03-static-sites/example-astro/src/layouts/Layout.astro`):
- Adicionar antes do `<title>`

Para o blog (`04-blog/example-blog/src/layouts/Layout.astro`):
- Mesmo padrão

Após o push, o Coolify faz auto deploy e o tracking começa a funcionar.

---

## Passo 6: Verificação pós-deploy

- [ ] `https://umami.vpslab.com.br` acessível com HTTPS
- [ ] Login funciona com credenciais trocadas
- [ ] Sites adicionados em Settings → Websites
- [ ] Script de tracking inserido nos Layouts
- [ ] Dashboard mostrando pageviews ao acessar os sites
- [ ] Banco não acessível externamente (Make it publicly available desabilitado)

---

## Testando localmente

```bash
cd 08-analytics

docker compose -f docker-compose.local.yml up -d

# Acessar http://localhost:3000
# Login: admin / umami

docker compose -f docker-compose.local.yml down
```

---

## Arquitetura

```
Internet
    │
    ▼
[Traefik] → umami.vpslab.com.br
    │
    ▼
[Container: umami]           ← porta 3000
    │  (rede interna Docker)
    ▼
[Container: umami-db]        ← PostgreSQL, zero porta exposta
```

Os sites (site.vpslab.com.br, blog.vpslab.com.br) enviam eventos via JavaScript
para umami.vpslab.com.br/script.js. O Umami processa e armazena no PostgreSQL interno.

---

## Por que Umami e não Google Analytics

| | Google Analytics | Umami |
|---|---|---|
| Dados | Google | Seu servidor |
| Cookies | Sim | Não |
| Banner LGPD | Obrigatório | Desnecessário |
| Custo | "Grátis" (seus dados são o produto) | Grátis (open source) |
| Múltiplos sites | Sim | Sim |
| Peso do script | ~45KB | ~2KB |
