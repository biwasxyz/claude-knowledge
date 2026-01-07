# Cloudflare Project Scaffold

Set up a new Cloudflare project with best practices for Workers, Pages, and storage products.

## Prerequisites

- Node.js 16.17.0 or later
- Cloudflare account
- Wrangler authenticated: `npx wrangler login`

## 1. Create Project

Always use the official C3 CLI:

```bash
npm create cloudflare@latest -- my-project
```

### Recommended Selections

| Prompt | Selection |
|--------|-----------|
| What would you like to start with? | Depends on project type |
| Which template? | Worker only / Pages / Framework |
| Language? | TypeScript (preferred) |
| Use git? | Yes |
| Deploy now? | No (verify locally first) |

### Common Templates

| Template | Use Case |
|----------|----------|
| `hello-world` | Basic Worker |
| `scheduled` | Cron triggers |
| `queues` | Queue consumer/producer |
| `pages` | Static site with Functions |

## 2. Initial Structure

After scaffolding, verify and enhance the structure:

```
my-project/
├── src/
│   └── index.ts          # Main entry point
├── .env                   # Local credentials (gitignored)
├── .gitignore
├── wrangler.jsonc         # Wrangler config (source of truth)
├── package.json           # npm scripts wrap wrangler
├── tsconfig.json
└── vitest.config.ts       # If using vitest for testing
```

### Configuration Best Practices

Use `wrangler.jsonc` (not `.toml`) for new projects:

```jsonc
{
  "name": "my-project",
  "main": "src/index.ts",
  "compatibility_date": "2026-01-07",
  "compatibility_flags": ["nodejs_compat"],

  // Environment-specific overrides
  "env": {
    "staging": {
      "vars": { "ENVIRONMENT": "staging" }
    },
    "production": {
      "vars": { "ENVIRONMENT": "production" }
    }
  }
}
```

## 3. Local Credentials Setup

Keep Cloudflare credentials in a local `.env` file and wrap all wrangler commands through npm scripts.

### Create .env File

```bash
# .env (add to .gitignore!)
CLOUDFLARE_API_TOKEN=your-api-token-here
CLOUDFLARE_ACCOUNT_ID=your-account-id-here
```

### Add to .gitignore

```bash
echo ".env" >> .gitignore
```

### Wrap Wrangler in package.json

Add a base `wrangler` script that sources `.env` before running wrangler:

```json
{
  "scripts": {
    "wrangler": "set -a && . ./.env && set +a && wrangler",
    "dev": "npm run wrangler -- dev",
    "deploy": "npm run wrangler -- deploy",
    "deploy:dry": "npm run wrangler -- deploy --dry-run",
    "deploy:staging": "npm run wrangler -- deploy --env staging",
    "tail": "npm run wrangler -- tail"
  }
}
```

### Usage

All wrangler commands go through `npm run wrangler`:

```bash
# Dev server
npm run dev

# Deploy (dry run first)
npm run deploy:dry
npm run deploy

# Any wrangler command
npm run wrangler -- kv:namespace list
npm run wrangler -- d1 migrations apply my-db
npm run wrangler -- tail --env production
```

**Why this pattern?**
- Credentials stay in `.env`, not shell history or global config
- Team members use same workflow
- Easy to switch accounts by editing `.env`
- Works on any shell that supports `set -a`

## 4. Add Products as Needed

Check the official docs for each product before adding bindings.

### Workers KV

Best for: Session data, API keys, config, high-read workloads.

```jsonc
// wrangler.jsonc
{
  "kv_namespaces": [
    { "binding": "MY_KV", "id": "xxx" }
  ]
}
```

**Docs**: https://developers.cloudflare.com/kv/

**Key limits**: 1 write/sec per key, eventual consistency, 25 MiB max value.

### R2 Storage

Best for: Large files, media, logs, S3-compatible storage.

```jsonc
{
  "r2_buckets": [
    { "binding": "MY_BUCKET", "bucket_name": "my-bucket" }
  ]
}
```

**Docs**: https://developers.cloudflare.com/r2/

**Note**: No egress fees. Auto-provisions on deploy.

### D1 Database

Best for: Lightweight relational data, read-heavy apps, <10GB datasets.

```jsonc
{
  "d1_databases": [
    { "binding": "DB", "database_name": "my-db", "database_id": "xxx" }
  ]
}
```

**Docs**: https://developers.cloudflare.com/d1/

**Note**: Built on SQLite. Use migrations for schema changes.

### Queues

Best for: Async processing, guaranteed delivery, decoupling services.

```jsonc
{
  "queues": {
    "producers": [{ "queue": "my-queue", "binding": "MY_QUEUE" }],
    "consumers": [{ "queue": "my-queue", "max_batch_size": 10 }]
  }
}
```

**Docs**: https://developers.cloudflare.com/queues/

### Durable Objects

Best for: Coordination, real-time state, WebSockets, rate limiting.

```jsonc
{
  "durable_objects": {
    "bindings": [{ "name": "MY_DO", "class_name": "MyDurableObject" }]
  }
}
```

**Docs**: https://developers.cloudflare.com/durable-objects/

## 5. Local Development

```bash
# Start dev server (uses .env credentials)
npm run dev

# With specific environment
npm run wrangler -- dev --env staging
```

### Testing

```bash
# Run tests
npm test

# Type check
npx tsc --noEmit
```

## 6. Deployment

### Dry Run First

```bash
npm run deploy:dry
```

### Deploy to Environment

```bash
# Staging
npm run deploy:staging

# Production (prefer CI/CD)
npm run deploy
```

### CI/CD Preferred

For production, prefer commit-and-push with GitHub Actions:

```yaml
# .github/workflows/deploy.yml
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## Quick Reference

| Product | Doc Link | Best For |
|---------|----------|----------|
| Workers | [docs](https://developers.cloudflare.com/workers/) | Serverless compute |
| Pages | [docs](https://developers.cloudflare.com/pages/) | Static sites + Functions |
| KV | [docs](https://developers.cloudflare.com/kv/) | Key-value, config, sessions |
| R2 | [docs](https://developers.cloudflare.com/r2/) | Object storage, media |
| D1 | [docs](https://developers.cloudflare.com/d1/) | SQLite database |
| Queues | [docs](https://developers.cloudflare.com/queues/) | Async messaging |
| Durable Objects | [docs](https://developers.cloudflare.com/durable-objects/) | Stateful coordination |
| Hyperdrive | [docs](https://developers.cloudflare.com/hyperdrive/) | Database connection pooling |

## Troubleshooting

**"Binding not found"**: Ensure binding names in code match `wrangler.jsonc`.

**Cold starts**: Cloudflare optimistically routes to warm instances. Use Smart Placement for API-heavy workers.

**CPU limit**: Default 50ms. Use Unbound for up to 30s CPU time.

**Rate limits**: KV is 1 write/sec per key. D1 is 10,000 rows/query. Check product docs for limits.
