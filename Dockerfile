FROM node:20-alpine AS builder

WORKDIR /app

RUN apk update && apk upgrade

COPY package*.json ./
RUN npm ci

COPY . .


FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

RUN apk update && apk upgrade \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

COPY package*.json ./
RUN npm ci --omit=dev

COPY --chown=appuser:appgroup --from=builder /app/src ./src

USER appuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "src/server.js"]
