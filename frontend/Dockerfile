# syntax=docker/dockerfile:1
# AgroCompare frontend: build with Node, serve with nginx.

# ---------- Stage 1: build the React app ----------
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies first so this layer is cached
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ---------- Stage 2: serve static files ----------
FROM nginx:1.27-alpine

# Pull in patched Alpine packages (the base image's own packages lag behind
# Alpine's security fixes, so this closes CVEs the base tag ships with).
RUN apk update && apk upgrade --no-cache

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1
