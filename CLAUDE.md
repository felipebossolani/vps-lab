# CLAUDE.md — vps-lab

Repositório público da série **vps-lab**.
Contém scripts, código, checklists e documentação técnica de cada episódio.

---

## Dois repositórios

| Repo | Visibilidade | Conteúdo |
|------|-------------|----------|
| [vps-lab](https://github.com/felipebossolani/vps-lab) | Público | Scripts, código, checklists, docs técnicos |
| [vps-lab-content](https://github.com/felipebossolani/vps-lab-content) | Privado | Rascunhos de posts, prints, controle editorial |

---

## Contexto

- **Autor:** Felipe Bossolani
- **Provider VPS:** Bork Cloud (nacional 🇧🇷)
- **OS:** Ubuntu 24.04
- **PaaS:** Coolify (self-hosted)
- **Domínio:** vpslab.dev (placeholder — substituir pelo real)
- **Usuário SSH:** `deploy` (root bloqueado via SSH)

## Estrutura

```
vps-lab/
├── 01-security/          ← EP01: hardening (setup.sh)
├── 02-coolify/           ← EP02: instalação Coolify
├── 03-static-sites/      ← EP03: site Astro
├── 04-blog/              ← EP04: blog Astro
├── 05-backend-with-db/   ← EP05: API Node.js + PostgreSQL
├── 06-observability/     ← EP06: Grafana + Loki + Uptime Kuma
├── 07-cost-analysis/     ← EP07: comparativo de custos
└── docs/
    ├── architecture.md
    └── lessons-learned.md
```

## Instruções para Claude Code

- Scripts devem ser idempotentes e ter `set -euo pipefail`
- Output colorido com seções claras (o usuário roda no servidor real)
- Nunca incluir IPs reais, senhas ou chaves nos arquivos
- `vpslab.dev` é placeholder — não substituir automaticamente
- `lessons-learned.md` deve ser atualizado após cada episódio concluído
- O README.md principal tem badges e tabela de status dos episódios — manter atualizado
