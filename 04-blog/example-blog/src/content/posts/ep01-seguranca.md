---
title: "EP01 — Segurança: hardening antes de qualquer deploy"
description: "SSH por chave, UFW, fail2ban e usuário deploy. O mínimo antes de colocar qualquer coisa no ar."
date: 2026-03-12
tags: ["seguranca", "ssh", "ufw", "fail2ban"]
---

## O problema

VPS nova, root aberto, sem firewall. Qualquer bot na internet consegue tentar brute force no SSH.

## O que fiz

O script `setup.sh` do EP01 automatiza tudo em sequência:

1. Criar usuário `deploy` com sudo
2. Copiar chave SSH e desabilitar login por senha
3. Desabilitar root login via SSH
4. Instalar e configurar UFW (apenas portas 22, 80, 443)
5. Instalar e configurar fail2ban para SSH

```bash
ssh root@SEU_IP 'bash -s' < setup.sh
```

## Decisões

- **Usuário `deploy` em vez de root** — menor superfície de ataque. Root fica bloqueado via SSH.
- **Chave SSH sem senha** — mais seguro que senha, mais prático que senha + 2FA para automação.
- **fail2ban com ban de 1h após 3 tentativas** — agressivo o suficiente para bots, tolerante para erros humanos.

## O que deu errado

O script precisa ser compatível com o que vem depois. No EP02, o Coolify precisa de portas específicas e bridges Docker que o UFW pode bloquear. O setup.sh já considera isso.

## Código

[github.com/felipebossolani/vps-lab/tree/main/01-security](https://github.com/felipebossolani/vps-lab/tree/main/01-security)
