#!/usr/bin/env bash
# =============================================================================
# vps-lab — EP02: Instalação do Coolify
# Ubuntu 24.04
#
# PRÉ-REQUISITOS:
#   - EP01 concluído (usuário deploy criado, firewall ativo)
#   - Domínio apontando para o IP do servidor (ex: coolify.vpslab.com.br → IP)
#   - Acesso como root (Coolify exige root para instalação)
#
# COMO USAR:
#   ssh vpslab                # acesse como deploy
#   sudo su -                 # eleve para root
#   bash install.sh
#
# NOTA SOBRE SEGURANÇA:
#   O Coolify precisa de root para instalar e gerenciar containers Docker.
#   Após a instalação, o acesso SSH diário continua sendo pelo usuário deploy.
#   Root aceita apenas chave SSH (prohibit-password) — senha bloqueada.
#   O Coolify usa chave SSH própria gerada na instalação para se comunicar
#   com o servidor via host.docker.internal.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

[[ $EUID -ne 0 ]] && error "Execute como root: sudo su - && bash install.sh"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     vps-lab — EP02: Instalação Coolify   ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# =============================================================================
# PASSO 1: Verificar pré-requisitos
# =============================================================================
section "1/5 Verificando pré-requisitos"

if ! grep -q "24.04" /etc/os-release; then
    warn "Este script foi testado no Ubuntu 24.04. Prosseguindo mesmo assim..."
fi

if ! curl -sf https://cdn.coollabs.io > /dev/null; then
    error "Sem acesso à internet. Verifique a conectividade."
fi

log "Pré-requisitos OK"

# =============================================================================
# PASSO 2: Garantir porta 8000 aberta no UFW (acesso inicial ao painel)
# =============================================================================
section "2/5 Liberando porta 8000 temporariamente"

if command -v ufw &>/dev/null; then
    ufw allow 8000/tcp comment 'Coolify UI inicial' 2>/dev/null || true
    log "Porta 8000 liberada no UFW"
fi

# =============================================================================
# PASSO 3: Instalar Coolify
# =============================================================================
section "3/5 Instalando Coolify"

warn "Isso vai levar alguns minutos..."
warn "O script oficial do Coolify irá instalar Docker e todos os componentes."
echo ""

curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

log "Coolify instalado com sucesso"

# =============================================================================
# PASSO 4: Fix da rede Docker (IPv6 gateway inválido)
# =============================================================================
section "4/5 Verificando rede Docker"

# O Coolify cria a rede "coolify" com um gateway IPv6 no formato inválido
# (ex: "fd73:ff0d:24c4::1/64" — o /64 no gateway causa erro no Traefik).
# Recriamos a rede sem IPv6 para evitar esse bug.
if docker network inspect coolify --format '{{json .IPAM.Config}}' 2>/dev/null | grep -q '/64"'; then
    warn "Rede coolify com IPv6 inválido detectada — recriando..."

    # Para containers
    docker compose -f /data/coolify/source/docker-compose.yml \
                   -f /data/coolify/source/docker-compose.prod.yml down 2>/dev/null || true

    # Remove e recria a rede sem IPv6
    docker network rm coolify 2>/dev/null || true
    docker network create coolify --driver bridge --subnet 10.0.1.0/24 --gateway 10.0.1.1
    log "Rede coolify recriada (sem IPv6 corrompido)"

    # Sobe containers novamente
    docker compose -f /data/coolify/source/docker-compose.yml \
                   -f /data/coolify/source/docker-compose.prod.yml up -d
    log "Containers Coolify reiniciados"

    # Aguarda containers ficarem healthy
    echo "Aguardando containers..."
    sleep 15
else
    log "Rede coolify OK"
fi

# =============================================================================
# PASSO 5: Verificar instalação
# =============================================================================
section "5/5 Verificando instalação"

if docker ps | grep -q coolify; then
    log "Containers Coolify estão rodando"
else
    warn "Containers não encontrados. Verifique: docker ps -a"
fi

echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|coolify" || true

# Verifica conectividade Docker-to-host SSH
echo ""
if docker exec coolify nc -z -w3 host.docker.internal 22 2>/dev/null; then
    log "Conectividade Docker → host SSH OK"
else
    warn "Docker → host SSH falhou. Execute fix-coolify-bridge.sh se necessário."
fi

# =============================================================================
# RESUMO FINAL
# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║           ✅  Coolify instalado!                     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Acesse o painel em: http://$(curl -sf ifconfig.me):8000"
echo ""
echo -e "${YELLOW}PRÓXIMOS PASSOS MANUAIS (via painel web):${NC}"
echo ""
echo "  1. Crie sua conta admin em http://SEU_IP:8000"
echo "  2. Onboarding: selecione 'This Machine'"
echo "  3. Settings → Instance → Domain → https://coolify.SEU_DOMINIO"
echo "  4. Aguarde SSL (Let's Encrypt) ser emitido automaticamente"
echo "  5. Após SSL, feche porta 8000:"
echo "     sudo ufw delete allow 8000/tcp"
echo ""
echo "  Se o Traefik não subir (erro IPv6), este script já corrigiu."
echo "  Se houver 'Connection refused', execute:"
echo "     sudo bash fix-coolify-bridge.sh"
echo ""
echo "  Consulte: 02-coolify/post-install-checklist.md"
echo ""
