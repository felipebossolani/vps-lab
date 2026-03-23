# EP08 — Deploy: Umami Analytics no Coolify

Analytics self-hosted, privacy-first. Sem cookies, sem banner de consentimento,
sem mandar dados para o Google. Uma instância monitora múltiplos sites.

---

## Passo 1: Criar o recurso no Coolify

1. No Coolify: **+ New Resource → Git → Public Repository**
2. URL: `https://github.com/umami-software/umami.git`
3. **Build Pack:** `Docker Compose`
4. **Docker Compose Location:** `/docker-compose.yml`
5. **Branch:** `master`
6. Clicar **Reload Compose File** para o Coolify parsear os serviços

---

## Passo 2: Domínio

1. Na Configuration → seção de domínios do serviço **umami**
2. Domínio: `https://umami.vpslab.com.br:3000`
   - O `:3000` indica a porta interna do container — o acesso externo continua pela 443 (HTTPS)
   - Não precisa abrir porta 3000 no UFW
3. Salvar

---

## Passo 3: Deploy

1. Clicar **Deploy**
2. Aguardar o build finalizar (o docker-compose do Umami sobe o app + PostgreSQL interno)
3. Acessar `https://umami.vpslab.com.br`

---

## Passo 4: Configuração inicial

### Trocar credenciais padrão

1. Login: `admin` / `umami`
2. **Settings → Team → admin → Edit** → trocar a senha imediatamente

### Adicionar sites

1. **Settings → Websites → Add website**
2. Adicionar cada site:

| Name | Domain |
|------|--------|
| VPS Lab Site | `site.vpslab.com.br` |
| VPS Lab Blog | `blog.vpslab.com.br` |

3. Clicar **Edit** em cada site → copiar o **Tracking code**

---

## Passo 5: Adicionar tracking nos sites Astro

Colar o script no `<head>` do Layout.astro de cada site, antes do `</head>`:

```html
<script async defer
  src="https://umami.vpslab.com.br/script.js"
  data-website-id="SEU_WEBSITE_ID"
  data-do-not-track="true"
></script>
```

- O `data-website-id` é gerado pelo Umami ao adicionar cada site
- O `data-do-not-track="true"` respeita a preferência "Do Not Track" do browser
- O script pesa ~2KB e não usa cookies

Após o push, o Coolify faz auto deploy e o tracking começa a funcionar.

---

## Verificação pós-deploy

- [ ] `https://umami.vpslab.com.br` acessível com HTTPS
- [ ] Senha do admin trocada
- [ ] Sites adicionados em Settings → Websites
- [ ] Script de tracking inserido nos Layouts
- [ ] Dashboard mostrando pageviews ao acessar os sites

---

## Por que Umami e não Google Analytics

| | Google Analytics | Umami |
|---|---|---|
| Dados | Google | Seu servidor |
| Cookies | Sim | Não |
| Banner LGPD | Obrigatório | Desnecessário |
| Custo | "Grátis" (seus dados são o produto) | Grátis (open source) |
| Peso do script | ~45KB | ~2KB |
