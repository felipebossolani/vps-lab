#!/usr/bin/env bash
# =============================================================================
# vps-lab — EP02: Fix Coolify + UFW (Docker bridge connectivity)
# Ubuntu 24.04
#
# PROBLEMA:
#   Coolify roda em container Docker e precisa conectar no SSH do host via
#   host.docker.internal. Com UFW ativo (policy DROP no INPUT), o tráfego
#   Docker-to-host é bloqueado e o Coolify não consegue gerenciar o servidor.
#
# CAUSA:
#   O container Coolify roda na rede Docker customizada "coolify" (10.0.1.0/24).
#   O host.docker.internal resolve para 10.0.0.1 (docker0), mas o container
#   não tem rota para essa interface. Conectar à rede bridge padrão resolve.
#
# SOLUÇÃO:
#   1. Corrige rede Docker com IPv6 inválido (se existir)
#   2. Conecta o container Coolify à rede bridge padrão do Docker
#   3. Cria serviço systemd para persistir após restarts
#   4. Adiciona regra no UFW para aceitar tráfego de bridges Docker
#
# QUANDO USAR:
#   Se após instalar o Coolify com UFW ativo, o painel mostrar:
#   "ssh: connect to host host.docker.internal port 22: Connection refused"
#   ou o Traefik não subir com erro de ParseAddr IPv6.
#
# COMO USAR:
#   sudo bash fix-coolify-bridge.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error(){ echo -e "${RED}[✗]${NC} $1"; exit 1; }

[[ $EUID -ne 0 ]] && error "Execute como root: sudo bash fix-coolify-bridge.sh"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  vps-lab — Fix: Coolify + UFW bridge connection  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# 1. Corrige rede Docker com IPv6 inválido (gateway com /64)
if docker network inspect coolify --format '{{json .IPAM.Config}}' 2>/dev/null | grep -q '/64"'; then
    warn "Rede coolify com IPv6 inválido detectada — recriando..."

    docker compose -f /data/coolify/source/docker-compose.yml \
                   -f /data/coolify/source/docker-compose.prod.yml down 2>/dev/null || true

    docker network rm coolify 2>/dev/null || true
    docker network create coolify --driver bridge --subnet 10.0.1.0/24 --gateway 10.0.1.1
    log "Rede coolify recriada (sem IPv6 corrompido)"

    docker compose -f /data/coolify/source/docker-compose.yml \
                   -f /data/coolify/source/docker-compose.prod.yml up -d
    log "Containers Coolify reiniciados"

    echo "Aguardando containers..."
    sleep 15
else
    log "Rede coolify sem problema de IPv6"
fi

# 2. Conecta o container à rede bridge padrão
if docker network connect bridge coolify 2>/dev/null; then
    log "Container coolify conectado à rede bridge"
else
    warn "Container já está na rede bridge (OK)"
fi

# 3. Verifica conectividade
if docker exec coolify nc -z -w3 host.docker.internal 22 2>/dev/null; then
    log "Conectividade SSH host.docker.internal OK"
else
    error "Ainda sem conectividade. Verifique se o SSH está rodando no host."
fi

# 4. Cria serviço systemd para persistir
cat > /etc/systemd/system/coolify-bridge-fix.service << 'UNIT'
[Unit]
Description=Connect Coolify container to default bridge network
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c 'until docker inspect coolify >/dev/null 2>&1; do sleep 2; done'
ExecStart=/bin/bash -c '/usr/bin/docker network connect bridge coolify 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable coolify-bridge-fix.service >/dev/null 2>&1
log "Serviço systemd criado e habilitado (coolify-bridge-fix.service)"

# 5. Adiciona regra UFW para bridges Docker (se não existir)
if ! grep -q "ufw-before-input -i br+" /etc/ufw/before.rules 2>/dev/null; then
    cp /etc/ufw/before.rules /etc/ufw/before.rules.bak
    sed -i '/-A ufw-before-input -i lo -j ACCEPT/a -A ufw-before-input -i br+ -j ACCEPT' /etc/ufw/before.rules
    ufw reload >/dev/null 2>&1
    log "Regra UFW adicionada para bridges Docker"
else
    warn "Regra UFW para bridges Docker já existe (OK)"
fi

# 6. Sobe o proxy (Traefik) se não estiver rodando
if ! docker ps | grep -q coolify-proxy; then
    warn "Traefik não está rodando — subindo..."
    cd /data/coolify/proxy && docker compose up -d 2>/dev/null && cd ~
    if docker ps | grep -q coolify-proxy; then
        log "Traefik iniciado com sucesso"
    else
        warn "Traefik não subiu. Verifique: docker logs coolify-proxy"
    fi
else
    log "Traefik já está rodando"
fi

echo ""
log "Fix aplicado com sucesso!"
echo ""
echo "  Valide no painel do Coolify: Servers → localhost → Validate"
echo ""
