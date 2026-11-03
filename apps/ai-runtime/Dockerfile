FROM node:22-alpine AS build
WORKDIR /workspace
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/ai-runtime/package.json apps/ai-runtime/package.json
COPY packages packages
RUN pnpm install --frozen-lockfile
COPY apps/ai-runtime apps/ai-runtime
RUN pnpm --filter @orbit/ai-runtime build
CMD ["node", "apps/ai-runtime/dist/main.js"]
