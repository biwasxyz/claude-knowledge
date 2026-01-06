# Tenero API Reference

Tenero (formerly STXTools) provides market data, trading analytics, and blockchain data for Stacks ecosystem chains.

- **Base URL**: `https://api.tenero.io`
- **Documentation**: https://docs.tenero.io/
- **Dashboard**: https://tenero.io/
- **OpenAPI Spec**: `~/dev/whoabuddy/claude-knowledge/downloads/2025-01-06-tenero-openapi-spec.json`

## Supported Chains

All endpoints use `{chain}` path parameter:
- `stacks` - Stacks mainnet
- `spark` - Spark chain
- `sportsfun` - SportsFun chain

## Response Format

All responses follow this structure:
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": { ... }
}
```

## API Endpoints

### Blocks
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/blocks/{height}` | Get block by height |
| `GET /v1/{chain}/blocks/latest` | Get latest block |

### Candlesticks / OHLC
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/pools/{pool_id}/ohlc` | Get OHLCV data for a pool |
| `GET /v1/{chain}/tokens/{token_address}/ohlc` | Get OHLCV data for a token |

**Parameters:**
- `period`: `1m`, `5m`, `15m`, `1h`, `4h`, `1d`
- `from`, `to`: Unix timestamps in seconds
- `limit`: 1-1000 (default 100)
- `type`: `usd` or `native` (for pools)

### Holdings
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/tokens/{token_address}/holders` | Get token holders |
| `GET /v1/{chain}/wallets/{wallet_address}/holdings` | Get wallet's token holdings |
| `GET /v1/{chain}/wallets/holdings` | Get merged holdings for multiple wallets (max 20) |
| `GET /v1/{chain}/wallets/{wallet_address}/holdings_value` | Get wallet holdings value |
| `GET /v1/{chain}/portfolio/holdings_value_multiple` | Get portfolio value for multiple wallets |

**Holder sorting options:** `balance`, `buy_amount_usd`, `sell_amount_usd`, `realized_pnl_usd`, `last_active_at`

### Holder Analytics
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/tokens/{token_address}/holder_percentages` | Get top holder concentration (top 10/25/50%) |
| `GET /v1/{chain}/tokens/{token_address}/holder_stats` | Get detailed holder statistics |

**Holder stats include:** holder_count, fresh wallets (1w/1m), old wallets (1y/2y), whale wallets, trader activity, etc.

### Market Data
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/market/hourly_netflow` | Hourly market netflow |
| `GET /v1/{chain}/market/stats` | Overall market statistics |
| `GET /v1/{chain}/market/top_gainers` | Top gaining tokens |
| `GET /v1/{chain}/market/top_losers` | Top losing tokens |
| `GET /v1/{chain}/market/top_market` | Top tokens by market cap |
| `GET /v1/{chain}/market/trader_stats` | Trader statistics |
| `GET /v1/{chain}/market/dex_trades_polling` | Poll for new DEX trades |
| `GET /v1/{chain}/market/top_inflows` | Tokens with highest inflows |
| `GET /v1/{chain}/market/top_outflows` | Tokens with highest outflows |

### Platforms (DEXes)
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/platforms` | List DEX platforms |

### Pools
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/pools/{pool_id}` | Get pool details |
| `GET /v1/{chain}/pools` | List pools with filtering |
| `GET /v1/{chain}/pools/trending/{timeframe}` | Get trending pools |

### Portfolio Wallets
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/portfolio_wallets` | List portfolio wallets |
| `GET /v1/{chain}/portfolio_wallets/{address}` | Get portfolio wallet details |

### Search
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/search` | Search tokens, pools, wallets |

### Transfers
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/tokens/{token_address}/transfers` | Get token transfer history |
| `GET /v1/{chain}/wallets/{wallet_address}/transfers` | Get wallet transfer history |

### Tokens
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/tokens/native` | Get native token info (STX) |
| `GET /v1/{chain}/tokens/{token_address}` | Get token details |
| `GET /v1/{chain}/tokens/{token_address}/market_summary` | Get token market summary |
| `GET /v1/{chain}/tokens/{token_address}/profile` | Get token profile |
| `GET /v1/{chain}/tokens` | List tokens with filtering |
| `GET /v1/{chain}/tokens_simple` | Simplified token list |

### Trades
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/market/whale_trades` | Large trades |
| `GET /v1/{chain}/market/top_trades` | Top trades by value |
| `GET /v1/{chain}/pools/{pool_id}/trades` | Trades for a specific pool |
| `GET /v1/{chain}/tokens/{token_address}/trades` | Trades for a specific token |
| `GET /v1/{chain}/trades/{tx_id}` | Get trade by transaction ID |
| `GET /v1/{chain}/wallets/{wallet_address}/trades` | Wallet trade history |
| `GET /v1/{chain}/trades/latest` | Latest trades |
| `GET /v1/{chain}/trades/multi` | Multiple trade queries |

### Wallets
| Endpoint | Description |
|----------|-------------|
| `GET /v1/{chain}/wallets/{wallet_address}` | Get wallet info |
| `GET /v1/{chain}/wallets/{wallet_address}/pnl_distribution` | Wallet PnL distribution |
| `GET /v1/{chain}/wallets/{wallet_address}/trade_stats` | Wallet trading statistics |
| `GET /v1/{chain}/wallets/{wallet_address}/daily_trade_stats` | Daily trade stats |

## Key Data Models

### Candlestick
```typescript
{
  time: number;      // Unix timestamp in seconds
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}
```

### TokenHolder
```typescript
{
  wallet_address: string;
  wallet_name?: string;
  balance: number | string;  // string for large numbers
  credits: number | string;
  debits: number | string;
  fees: number | string;
  start_holding_at: number;  // Unix ms
  last_active_at: number;    // Unix ms
  trade_stats: TradeStats;
}
```

### TradeStats
```typescript
{
  buy_tx_count: number;
  sell_tx_count: number;
  buy_amount: number;
  sell_amount: number;
  netflow_amount: number;
  buy_amount_usd: number;
  sell_amount_usd: number;
  netflow_amount_usd: number;
  avg_buy_price_usd: number;
  avg_sell_price_usd: number;
  first_trade_time: number;  // Unix ms
  last_trade_time: number;   // Unix ms
  total_tx_count: number;
  total_volume_usd: number;
  realized_pnl_usd: number;
}
```

### HolderStats
```typescript
{
  holder_count: string;
  fresh_1w: string;           // New holders in last week
  fresh_1m: string;           // New holders in last month
  old_1y: string;             // Holders for 1+ year
  old_2y: string;             // Holders for 2+ years
  whale_wallets: string;
  low_token_count_wallets: string;
  multi_token_wallets: string;
  single_token_wallets: string;
  recently_started_holding: string;
  active_1w: string;
  active_1m: string;
  inactive_6m: string;
  inactive_1y: string;
  trader_wallets: string;
  high_volume_traders: string;
  frequent_traders: string;
  updated_at: number;
}
```

## Common Query Parameters

### Pagination
- `limit`: Number of items (usually 1-100)
- `cursor`: Cursor for next page (returned in response as `next`)

### Sorting
- `order`: Field to sort by
- `direction`: `ASC` or `DESC`

### Filtering (for holders/holdings)
- `min_balance`, `max_balance`: Balance range (string for bigint)
- `min_buy_tx_count`, `min_sell_tx_count`: Transaction count filters
- `min_total_volume_usd`, `max_total_volume_usd`: Volume filters
- `min_realized_pnl_usd`, `max_realized_pnl_usd`: PnL filters

## Example Usage

### Get token price and info
```bash
curl "https://api.tenero.io/v1/stacks/tokens/SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token"
```

### Get OHLCV data for a token
```bash
curl "https://api.tenero.io/v1/stacks/tokens/SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token/ohlc?period=1h&limit=24"
```

### Get top holders of a token
```bash
curl "https://api.tenero.io/v1/stacks/tokens/SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token/holders?limit=10&order=balance"
```

### Get wallet holdings
```bash
curl "https://api.tenero.io/v1/stacks/wallets/SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D/holdings"
```

### Get trending pools
```bash
curl "https://api.tenero.io/v1/stacks/pools/trending/24h"
```

### Get market top gainers
```bash
curl "https://api.tenero.io/v1/stacks/market/top_gainers"
```

## Notes

- Timestamps: Block times in milliseconds, candlestick times in seconds
- Large numbers: Balance/credit/debit fields may be strings when exceeding JavaScript safe integer
- Token addresses: Format is `{deployer}.{contract-name}` (e.g., `SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token`)
- Pool IDs: Format is `{deployer}.{pool-contract}` (e.g., `SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-leo-stx-v-1-1`)
