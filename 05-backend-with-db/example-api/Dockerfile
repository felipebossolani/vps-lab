# Dockerfile — vpslab-shortener
# Multi-stage build: menor imagem final, sem devDependencies

# ── Stage 1: instalar dependências ──────────────────────────────────────────
FROM node:20.20-alpine3.21 AS deps

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --omit=dev

# ── Stage 2: imagem final ────────────────────────────────────────────────────
FROM node:20.20-alpine3.21 AS runner

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

ENV NODE_ENV=production

COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules

COPY --chown=appuser:appgroup src/ ./src/
COPY --chown=appuser:appgroup package.json ./

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]
