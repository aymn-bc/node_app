# STAGE 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
# Use npm install to allow package.json overrides to take effect without local package-lock updates
RUN npm install --no-audit --no-fund

COPY src ./src


# STAGE 2: Production Execution
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Upgrade Alpine OS packages to patch libcrypto3 / libssl3 (OpenSSL)
RUN apk update && apk upgrade --no-cache && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

COPY package*.json ./
RUN npm install --omit=dev --no-audit --no-fund
RUN rm -rf /usr/local/lib/node_modules/npm && rm -f /usr/local/bin/npm /usr/local/bin/npx

COPY --chown=appuser:appgroup --from=builder /app/src ./src

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

CMD ["node", "src/server.js"]