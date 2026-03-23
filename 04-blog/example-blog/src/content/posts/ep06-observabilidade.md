---
title: "EP06 — Observabilidade: saber que algo quebrou antes de alguém perguntar"
description: "Grafana, Prometheus, Loki, Uptime Kuma — stack de observabilidade self-hosted com um único docker-compose."
date: 2026-03-19
tags: ["grafana", "prometheus", "loki", "uptime-kuma", "observabilidade"]
---

## O problema

Tenho VPS, site, blog e API rodando. Como sei que está tudo funcionando às 3 da manhã? Sem observabilidade, só descubro que algo quebrou quando alguém pergunta "seu site está fora?".

## Stack

Um único docker-compose sobe 6 serviços:

- **Grafana** — dashboards de métricas e logs
- **Prometheus** — coleta métricas dos containers e do host a cada 15s
- **Node Exporter** — expõe métricas do host (CPU, memória, disco, rede)
- **Loki** — agrega logs de todos os containers Docker
- **Promtail** — agente que coleta logs dos containers e envia para o Loki
- **Uptime Kuma** — status page pública

Tudo na rede `vpslab-monitoring`, sem nenhum serviço exposto diretamente — Grafana e Uptime Kuma acessíveis via Traefik com HTTPS.

## Deploy no Coolify

O deploy é via **Docker Compose conectado ao GitHub** — mesmo repo `felipebossolani/vps-lab`, Base Directory `/06-observability`. O Coolify puxa o docker-compose junto com os arquivos de config (`prometheus.yml`, `promtail-config.yml`) e sobe todos os serviços de uma vez.

Domínios são configurados individualmente:
- `grafana.vpslab.com.br` — dashboards (protegido por login)
- `status.vpslab.com.br` — status page (público)

Variáveis de ambiente da stack: `GRAFANA_USER` e `GRAFANA_PASSWORD`.

## Grafana + Node Exporter

O dashboard 1860 (Node Exporter Full) vem pronto — importa o ID no Grafana e já tem:

- CPU por core
- Memória usada/livre
- Disco: uso e I/O
- Rede: tráfego de entrada e saída

Tudo em tempo real, sem criar nada do zero.

## Loki + Promtail

O Promtail coleta logs de todos os containers Docker automaticamente (monta `/var/lib/docker/containers` como read-only).

No Grafana, com Loki como data source:
- Filtro por container: `{container_name="shortener-api"}`
- Filtro por nível: error, warn, info
- Filtro por janela de tempo

Sem precisar fazer SSH para ler logs.

## Uptime Kuma

Status page pública em `status.vpslab.com.br`. Monitora cada serviço individualmente:

| Monitor | URL |
|---------|-----|
| Site | `https://vpslab.com.br` |
| Blog | `https://blog.vpslab.com.br` |
| API | `https://api.vpslab.com.br/health` |
| Coolify | `https://coolify.vpslab.com.br` |
| Grafana | `https://grafana.vpslab.com.br` |

Histórico de 90 dias, badge de uptime para o README, alertas por push/email/Telegram/Slack.

## Pontos de atenção

### Docker Compose via GitHub no Coolify

O Coolify suporta Docker Compose conectado ao GitHub — aponta o Base Directory e ele puxa o docker-compose junto com os arquivos referenciados. Todos os serviços sobem juntos e compartilham a mesma rede.

### Bind mounts relativos não funcionam no Coolify

Se o docker-compose usa `./prometheus.yml:/etc/prometheus/prometheus.yml:ro`, o deploy falha. O Coolify clona o repo num diretório interno (`/data/coolify/applications/...`) e o Docker não encontra os arquivos no path esperado.

A solução: criar um Dockerfile mínimo que faz `COPY` do config durante o build:

```dockerfile
FROM prom/prometheus:latest
COPY prometheus.yml /etc/prometheus/prometheus.yml
```

No docker-compose, trocar `image:` por `build:`. Dois arquivos de 2 linhas cada (um pro Prometheus, outro pro Promtail) e o problema sumiu.

### Data sources usam hostname interno

No Grafana, os data sources apontam para `http://prometheus:9090` e `http://loki:3100` — hostname do container, não localhost. Funciona porque estão na mesma rede Docker.

### Promtail precisa de acesso aos logs do Docker

O volume `/var/lib/docker/containers` é montado como read-only. Sem isso, o Promtail não consegue coletar logs dos outros containers.

## Código

[github.com/felipebossolani/vps-lab/tree/main/06-observability](https://github.com/felipebossolani/vps-lab/tree/main/06-observability)
