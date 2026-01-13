# AIBTC Shared Logger Setup

This runbook covers setting up a Cloudflare Worker application to use the AIBTC `worker-logs` service for centralized logging.

## Overview

The `worker-logs` service provides centralized logging for all Cloudflare Workers with:
- Per-app isolated SQLite storage via Durable Objects
- Daily aggregated statistics
- Request correlation via `request_id`
- Health monitoring capabilities
- Both RPC (service binding) and HTTP REST API access

**Service Location**: https://logs.aibtc.dev
**Source Code**: `~/dev/aibtcdev/worker-logs`

## Prerequisites

- Cloudflare account on the same account as worker-logs (for service binding)
- Wrangler CLI installed (`npm install -g wrangler`)
- Worker project initialized with `wrangler.jsonc`

## Step 1: Register Your Application

Before sending logs, register your app with worker-logs to get an app ID and API key.

```bash
curl -X POST https://logs.aibtc.dev/apps \
  -H "Content-Type: application/json" \
  -d '{"app_id": "my-worker", "name": "My Worker App"}'
```

Response:
```json
{
  "ok": true,
  "data": {
    "name": "My Worker App",
    "api_key": "48f8a1b2c3d4e5f...",
    "created_at": "2024-01-07T...",
    "health_urls": []
  }
}
```

**Save the `api_key`** - you'll need it for HTTP API access. For service binding access (recommended), you don't need the API key.

## Step 2: Configure Service Binding (Recommended)

Service bindings provide zero-latency, authenticated internal communication.

### 2.1 Update wrangler.jsonc

Add the service binding to your worker's `wrangler.jsonc`:

```jsonc
{
  "name": "my-worker",
  "main": "src/index.ts",
  "compatibility_date": "2024-12-01",
  "compatibility_flags": ["nodejs_compat_v2"],  // Required for RPC

  "services": [
    {
      "binding": "LOGS",
      "service": "worker-logs",
      "entrypoint": "LogsRPC"
    }
  ]
}
```

### 2.2 Update Environment Types

Create or update your types file:

```typescript
// src/types.ts
import type { Service } from 'cloudflare:workers'
import type { LogsRPC } from 'worker-logs'

export interface Env {
  LOGS: Service<LogsRPC>
  // ... your other bindings
}
```

### 2.3 Generate Cloudflare Types

```bash
npx wrangler types
```

## Step 3: Create Logger Helper

Create a reusable logger helper for cleaner code:

```typescript
// src/logger.ts
import type { Service } from 'cloudflare:workers'
import type { LogsRPC } from 'worker-logs'

const APP_ID = 'my-worker'  // Match your registered app_id

export function createLogger(
  logs: Service<LogsRPC>,
  requestId?: string
) {
  const baseContext = requestId ? { request_id: requestId } : {}

  return {
    debug: (msg: string, context?: Record<string, unknown>) =>
      logs.debug(APP_ID, msg, { ...baseContext, ...context }),

    info: (msg: string, context?: Record<string, unknown>) =>
      logs.info(APP_ID, msg, { ...baseContext, ...context }),

    warn: (msg: string, context?: Record<string, unknown>) =>
      logs.warn(APP_ID, msg, { ...baseContext, ...context }),

    error: (msg: string, context?: Record<string, unknown>) =>
      logs.error(APP_ID, msg, { ...baseContext, ...context }),

    // Batch multiple logs (more efficient)
    batch: (entries: Array<{
      level: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR'
      message: string
      context?: Record<string, unknown>
    }>) => logs.logBatch(APP_ID, entries.map(e => ({
      ...e,
      ...baseContext,
    }))),
  }
}
```

## Step 4: Integrate Logging

### Basic Usage

```typescript
// src/index.ts
import { createLogger } from './logger'
import type { Env } from './types'

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext) {
    const requestId = crypto.randomUUID()
    const log = createLogger(env.LOGS, requestId)

    await log.info('Request received', {
      url: request.url,
      method: request.method,
    })

    try {
      // Your handler logic
      const result = await handleRequest(request, env)

      await log.info('Request completed', { status: 200 })
      return result

    } catch (error) {
      await log.error('Request failed', {
        error: error instanceof Error ? error.message : String(error),
      })
      return new Response('Internal Error', { status: 500 })
    }
  }
}
```

### Fire-and-Forget Logging

For non-critical logs that shouldn't block the response:

```typescript
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext) {
    const requestId = crypto.randomUUID()

    // Fire-and-forget: log without awaiting
    ctx.waitUntil(
      env.LOGS.info('my-worker', 'Request received', {
        request_id: requestId,
        url: request.url,
      })
    )

    // Continue processing immediately
    return handleRequest(request, env)
  }
}
```

### Batch Logging

For multiple related logs, batch them for efficiency:

```typescript
await log.batch([
  { level: 'INFO', message: 'Step 1: Validated input' },
  { level: 'INFO', message: 'Step 2: Fetched data' },
  { level: 'INFO', message: 'Step 3: Processed result' },
])
```

## Step 5: Deploy and Test

### Deploy Your Worker

```bash
npx wrangler deploy
```

### Verify Logs Are Working

Check that logs are being recorded:

```bash
# Via HTTP API
curl "https://logs.aibtc.dev/logs?limit=10" \
  -H "X-App-ID: my-worker" \
  -H "X-Api-Key: YOUR_API_KEY"

# Check stats
curl "https://logs.aibtc.dev/stats/my-worker?days=1"
```

## Alternative: HTTP API Integration

If service binding isn't available (different Cloudflare account, external service), use the HTTP API.

### Environment Variables

Add to your worker's secrets:

```bash
npx wrangler secret put LOGS_API_KEY
# Enter your API key when prompted
```

### HTTP Logger Helper

```typescript
// src/http-logger.ts
const LOGS_URL = 'https://logs.aibtc.dev'
const APP_ID = 'my-worker'

export function createHttpLogger(apiKey: string, requestId?: string) {
  const headers = {
    'Content-Type': 'application/json',
    'X-App-ID': APP_ID,
    'X-Api-Key': apiKey,
  }

  const baseContext = requestId ? { request_id: requestId } : {}

  const log = async (
    level: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR',
    message: string,
    context?: Record<string, unknown>
  ) => {
    await fetch(`${LOGS_URL}/logs`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        level,
        message,
        context: { ...baseContext, ...context },
      }),
    })
  }

  return {
    debug: (msg: string, ctx?: Record<string, unknown>) => log('DEBUG', msg, ctx),
    info: (msg: string, ctx?: Record<string, unknown>) => log('INFO', msg, ctx),
    warn: (msg: string, ctx?: Record<string, unknown>) => log('WARN', msg, ctx),
    error: (msg: string, ctx?: Record<string, unknown>) => log('ERROR', msg, ctx),
  }
}
```

## Querying Logs

### Via RPC (in another worker)

```typescript
// Query recent errors
const errors = await env.LOGS.query('my-worker', {
  level: 'ERROR',
  limit: 50,
  since: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
})

// Get stats for last 7 days
const stats = await env.LOGS.getStats('my-worker', 7)
```

### Via HTTP API

```bash
# Query with filters
curl "https://logs.aibtc.dev/logs?level=ERROR&limit=50&since=2024-01-01T00:00:00Z" \
  -H "X-App-ID: my-worker" \
  -H "X-Api-Key: YOUR_API_KEY"

# Get daily stats
curl "https://logs.aibtc.dev/stats/my-worker?days=7"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `level` | Filter by log level | `ERROR`, `WARN`, `INFO`, `DEBUG` |
| `since` | Logs after timestamp | `2024-01-01T00:00:00Z` |
| `until` | Logs before timestamp | `2024-01-07T23:59:59Z` |
| `request_id` | Filter by request correlation ID | `uuid-here` |
| `limit` | Max results (default 100) | `50` |
| `offset` | Pagination offset | `100` |

## Optional: Health Monitoring

Register URLs for automatic health checks (runs every 5 minutes):

```bash
curl -X POST "https://logs.aibtc.dev/apps/my-worker/health-urls" \
  -H "Content-Type: application/json" \
  -d '{"urls": ["https://my-worker.example.com/health"]}'
```

View health check history:

```bash
curl "https://logs.aibtc.dev/health/my-worker"
```

## Maintenance

### Prune Old Logs

Delete logs before a specific timestamp:

```bash
curl -X POST "https://logs.aibtc.dev/apps/my-worker/prune" \
  -H "Content-Type: application/json" \
  -d '{"before": "2024-01-01T00:00:00Z"}'
```

### Regenerate API Key

If your API key is compromised:

```bash
curl -X POST "https://logs.aibtc.dev/apps/my-worker/regenerate-key"
```

## Troubleshooting

### "App not found" Error

Ensure you registered the app first:
```bash
curl -X POST https://logs.aibtc.dev/apps \
  -d '{"app_id": "my-worker", "name": "My Worker"}'
```

### "Unauthorized" Error (HTTP API)

Check that both headers are present and correct:
- `X-App-ID` matches your registered app
- `X-Api-Key` is the key returned during registration

### Service Binding Not Working

1. Verify `compatibility_flags` includes `nodejs_compat_v2`
2. Check the service name matches exactly: `worker-logs`
3. Ensure entrypoint is `LogsRPC`
4. Redeploy both workers after config changes

### Logs Not Appearing

1. Check for errors in the response from log calls
2. Verify the app_id matches exactly
3. For fire-and-forget, ensure you're using `ctx.waitUntil()`

## RPC Methods Reference

| Method | Parameters | Returns |
|--------|------------|---------|
| `debug(appId, message, context?)` | string, string, object | LogEntry |
| `info(appId, message, context?)` | string, string, object | LogEntry |
| `warn(appId, message, context?)` | string, string, object | LogEntry |
| `error(appId, message, context?)` | string, string, object | LogEntry |
| `log(appId, entry)` | string, LogInput | LogEntry |
| `logBatch(appId, entries)` | string, LogInput[] | { count: number } |
| `query(appId, filters?)` | string, QueryFilters | LogEntry[] |
| `getStats(appId, days?)` | string, number | DailyStats[] |

## Related Documentation

- Full integration guide: `~/dev/aibtcdev/worker-logs/docs/integration.md`
- Architecture details: `~/dev/aibtcdev/worker-logs/docs/PLAN.md`
