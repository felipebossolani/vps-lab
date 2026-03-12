# Dockerfile — vpslab-shortener
# Multi-stage build: menor imagem final, sem devDependencies

# ── Stage 1: instalar dependências ──────────────────────────────────────────
FROM node:20-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm ci --only=production

# ── Stage 2: imagem final ────────────────────────────────────────────────────
FROM node:20-alpine AS runner

# Usuário não-root dentro do container
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copia dependências do stage anterior
COPY --from=deps /app/node_modules ./node_modules

# Copia código fonte
COPY src/ ./src/
COPY package.json ./

# Muda para usuário não-root
USER appuser

EXPOSE 3000

# Health check para o Coolify / Docker saber que o container está saudável
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]
