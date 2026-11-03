FROM node:22-alpine AS build
WORKDIR /workspace
RUN corepack enable
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json apps/web/package.json
COPY packages packages
RUN pnpm install --frozen-lockfile
COPY apps/web apps/web
RUN pnpm --filter @orbit/web build
FROM nginx:alpine
COPY --from=build /workspace/apps/web/dist /usr/share/nginx/html
EXPOSE 80
