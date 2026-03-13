# Lições Aprendidas — vps-lab

Documento vivo. Atualizado a cada episódio.

---

## EP01 — Segurança

- **Testar acesso com novo usuário ANTES de fechar a sessão root.** Parece óbvio. Todo mundo esquece uma vez.
- Fail2ban bane o seu próprio IP se você errar a senha 3x testando. `fail2ban-client set sshd unbanip SEU_IP` salva vidas.
- O backup do `sshd_config` (`sshd_config.bak`) vale ouro se você travar o acesso.
- Bork Cloud (e a maioria dos providers) tem console web de emergência — use se precisar recuperar acesso.
- **No Ubuntu 24.04 o serviço SSH se chama `ssh.service`, não `sshd.service`** (diferente de CentOS/RHEL e versões anteriores do Ubuntu). O script original usava `systemctl reload sshd` e falhava com "Unit sshd.service not found". Fix: trocar por `systemctl reload ssh`.
- **cloud-init sobrescreve sshd_config silenciosamente.** Ubuntu 24.04 com cloud-init cria `/etc/ssh/sshd_config.d/50-cloud-init.conf` com `PasswordAuthentication yes`, que tem prioridade sobre o `sshd_config` principal. Fix: remover o arquivo e criar `99-hardening.conf` com nossas configs.
- **`systemctl reload ssh` nem sempre aplica todas as mudanças.** Usar `systemctl restart ssh` é mais seguro para garantir que as configs novas entrem em vigor.
- **`adduser --disabled-password` cria usuário sem senha — `sudo` não funciona.** O login SSH é por chave, mas `sudo` precisa de senha. Fix: adicionar `passwd deploy` no script logo após criar o usuário.

## EP02 — Coolify

- Coolify v4 exige root para instalação. Non-root é experimental e tem bugs conhecidos com permissões do proxy.
- A estratégia adotada: instalar como root, mas root não tem entrada SSH direta. Coolify usa chave própria.
- Fechar porta 8000 DEPOIS de confirmar HTTPS funcionando. Não antes.
- DNS precisa estar propagado antes de emitir o SSL. `dig coolify.vpslab.com.br` para confirmar.

## EP03 — Site Estático

- `Base Directory` no Coolify precisa apontar para onde está o `package.json`, não a raiz do repo.
- Nixpacks detecta Astro automaticamente — não precisa configurar build pack manualmente.

## EP04 — Blog

- (a preencher)

## EP05 — Backend + DB

- A connection string **interna** do Coolify usa o nome do container como hostname — não o IP do servidor.
- Nunca expor porta do PostgreSQL publicamente. Coolify facilita isso — basta não marcar "Publicly Accessible".
- Multi-stage Dockerfile reduz imagem final significativamente (sem devDependencies, sem cache do npm).

## EP06 — Observabilidade

- (a preencher)

## EP07 — Custo & Balanço

- (a preencher)
