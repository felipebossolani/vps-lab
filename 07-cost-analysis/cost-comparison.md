# EP07 — Custo Real: VPS Self-hosted vs SaaS

---

## Comparativo mensal

| Serviço | SaaS equivalente | Custo SaaS | Self-hosted (VPS) |
|---------|-----------------|------------|-------------------|
| PaaS (deploy de apps) | Render / Railway Starter | ~$20/mês | ✅ incluso |
| Blog | Ghost Pro Starter | $25/mês | ✅ incluso |
| Encurtador de URLs | Bitly Premium | $35/mês | ✅ incluso |
| Monitoramento | Datadog Free (limitado) | $15+/mês | ✅ incluso |
| Status page | Statuspage.io | $29/mês | ✅ incluso (Uptime Kuma) |
| PostgreSQL gerenciado | Supabase Pro | $25/mês | ✅ incluso |
| **Total SaaS** | | **~$149/mês** | |
| **VPS (Bork Cloud)** | | | **~R$ 80-150/mês** |

---

## O que o SaaS ainda ganha

Ser honesto faz parte da série. Self-hosted não é bala de prata:

| Aspecto | SaaS | Self-hosted |
|---------|------|-------------|
| Tempo de setup | Minutos | Horas (na primeira vez) |
| Manutenção | Zero | Você (patches, backups) |
| SLA garantido | Sim | Você é o SLA |
| Escalabilidade automática | Sim | Manual |
| Suporte | Sim | Stack Overflow e você |
| Disaster recovery | Gerenciado | Você configura |

---

## Quando self-hosted faz sentido

✅ Side projects e labs sem SLA crítico
✅ Aprendizado real de infraestrutura
✅ Portfólio técnico público (como essa série)
✅ Múltiplos projetos pequenos — custo fixo não escala

❌ Produto em produção com usuários pagantes sem time de infra
❌ Quando seu tempo vale mais do que a diferença de custo
❌ Quando compliance exige SLAs contratuais

---

## Lições aprendidas na série

Veja o arquivo completo em [`docs/lessons-learned.md`](../docs/lessons-learned.md).

---

## Próximos passos desta infra

- [ ] Backup automatizado para S3-compatible (Cloudflare R2)
- [ ] Alertas por push via ntfy.sh
- [ ] Segundo servidor para alta disponibilidade
- [ ] Migrar um projeto real de produção
