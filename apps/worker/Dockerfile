FROM node:22-alpine AS build
WORKDIR /workspace
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/worker/package.json apps/worker/package.json
COPY packages packages
RUN pnpm install --frozen-lockfile
COPY apps/worker apps/worker
RUN pnpm --filter @orbit/worker build
CMD ["node", "apps/worker/dist/main.js"]
