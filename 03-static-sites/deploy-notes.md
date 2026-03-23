# EP03 — Deploy de Site Estático com Coolify

---

## Pré-requisitos

- Coolify instalado e funcionando (EP02)
- Repositório no GitHub com o site Astro
- DNS configurado: `vpslab.com.br → SEU_IP`

---

## Configurando o deploy no Coolify

### 1. Conectar GitHub ao Coolify

No painel Coolify:
1. **Sources → + Add**
2. Preencher **Name** (ex: "vpslab"), deixar **Organization** vazio
3. **Continue**
4. Ignorar "Manual Installation" — em **Automated Installation**, trocar Webhook Endpoint para o domínio HTTPS do Coolify
5. Clicar **Register Now** → GitHub abre para autorizar (nome do App fica `vpslab-SEUUSER`)
6. Voltar ao Coolify — campos preenchidos automaticamente

### 2. Criar nova aplicação

1. **Projects → New Project → New Application**
2. Selecionar **GitHub** como source
3. Repositório: `felipebossolani/vps-lab`
4. Branch: `main`
5. **Build Pack:** `Static` (não Nixpacks — o Astro gera HTML estático)

### 3. Configurações da aplicação

| Campo | Valor |
|-------|-------|
| Base Directory | `/03-static-sites/example-astro` |
| Build Command | `npm run build` |
| Publish Directory | `dist` |

> **Atenção:** O Astro com `output: 'static'` gera HTMLs em `dist/`. Use o build pack **Static**,
> não Nixpacks. Com Nixpacks o deploy completa mas dá 404.

### 4. Domínio e SSL

1. Na aba **Domains**
2. Substituir o domínio sslip.io por `https://vpslab.com.br`
3. Salvar e clicar **Redeploy** (obrigatório — as rotas do Traefik são geradas no deploy)
4. Coolify + Traefik emitem SSL automaticamente via Let's Encrypt

### 5. Deploy automático

1. Aba **General → Auto Deploy**: ✅ habilitado
2. A partir daqui: **push no GitHub = deploy automático**

---

## Estrutura do projeto Astro

```
example-astro/
├── astro.config.mjs     # output: static
├── package.json
└── src/
    ├── layouts/
    │   └── Layout.astro
    ├── components/
    │   └── Card.astro
    └── pages/
        └── index.astro
```

---

## Testando localmente antes do deploy

```bash
cd 03-static-sites/example-astro
npm install
npm run dev       # http://localhost:4321
npm run build     # gera /dist
```

---

## Troubleshooting

**Build falha no Coolify**
- Verifique o `Base Directory` — precisa apontar para onde está o `package.json`
- Logs de build disponíveis no painel Coolify

**SSL não emite**
- Confirme que o DNS está propagado: `dig vpslab.com.br`
- Coolify usa Let's Encrypt com desafio HTTP — porta 80 precisa estar aberta

**Deploy não trigou automaticamente**
- Verifique se o GitHub App está instalado no repositório
- Aba Webhooks no GitHub: `Settings → Webhooks` — deve ter um webhook do Coolify
