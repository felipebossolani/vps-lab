# EP03 — Deploy de Site Estático com Coolify

---

## Pré-requisitos

- Coolify instalado e funcionando (EP02)
- Repositório no GitHub com o site Astro
- DNS configurado: `site.vpslab.dev → SEU_IP`

---

## Configurando o deploy no Coolify

### 1. Conectar GitHub ao Coolify

No painel Coolify:
1. **Settings → Source → GitHub**
2. Instalar o **Coolify GitHub App** no seu repositório
3. Autorizar acesso ao repo `vps-lab`

### 2. Criar nova aplicação

1. **Projects → New Project → New Application**
2. Selecionar **GitHub** como source
3. Repositório: `felipebossolani/vps-lab`
4. Branch: `main`
5. **Build Pack:** `Nixpacks` (detecta Astro automaticamente)

### 3. Configurações da aplicação

| Campo | Valor |
|-------|-------|
| Base Directory | `/03-static-sites/example-astro` |
| Build Command | `npm run build` |
| Publish Directory | `dist` |
| Port | `4321` (dev) — não necessário para site estático |

### 4. Domínio e SSL

1. Na aba **Domains**
2. Adicionar: `https://site.vpslab.dev`
3. Coolify + Traefik emitem SSL automaticamente via Let's Encrypt

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
- Confirme que o DNS está propagado: `dig site.vpslab.dev`
- Coolify usa Let's Encrypt com desafio HTTP — porta 80 precisa estar aberta

**Deploy não trigou automaticamente**
- Verifique se o GitHub App está instalado no repositório
- Aba Webhooks no GitHub: `Settings → Webhooks` — deve ter um webhook do Coolify
