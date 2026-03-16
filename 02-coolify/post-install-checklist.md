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

## Onboarding

- [ ] Selecione "This Machine" no Choose Server Type
- [ ] Aguarde validação do servidor (deve conectar via SSH)
- [ ] Confirme "Setup Complete" com todos os checks verdes

> Se aparecer "Connection refused" na validação, execute o script de fix:
> `sudo bash fix-coolify-bridge.sh`

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

> Se o Traefik não subir (erro de IPv6/ParseAddr), execute o script de fix:
> `sudo bash fix-coolify-bridge.sh`

---

## Configurar chave SSH do Coolify (para gerenciar o próprio servidor)

O Coolify gera uma chave SSH própria durante a instalação para se comunicar com o servidor host.

- [ ] Verificar se a chave foi gerada:
  ```bash
  ls /data/coolify/ssh/keys/
  ```
- [ ] No painel: Keys & Tokens → SSH Keys → verificar se a chave do host está listada
- [ ] Servers → localhost → validar conexão

---

## Checklist de segurança pós-Coolify

- [ ] Porta 8000 fechada no UFW (após configurar domínio)
- [ ] HTTPS funcionando em `coolify.vpslab.com.br`
- [ ] Login root SSH por chave apenas (confirmar):
  ```bash
  sudo grep PermitRootLogin /etc/ssh/sshd_config
  # deve retornar: PermitRootLogin prohibit-password
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

## Troubleshooting

### "Connection refused" na validação do servidor
O container Coolify não alcança o SSH do host. Causa: UFW bloqueia tráfego Docker-to-host.
```bash
sudo bash fix-coolify-bridge.sh
```

### Traefik não sobe (erro ParseAddr IPv6)
O Coolify cria a rede Docker com gateway IPv6 em formato inválido. O fix-coolify-bridge.sh recria a rede sem IPv6.
```bash
sudo bash fix-coolify-bridge.sh
```

### Proxy aparece como "RUNNING" mas não existe container
Reinicie o proxy pelo painel: Servers → localhost → Proxy → Start.

---

## Trocar domínio no futuro

Quando quiser apontar para outro domínio (ex: `coolify.bossolani.com`):

1. Crie o registro DNS apontando para o mesmo IP
2. No painel Coolify: Settings → Instance → Domain → novo domínio
3. Coolify emite novo certificado SSL automaticamente
4. O domínio antigo para de funcionar (Traefik atualiza as rotas)

Cada app deployada tem domínio configurado individualmente — não são afetadas.
