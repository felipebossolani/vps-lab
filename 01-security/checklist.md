# EP01 — Checklist de Segurança

Use esse checklist antes e depois de rodar o `setup.sh`.

---

## Antes de rodar (na sua máquina local)

- [ ] Gerar par de chaves SSH:
  ```bash
  ssh-keygen -t ed25519 -C "vpslab" -f ~/.ssh/vpslab
  ```
- [ ] Copiar a chave pública para usar no script:
  ```bash
  cat ~/.ssh/vpslab.pub
  ```
- [ ] Anotar o IP do servidor (entregue pelo provider)
- [ ] Testar acesso inicial como root:
  ```bash
  ssh root@SEU_IP
  ```

---

## Depois de rodar o setup.sh

- [ ] **Teste acesso com novo usuário ANTES de sair da sessão root:**
  ```bash
  ssh -i ~/.ssh/vpslab deploy@SEU_IP
  ```
- [ ] Confirmar que login root está bloqueado:
  ```bash
  ssh root@SEU_IP  # deve ser recusado
  ```
- [ ] Verificar status do UFW:
  ```bash
  sudo ufw status verbose
  ```
- [ ] Verificar status do fail2ban:
  ```bash
  sudo fail2ban-client status sshd
  ```
- [ ] Verificar atualizações automáticas:
  ```bash
  sudo systemctl status unattended-upgrades
  ```
- [ ] Confirmar portas abertas:
  ```bash
  sudo ss -tlnp
  ```

---

## Configuração local recomendada (~/.ssh/config)

Adicione no arquivo `~/.ssh/config` da sua máquina para facilitar o acesso:

```
Host vpslab
  HostName SEU_IP
  User deploy
  IdentityFile ~/.ssh/vpslab
  Port 22
```

Depois é só:
```bash
ssh vpslab
```

---

## O que foi configurado

| Item | Configuração |
|------|-------------|
| Usuário | `deploy` (não-root, com sudo) |
| Autenticação SSH | Somente chave Ed25519 |
| Login root SSH | `PermitRootLogin no` |
| Login por senha | `PasswordAuthentication no` |
| Firewall | UFW: allow 22, 80, 443, 8000 |
| Brute-force | fail2ban: 3 tentativas → ban 24h |
| Atualizações | unattended-upgrades: security only |

---

## Troubleshooting

**Travei meu próprio acesso (clássico)**
- Acesse pelo console web do provider (Bork Cloud tem console de emergência)
- Restaure o sshd_config: `cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config`
- Reinicie SSH: `systemctl restart sshd`

**fail2ban baniu meu próprio IP**
```bash
sudo fail2ban-client set sshd unbanip SEU_IP
```

**Ver IPs banidos atualmente**
```bash
sudo fail2ban-client status sshd
```

**Verificar log de tentativas de acesso**
```bash
sudo journalctl -u ssh --since "1 hour ago"
```
