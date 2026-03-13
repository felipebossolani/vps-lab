# EP02 — Checklist pós-instalação do Coolify

---

## DNS — Fazer antes de instalar

Configure esses registros no painel do seu registrador de domínio (ou Cloudflare):

| Tipo | Nome | Valor | TTL |
|------|------|-------|-----|
| A | `coolify` | `SEU_IP` | 300 |
| A | `site` | `SEU_IP` | 300 |
| A | `blog` | `SEU_IP` | 300 |
| A | `api` | `SEU_IP` | 300 |
| A | `status` | `SEU_IP` | 300 |
| A | `grafana` | `SEU_IP` | 300 |

> Dica: Se usar Cloudflare, deixe o proxy (laranjinha) **desativado** inicialmente para facilitar a emissão do certificado SSL.

---

## Primeiro acesso ao painel

- [ ] Acesse `http://SEU_IP:8000`
- [ ] Crie conta admin (usuário + senha fortes)
- [ ] Anote as credenciais em local seguro

---

## Configurar domínio do painel

- [ ] Settings → Instance → Domain
- [ ] Preencher: `https://coolify.vpslab.com.br`
- [ ] Salvar e aguardar SSL (pode levar 1-2 minutos)
- [ ] Testar acesso em `https://coolify.vpslab.com.br`
- [ ] Fechar porta 8000 após confirmar HTTPS:
  ```bash
  sudo ufw delete allow 8000/tcp
  sudo ufw status
  ```

---

## Configurar chave SSH do Coolify (para gerenciar o próprio servidor)

O Coolify gera uma chave SSH própria durante a instalação para se comunicar com o servidor host.

- [ ] Verificar se a chave foi gerada:
  ```bash
  ls /data/coolify/ssh/keys/
  # deve existir: id.root@host.docker.internal
  ```
- [ ] No painel: Keys & Tokens → SSH Keys → verificar se a chave do host está listada
- [ ] Servers → localhost → validar conexão

---

## Configurar backup do Coolify

- [ ] Settings → Backup
- [ ] Configurar S3-compatible (Cloudflare R2, Backblaze B2 ou similar)
- [ ] Testar backup manual

---

## Checklist de segurança pós-Coolify

- [ ] Porta 8000 fechada no UFW (após configurar domínio)
- [ ] HTTPS funcionando em `coolify.vpslab.com.br`
- [ ] Login root SSH ainda desabilitado (confirmar):
  ```bash
  sudo grep PermitRootLogin /etc/ssh/sshd_config
  # deve retornar: PermitRootLogin no
  ```
- [ ] fail2ban ainda ativo:
  ```bash
  sudo fail2ban-client status
  ```

---

## Arquitetura após EP02

```
Internet
    │
    ▼
[UFW: 80, 443 abertos]
    │
    ▼
[Traefik — reverse proxy do Coolify]
    │
    ├── coolify.vpslab.com.br  →  Coolify UI
    └── (próximos apps virão aqui)

[Coolify] ←→ [Docker socket] ←→ [Containers]
```

---

## Trocar domínio no futuro

Quando quiser apontar para outro domínio (ex: `coolify.bossolani.com`):

1. Crie o registro DNS apontando para o mesmo IP
2. No painel Coolify: Settings → Instance → Domain → novo domínio
3. Coolify emite novo certificado SSL automaticamente
4. O domínio antigo para de funcionar (Traefik atualiza as rotas)

Cada app deployada tem domínio configurado individualmente — não são afetadas.
