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
#   ssh deploy@SEU_IP        # acesse como deploy
#   sudo su -                # eleve para root
#   bash install.sh
#
# NOTA SOBRE SEGURANÇA:
#   O Coolify precisa de root para instalar e gerenciar containers Docker.
#   Após a instalação, o acesso SSH diário continua sendo pelo usuário deploy.
#   O root não tem entrada SSH — o Coolify usa chave SSH própria gerada na
#   instalação para se comunicar com o servidor.
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
section "1/4 Verificando pré-requisitos"

# Verifica Ubuntu 24.04
if ! grep -q "24.04" /etc/os-release; then
    warn "Este script foi testado no Ubuntu 24.04. Prosseguindo mesmo assim..."
fi

# Verifica conectividade
if ! curl -sf https://cdn.coollabs.io > /dev/null; then
    error "Sem acesso à internet. Verifique a conectividade."
fi

log "Pré-requisitos OK"

# =============================================================================
# PASSO 2: Garantir porta 8000 aberta no UFW (acesso inicial ao painel)
# =============================================================================
section "2/4 Liberando porta 8000 temporariamente"

if command -v ufw &>/dev/null; then
    ufw allow 8000/tcp comment 'Coolify UI inicial' 2>/dev/null || true
    log "Porta 8000 liberada no UFW"
fi

# =============================================================================
# PASSO 3: Instalar Coolify
# =============================================================================
section "3/4 Instalando Coolify"

warn "Isso vai levar alguns minutos..."
warn "O script oficial do Coolify irá instalar Docker e todos os componentes."
echo ""

curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

log "Coolify instalado com sucesso"

# =============================================================================
# PASSO 4: Verificar instalação
# =============================================================================
section "4/4 Verificando instalação"

# Aguarda containers subirem
echo "Aguardando containers iniciarem..."
sleep 15

# Verifica containers rodando
if docker ps | grep -q coolify; then
    log "Container Coolify está rodando"
else
    warn "Container Coolify não encontrado. Verifique: docker ps -a"
fi

# Mostra containers ativos
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|coolify" || true

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
echo "  2. Settings → Domain → adicione https://coolify.vpslab.com.br"
echo "  3. Aguarde SSL (Let's Encrypt) ser emitido automaticamente"
echo "  4. Após SSL, feche porta 8000:"
echo "     sudo ufw delete allow 8000/tcp"
echo ""
echo "  Consulte: 02-coolify/post-install-checklist.md"
echo ""
