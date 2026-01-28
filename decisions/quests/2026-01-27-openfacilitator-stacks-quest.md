# Quest: Add Stacks Blockchain Support

**Status:** active
**Created:** 2026-01-27
**Issue:** #5 — feat: Add Stacks blockchain support
**Repos:** rawgroundbeef/OpenFacilitator

## Goal

Implement full Stacks blockchain support in OpenFacilitator as described in issue #5. This adds Stacks as the third supported blockchain alongside EVM and Solana, bringing STX, sBTC, and USDCx payment tokens. The settlement model mirrors Solana (pre-signed transaction broadcast via Hiro API).

## Scope

All four workspace packages require changes:

| Package | Scope |
|---------|-------|
| `packages/core` | Chain config, token registry, settlement module, facilitator routing |
| `packages/sdk` | Network type, CAIP-2 mappings, network detection |
| `packages/server` | DB migration, routes, wallet services, billing fallback |
| `apps/dashboard` | Stacks provider, wallet UI, network selectors, chain preference |

## Reference Implementations

- [x402-stacks-facilitator](https://github.com/x402Stacks/x402-stacks-facilitator) (Go)
- [x402-stacks](https://www.npmjs.com/package/x402-stacks) (TypeScript)
- [x402-crosschain-example](https://github.com/aibtcdev/x402-crosschain-example) (EVM + Stacks)
- [stx402](https://github.com/whoabuddy/stx402) (Production Stacks x402 service)
- [x402-api](https://github.com/aibtcdev/x402-api) (Stacks x402 API service)
