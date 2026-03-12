# 🖥️ vps-lab

Série pública documentando a construção de uma infraestrutura self-hosted completa com VPS + Coolify.

Cada episódio tem script pronto para rodar, checklist e post publicado no LinkedIn e Twitter.

> **VPS:** Ubuntu 24.04 · **PaaS:** Coolify · **Domínio:** vpslab.dev

---

## 📅 Episódios

| EP | Tema | Status |
|----|------|--------|
| [01 — Segurança](./01-security/) | Hardening do servidor antes de instalar qualquer coisa | ✅ |
| [02 — Coolify](./02-coolify/) | Instalação do Coolify + domínio + SSL automático | 🔜 |
| [03 — Site Estático](./03-static-sites/) | Deploy de site Astro com CI/CD via GitHub | 🔜 |
| [04 — Blog](./04-blog/) | Blog com Astro + deploy automatizado | 🔜 |
| [05 — Backend + DB](./05-backend-with-db/) | API Node.js + PostgreSQL gerenciado pelo Coolify | 🔜 |
| [06 — Observabilidade](./06-observability/) | Grafana + Loki + Prometheus + Uptime Kuma | 🔜 |
| [07 — Custo & Balanço](./07-cost-analysis/) | Quanto custa vs SaaS equivalente | 🔜 |

---

## 🗺️ Arquitetura

```
vpslab.dev
├── coolify.vpslab.dev     → Painel Coolify (HTTPS automático)
├── site.vpslab.dev        → Site estático Astro
├── blog.vpslab.dev        → Blog Astro
├── api.vpslab.dev         → API encurtador de URLs (Node + PostgreSQL)
├── status.vpslab.dev      → Uptime Kuma (público)
└── grafana.vpslab.dev     → Grafana (protegido)
```

---

## 🔐 Premissas de segurança

- Acesso SSH apenas via chave (sem senha)
- Login root via SSH desabilitado
- UFW habilitado com regras mínimas
- fail2ban protegendo SSH
- Atualizações de segurança automáticas
- Coolify acessa o servidor via chave SSH própria

---

## 📣 Acompanhe a série

- LinkedIn: [linkedin.com/in/felipebossolani](https://linkedin.com/in/felipebossolani)
- GitHub: [github.com/felipebossolani/vps-lab](https://github.com/felipebossolani/vps-lab)

---

## 🧰 Stack utilizada

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)
![Coolify](https://img.shields.io/badge/Coolify-self--hosted-6C47FF)
![Docker](https://img.shields.io/badge/Docker-latest-2496ED?logo=docker&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=node.js&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![Astro](https://img.shields.io/badge/Astro-latest-FF5D01?logo=astro&logoColor=white)
