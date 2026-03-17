# EP04 — Deploy de Blog com Astro Content Collections

---

## Pré-requisitos

- Coolify instalado e funcionando (EP02)
- GitHub App conectado ao Coolify (EP03)
- DNS configurado: `blog.vpslab.com.br → SEU_IP`

---

## Configurando o deploy no Coolify

### 1. Criar nova aplicação

1. **Projects → + New Resource → Application**
2. Selecionar **GitHub** como source
3. Repositório: `felipebossolani/vps-lab`
4. Branch: `main`
5. **Build Pack:** `Static` (mesmo do EP03 — Astro gera HTML estático)

### 2. Configurações da aplicação

| Campo | Valor |
|-------|-------|
| Base Directory | `/04-blog/example-blog` |
| Build Command | `npm run build` |
| Publish Directory | `dist` |

> **Nota:** Mesmo fluxo do EP03. O Astro com content collections continua gerando
> HTML estático em `dist/`. O Build Pack Static serve os arquivos gerados.

### 3. Domínio e SSL

1. Na aba **Domains**
2. Substituir o domínio sslip.io por `https://blog.vpslab.com.br`
3. Salvar e clicar **Redeploy** (obrigatório — rotas Traefik são geradas no deploy)
4. SSL emitido automaticamente via Let's Encrypt

### 4. Deploy automático

1. Aba **General → Auto Deploy**: habilitar
2. A partir daqui: **push no GitHub = deploy automático**

---

## Diferenças em relação ao EP03

| Aspecto | EP03 (site) | EP04 (blog) |
|---------|-------------|-------------|
| Conteúdo | Hardcoded nos componentes | Arquivos `.md` em `src/content/posts/` |
| Novo conteúdo | Editar `.astro` | Criar novo `.md` e push |
| Rotas | Só `index.astro` | Dinâmicas via `[...slug].astro` |
| Build Pack | Static | Static (mesmo) |
| Publish Directory | `dist` | `dist` (mesmo) |

---

## Estrutura do projeto Astro

```
example-blog/
├── astro.config.mjs          # output: static
├── package.json
├── tsconfig.json
└── src/
    ├── content/
    │   ├── config.ts          # schema das collections (title, description, date, tags)
    │   └── posts/
    │       ├── ep01-seguranca.md
    │       ├── ep02-coolify.md
    │       └── ep03-site-estatico.md
    ├── layouts/
    │   ├── Layout.astro       # Base (dark theme, JetBrains Mono, #6C47FF)
    │   └── PostLayout.astro   # Layout de post individual
    ├── pages/
    │   ├── index.astro        # Lista de posts (mais recentes primeiro)
    │   └── posts/
    │       └── [...slug].astro # Rota dinâmica por post
    └── components/
        └── PostCard.astro     # Card na listagem
```

---

## Adicionando um novo post

1. Criar arquivo `.md` em `src/content/posts/`:
   ```markdown
   ---
   title: "Título do post"
   description: "Descrição curta"
   date: 2026-03-20
   tags: ["tag1", "tag2"]
   ---

   Conteúdo em Markdown aqui.
   ```

2. Commit e push:
   ```bash
   git add . && git commit -m "post: novo post" && git push
   ```

3. Coolify detecta, builda, sobe. Post no ar em ~60 segundos.

---

## Testando localmente

```bash
cd 04-blog/example-blog
npm install
npm run dev       # http://localhost:4321
npm run build     # gera /dist com HTMLs
```

---

## Troubleshooting

**Build falha no Coolify**
- Verifique o `Base Directory` — precisa apontar para `/04-blog/example-blog`
- Frontmatter dos posts precisa seguir o schema (title, description, date, tags)

**404 após deploy**
- Build Pack deve ser **Static**, não Nixpacks
- Publish Directory: `dist`

**SSL não emite**
- Confirmar DNS: `dig blog.vpslab.com.br +short` → deve retornar o IP
- Porta 80 aberta (Let's Encrypt usa desafio HTTP)
- Redeploy após mudar o domínio

**Posts não aparecem**
- Arquivos `.md` devem estar em `src/content/posts/`
- Frontmatter precisa ter os 4 campos: title, description, date, tags
- `date` precisa ser formato ISO (YYYY-MM-DD)
