#!/usr/bin/env bash
# =============================================================================
# vps-lab — EP01: Hardening do servidor
# Ubuntu 24.04 | Testado em Bork Cloud
#
# O QUE ESSE SCRIPT FAZ:
#   1. Atualiza o sistema
#   2. Cria usuário não-root com sudo (pede para definir senha)
#   3. Configura chave SSH para o novo usuário
#   4. Endurece SSH (root só por chave, senha desabilitada)
#   5. Configura UFW (firewall) — compatível com Docker/Coolify
#   6. Instala e configura fail2ban
#   7. Habilita atualizações automáticas de segurança
#
# COMPATIBILIDADE:
#   Esse script foi desenhado para funcionar COM Docker e Coolify.
#   O PermitRootLogin usa "prohibit-password" (chave sim, senha não),
#   porque o Coolify precisa de SSH root local via chave.
#   O UFW inclui regras para tráfego Docker-to-host não ser bloqueado.
#
# COMO USAR:
#   1. Na SUA MÁQUINA LOCAL, gere um par de chaves SSH (se ainda não tiver):
#      ssh-keygen -t ed25519 -C "vpslab" -f ~/.ssh/vpslab
#
#   2. Copie a chave pública gerada:
#      cat ~/.ssh/vpslab.pub
#
#   3. Acesse o servidor como root (primeira e última vez):
#      ssh root@IP_DO_SEU_VPS
#
#   4. Execute esse script passando o usuário e a chave pública:
#      bash setup.sh deploy "ssh-ed25519 AAAA... vpslab"
#
# PARÂMETROS:
#   $1 = nome do usuário a criar (ex: deploy)
#   $2 = chave pública SSH completa entre aspas
#
# IDEMPOTENTE: pode rodar mais de uma vez sem efeitos colaterais
# =============================================================================

set -euo pipefail

# --- Cores para output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# --- Validações iniciais ---
[[ $EUID -ne 0 ]] && error "Execute como root: sudo bash setup.sh"
[[ $# -lt 2 ]]   && error "Uso: bash setup.sh <usuario> \"<chave-ssh-publica>\""

NEW_USER="$1"
SSH_PUBLIC_KEY="$2"
SSH_PORT=22  # Altere aqui se quiser trocar a porta SSH (ex: 2222)

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       vps-lab — EP01: Hardening          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
warn "Usuário a criar: ${NEW_USER}"
warn "Porta SSH: ${SSH_PORT}"
echo ""

# =============================================================================
# PASSO 1: Atualizar o sistema
# =============================================================================
section "1/7 Atualizando o sistema"

apt-get update -qq
apt-get upgrade -y -qq
apt-get autoremove -y -qq
log "Sistema atualizado"

# =============================================================================
# PASSO 2: Criar usuário não-root
# =============================================================================
section "2/7 Criando usuário ${NEW_USER}"

if id "$NEW_USER" &>/dev/null; then
    warn "Usuário ${NEW_USER} já existe — pulando criação"
else
    adduser --disabled-password --gecos "" "$NEW_USER"
    log "Usuário ${NEW_USER} criado"
fi

# Garantir que está no grupo sudo
usermod -aG sudo "$NEW_USER"
log "Usuário ${NEW_USER} adicionado ao grupo sudo"

# Definir senha para o usuário (necessária para sudo)
warn "Defina a senha do usuário ${NEW_USER} (usada apenas para sudo):"
passwd "$NEW_USER"
log "Senha definida para ${NEW_USER}"

# =============================================================================
# PASSO 3: Configurar chave SSH para o novo usuário
# =============================================================================
section "3/7 Configurando chave SSH"

USER_HOME="/home/${NEW_USER}"
SSH_DIR="${USER_HOME}/.ssh"

mkdir -p "$SSH_DIR"

# Adiciona a chave se ainda não estiver lá
if ! grep -qF "$SSH_PUBLIC_KEY" "${SSH_DIR}/authorized_keys" 2>/dev/null; then
    echo "$SSH_PUBLIC_KEY" >> "${SSH_DIR}/authorized_keys"
    log "Chave SSH adicionada"
else
    warn "Chave SSH já presente — pulando"
fi

chmod 700 "$SSH_DIR"
chmod 600 "${SSH_DIR}/authorized_keys"
chown -R "${NEW_USER}:${NEW_USER}" "$SSH_DIR"
log "Permissões do diretório SSH configuradas"

# =============================================================================
# PASSO 4: Configurar SSH — root só por chave, senha desabilitada
# =============================================================================
section "4/7 Endurecendo configuração SSH"

SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup da config original (apenas na primeira vez)
if [[ ! -f "${SSHD_CONFIG}.bak" ]]; then
    cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"
    log "Backup de sshd_config criado em ${SSHD_CONFIG}.bak"
fi

# Função para setar ou adicionar diretiva no sshd_config
set_sshd() {
    local key="$1"
    local value="$2"
    if grep -qE "^#?${key}" "$SSHD_CONFIG"; then
        sed -i "s|^#\?${key}.*|${key} ${value}|" "$SSHD_CONFIG"
    else
        echo "${key} ${value}" >> "$SSHD_CONFIG"
    fi
}

set_sshd "Port"                    "$SSH_PORT"
set_sshd "PermitRootLogin"         "prohibit-password"  # chave sim, senha não (Coolify precisa)
set_sshd "PasswordAuthentication"  "no"                  # somente chave SSH
set_sshd "PubkeyAuthentication"    "yes"
set_sshd "AuthorizedKeysFile"      ".ssh/authorized_keys"
set_sshd "X11Forwarding"           "no"
set_sshd "AllowTcpForwarding"      "no"
set_sshd "MaxAuthTries"            "3"
set_sshd "LoginGraceTime"          "20"
set_sshd "ClientAliveInterval"     "300"
set_sshd "ClientAliveCountMax"     "2"

# Remove overrides do cloud-init que podem sobrescrever nossas configs
if [[ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]]; then
    rm /etc/ssh/sshd_config.d/50-cloud-init.conf
    warn "Removido override do cloud-init (50-cloud-init.conf)"
fi

# Garante nossas configs via drop-in (maior prioridade)
cat > /etc/ssh/sshd_config.d/99-hardening.conf << SSHEOF
PasswordAuthentication no
PermitRootLogin prohibit-password
SSHEOF
log "Drop-in 99-hardening.conf criado"

# Valida a config antes de reiniciar
sshd -t && log "Configuração SSH válida"

systemctl restart ssh
log "SSH reconfigurado — root só por chave, senha desabilitada"

warn "IMPORTANTE: Abra um NOVO terminal e teste o acesso antes de sair!"
warn "  ssh -i ~/.ssh/vpslab -p ${SSH_PORT} ${NEW_USER}@\$(hostname -I | awk '{print \$1}')"

# =============================================================================
# PASSO 5: Configurar UFW (firewall) — compatível com Docker
# =============================================================================
section "5/7 Configurando UFW"

apt-get install -y -qq ufw

# Reseta regras sem interação
ufw --force reset

# Política padrão: negar tudo que entra, permitir tudo que sai
ufw default deny incoming
ufw default allow outgoing

# Regras básicas
ufw allow "$SSH_PORT"/tcp    comment 'SSH'
ufw allow 80/tcp             comment 'HTTP'
ufw allow 443/tcp            comment 'HTTPS'
ufw allow 8000/tcp           comment 'Coolify UI (remover após configurar domínio)'

# Docker-to-host: permite que containers acessem SSH do host
# Necessário para Coolify gerenciar o servidor via host.docker.internal
ufw allow from 172.16.0.0/12 to any port "$SSH_PORT" proto tcp comment 'Docker bridge to host SSH'
ufw allow from 10.0.0.0/8 to any port "$SSH_PORT" proto tcp comment 'Docker overlay to host SSH'

# Permite forward de tráfego Docker (containers se comunicando)
# Sem isso, Docker custom bridge networks não funcionam com UFW
sed -i 's/^DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
log "Forward policy ajustada para ACCEPT (Docker)"

# Permite tráfego de bridges Docker no INPUT (host.docker.internal)
if ! grep -q "ufw-before-input -i br+" /etc/ufw/before.rules 2>/dev/null; then
    sed -i '/-A ufw-before-input -i lo -j ACCEPT/a -A ufw-before-input -i br+ -j ACCEPT' /etc/ufw/before.rules
    log "Regra para bridges Docker adicionada em before.rules"
else
    warn "Regra para bridges Docker já existe em before.rules"
fi

# Habilita sem confirmação interativa
ufw --force enable
log "UFW habilitado"
ufw status verbose

# =============================================================================
# PASSO 6: Instalar e configurar fail2ban
# =============================================================================
section "6/7 Configurando fail2ban"

apt-get install -y -qq fail2ban

# Cria configuração local (não sobrescrita em atualizações)
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled  = true
port     = ${SSH_PORT}
logpath  = %(sshd_log)s
maxretry = 3
bantime  = 24h
EOF

systemctl enable fail2ban
systemctl restart fail2ban
log "fail2ban configurado — 3 tentativas erradas = ban de 24h"

# =============================================================================
# PASSO 7: Atualizações automáticas de segurança
# =============================================================================
section "7/7 Atualizações automáticas"

apt-get install -y -qq unattended-upgrades

cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF

systemctl enable unattended-upgrades
log "Atualizações automáticas de segurança habilitadas"

# =============================================================================
# RESUMO FINAL
# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║              ✅  Hardening concluído!                ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Usuário criado:       ${NEW_USER}"
echo "  Porta SSH:            ${SSH_PORT}"
echo "  Login root SSH:       SÓ POR CHAVE (prohibit-password)"
echo "  Login por senha:      DESABILITADO"
echo "  Firewall (UFW):       ATIVO (compatível com Docker)"
echo "  fail2ban:             ATIVO"
echo "  Auto security updates: ATIVO"
echo ""
echo -e "${YELLOW}⚠️  PRÓXIMO PASSO OBRIGATÓRIO:${NC}"
echo "  Abra um NOVO terminal e confirme que consegue acessar:"
echo ""
echo "  ssh -i ~/.ssh/vpslab -p ${SSH_PORT} ${NEW_USER}@SEU_IP"
echo ""
echo "  Só feche essa sessão depois de confirmar o acesso!"
echo ""
echo "  Próximo episódio: EP02 — Instalação do Coolify"
echo "  https://github.com/felipebossolani/vps-lab/tree/main/02-coolify"
echo ""
