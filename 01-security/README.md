# EP01 — Segurança: Hardening do servidor

> Antes de instalar qualquer coisa, o servidor precisa estar seguro.

---

## O que esse episódio cobre

- Criação de usuário não-root com sudo
- Autenticação SSH exclusivamente por chave (sem senha)
- Bloqueio de login root via SSH
- Firewall com UFW
- Proteção contra brute-force com fail2ban
- Atualizações automáticas de segurança

## Como usar

**1. Na sua máquina local**, gere o par de chaves SSH:
```bash
ssh-keygen -t ed25519 -C "vpslab" -f ~/.ssh/vpslab
```

**2. Acesse o servidor como root** (primeira e última vez):
```bash
ssh root@SEU_IP
```

**3. Baixe e execute o script** passando o nome do usuário e sua chave pública:
```bash
curl -fsSL https://raw.githubusercontent.com/felipebossolani/vps-lab/main/01-security/setup.sh -o setup.sh

bash setup.sh deploy "$(cat ~/.ssh/vpslab.pub)"
```

**4. Antes de fechar a sessão root**, teste o novo acesso em outro terminal:
```bash
ssh -i ~/.ssh/vpslab deploy@SEU_IP
```

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `setup.sh` | Script de hardening — roda tudo em sequência |
| `checklist.md` | O que verificar antes e depois |

## Post da série

🔗 [LinkedIn — EP01](https://linkedin.com/in/felipebossolani)
