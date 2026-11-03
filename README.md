# ORBIT OS

ORBIT OS is a TypeScript monorepo containing the web app, API, AI runtime,
Temporal worker, and shared packages.

## 1. Requirements

Install these tools before starting:

- Git
- Node.js 22 or newer
- pnpm 12
- Docker Desktop

Check your versions:

```bash
node --version
pnpm --version
git --version
docker --version
```

If pnpm is not installed, enable it through Corepack:

```bash
corepack enable
corepack prepare pnpm@12.16.1 --activate
```

## 2. Get the project

Clone the repository:

```bash
git clone <repository-url>
cd orbit-os
```

Install dependencies:

```bash
pnpm install
```

If pnpm asks for permission to run dependency build scripts, run:

```bash
pnpm approve-builds
```

Choose the requested packages, then run `pnpm install` again.

Create your local environment file:

```bash
copy .env.example .env
```

On macOS or Linux, use:

```bash
cp .env.example .env
```

Do not commit `.env`.

## 3. Start local infrastructure

Docker Desktop must be running.

```bash
docker compose -f infrastructure/docker/docker-compose.yml up -d
```

Check the containers:

```bash
docker compose -f infrastructure/docker/docker-compose.yml ps
```

Stop the containers when finished:

```bash
docker compose -f infrastructure/docker/docker-compose.yml down
```

Local services:

| Service | URL/Port |
|---|---|
| Web app | http://localhost:5173 |
| API | http://localhost:3000 |
| API health | http://localhost:3000/api/v1/health |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |
| NATS | localhost:4222 |
| Temporal | localhost:7233 |
| Temporal UI | http://localhost:8080 |
| MinIO API | http://localhost:9000 |
| MinIO Console | http://localhost:9001 |

## 4. Start the project

Start all development applications:

```bash
pnpm dev
```

Or start one application:

```bash
pnpm --filter @orbit/web dev
pnpm --filter @orbit/api dev
pnpm --filter @orbit/ai-runtime dev
pnpm --filter @orbit/worker dev
```

The worker needs Temporal running. The AI runtime starts without an LLM API key.

## 5. Useful commands

Run these before opening a pull request:

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

Format the code:

```bash
pnpm format
```

## 6. Git workflow

### First-time setup

Configure your Git identity if needed:

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

Check the current branch and worktree:

```bash
git status
git branch
```

### Create a feature branch

Always create a branch before editing:

```bash
git pull origin main
git switch -c feature/short-description
```

Examples:

```bash
git switch -c feature/login-page
git switch -c fix/api-health
```

### Save and push your work

After making changes:

```bash
git status
git add .
git commit -m "feat: add login page"
git push -u origin feature/login-page
```

Use clear Conventional Commit messages:

```text
feat: add a new feature
fix: correct a bug
docs: update documentation
chore: update tooling
test: add tests
refactor: improve code structure
```

Then open a pull request on GitHub from your branch into `main`.

### Get the latest changes

Before starting new work:

```bash
git switch main
git pull origin main
```

Update an existing feature branch:

```bash
git switch feature/short-description
git merge main
```

If Git reports conflicts, fix the files, then run:

```bash
git add .
git commit
git push
```

## 7. Recommended team rules

- Do not work directly on `main`.
- Create one branch per feature or fix.
- Pull the latest `main` before starting work.
- Run lint, typecheck, tests, and build before pushing.
- Never commit `.env`, passwords, API keys, or generated files.
- Keep commits small and describe what changed.

## Project structure

```text
apps/
  web/          React + Vite frontend
  api/          NestJS backend
  ai-runtime/   AI runtime foundation
  worker/       Temporal worker

packages/
  config/       Environment validation
  database/     Database foundation
  contracts/    Shared schemas and types
  domain/       Domain types and rules
  observability Logging foundation
  auth/         Authentication interfaces
  event-bus/    NATS abstraction
  workflow/     Temporal abstractions
  shared/       Common types and constants
```
