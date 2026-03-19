---
title: "EP02 — Coolify: PaaS self-hosted na VPS"
description: "Instalação do Coolify como alternativa self-hosted ao Railway, Render e Vercel. Deploy automático, SSL e domínios customizados."
date: 2026-03-14
tags: ["coolify", "docker", "paas", "deploy"]
---

## O problema

Preciso de uma forma simples de fazer deploy de aplicações na VPS sem configurar Nginx, Certbot e systemd na mão para cada projeto.

## O que é o Coolify

PaaS open-source que roda na própria VPS. Faz o que Railway, Render e Fly.io fazem, mas rodando no seu hardware. Interface web, deploy via GitHub, SSL automático via Let's Encrypt, domínios customizados.

## Instalação

Uma linha:

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

Após ~3 minutos, o painel fica acessível na porta 8000. A partir daí, tudo pelo browser.

## O que deu errado

### PermitRootLogin

O Coolify precisa de acesso root local para gerenciar containers Docker. O script de instalação tenta conectar via SSH no próprio servidor. Se `PermitRootLogin` estiver `no` (como o EP01 configura), a instalação falha.

Fix: liberar `PermitRootLogin` apenas para localhost.

### UFW bloqueando bridges Docker

O Docker cria bridges de rede que o UFW pode bloquear. Containers não conseguem se comunicar entre si.

Fix: regras UFW específicas para a subnet Docker.

### IPv6

O Coolify tenta resolver dependências via IPv6. Em VPS sem IPv6 configurado, timeout.

Fix: desabilitar resolução IPv6 no Docker daemon.

## Código

[github.com/felipebossolani/vps-lab/tree/main/02-coolify](https://github.com/felipebossolani/vps-lab/tree/main/02-coolify)
