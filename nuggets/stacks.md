# Stacks Knowledge Nuggets

Quick facts and learnings about Stacks.js, Stacks blockchain, and deployment.

## Entries

### Tenero API (formerly STXTools)
- Base URL: `https://api.tenero.io`
- Docs: https://docs.tenero.io/
- Dashboard: https://tenero.io/
- Supports chains: `stacks`, `spark`, `sportsfun`
- No authentication required for public endpoints
- Great for: token prices, pool data, wallet holdings, trade history, market stats
- Full reference: `~/dev/whoabuddy/claude-knowledge/context/tenero-api.md`

### Sign In with Stacks (SIWS)
- Library: `sign-in-with-stacks`
- Purpose: Wallet-based authentication for web apps
- Spec: SIP-SIWS (draft) - https://github.com/stacksgov/sips/pull/70
- Local repo: `~/sign-in-with-stacks`
- Key functions: `createSiwsMessage`, `verifySiwsMessage`, `generateSiwsNonce`
- Flow: Server generates nonce → Client creates message → Wallet signs → Server verifies
- Always validate domain and nonce server-side to prevent phishing/replay attacks
- Full guide: `~/dev/whoabuddy/claude-knowledge/context/siws-guide.md`

### SIP-018: Signed Structured Data
- Purpose: Sign arbitrary Clarity data for on-chain verification
- Use cases: meta-transactions, permits, off-chain voting, multi-sig
- Hash: `sha256(0x534950303138 || domainHash || structuredDataHash)`
- Domain tuple: `{ name, version, chain-id }` - prevents replay across apps/chains
- Library: `@stacks/transactions` (`signStructuredData`, `hashStructuredData`)
- On-chain verify: `secp256k1-recover?` to recover signer from signature
- Full reference: `~/dev/whoabuddy/claude-knowledge/context/sip-018.md`

### SIWS vs SIP-018
- SIWS: Human-readable text, off-chain verification only, for web auth
- SIP-018: Binary Clarity tuples, on-chain verification, for smart contract interactions

