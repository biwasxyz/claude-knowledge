# SIP-SIWS: Sign In with Stacks Specification

**Status**: Draft (PR #70)
**PR**: https://github.com/stacksgov/sips/pull/70
**Inspired by**: EIP-4361 (Sign-In with Ethereum)

## Overview

SIP-SIWS defines a standard message format for wallet-based authentication in the Stacks ecosystem. It enables web applications to authenticate users by requesting a cryptographic signature of a structured message.

## Message Format

```
[scheme://]<domain> wants you to sign in with your Stacks account:
<address>

[statement]

URI: <uri>
Version: <version>
Chain ID: <chainId>
Nonce: <nonce>
Issued At: <issuedAt>
[Expiration Time: <expirationTime>]
[Not Before: <notBefore>]
[Request ID: <requestId>]
[Resources:
- <resource1>
- <resource2>
...]
```

## Field Specifications

### Required Fields

| Field | Format | Description |
|-------|--------|-------------|
| `domain` | RFC 3986 authority | Domain requesting authentication. Max 80 ASCII chars recommended. |
| `address` | Stacks principal | User's Stacks address (`S[A-Z0-9]{39,40}`) |
| `uri` | RFC 3986 URI | Resource that is the subject of signing |
| `version` | `"1"` | SIWS message version (currently only "1") |
| `chainId` | SIP-005 chain ID | Target chain (1 = mainnet, 2147483648 = testnet) |
| `nonce` | Alphanumeric | Random string, minimum 8 characters |
| `issuedAt` | ISO 8601 datetime | When the message was created |

### Optional Fields

| Field | Format | Description |
|-------|--------|-------------|
| `scheme` | RFC 3986 scheme | URI scheme of origin (e.g., `https`) |
| `statement` | ASCII string | Human-readable message to display |
| `expirationTime` | ISO 8601 datetime | When the message expires |
| `notBefore` | ISO 8601 datetime | When the message becomes valid |
| `requestId` | String | System-specific request identifier |
| `resources` | String[] | URIs to resolve during authentication (max 10) |

## Signing Process

1. Application creates message with required fields
2. User reviews message in wallet (human-readable format)
3. Wallet signs message using `personal_sign` equivalent
4. Signature returned to application

### Signature Format

- Algorithm: ECDSA with secp256k1
- Format: RSV (65 bytes)
- Message hashing: `hashMessage()` from `@stacks/encryption`

## Verification Process

```
1. Parse message string → extract fields
2. Validate required fields present
3. Validate field formats (domain, nonce, URI, etc.)
4. If domain provided → verify domain matches
5. If nonce provided → verify nonce matches
6. If time constraints → verify current time within bounds
7. Hash message with hashMessage()
8. Recover public key from signature (RSV format)
9. Derive Stacks address from public key
10. Verify derived address matches message address
```

## Security Considerations

### Replay Attack Prevention

- **Nonce**: Random value generated server-side, stored temporarily
- **Expiration**: Message should have short TTL (5-15 minutes)
- **One-time use**: Delete nonce after successful verification

### Domain Binding

- Message includes domain to prevent phishing
- Server MUST verify domain matches expected value
- Wallets should display domain prominently

### Chain Binding

- Chain ID prevents cross-chain replay
- Server should verify chain ID matches expected network

### Time Validation

- `expirationTime`: Message invalid after this time
- `notBefore`: Message invalid before this time
- Both optional but recommended for security

## Address Format

Stacks addresses follow pattern: `S[A-Z0-9]{39,40}`

Examples:
- Mainnet: `SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173`
- Testnet: `ST2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173`

Address derivation:
1. Recover public key from signature
2. Hash public key (RIPEMD-160 of SHA-256)
3. Add version byte (mainnet: 22, testnet: 26)
4. Base58Check encode

## Example Message

```
https://example.com wants you to sign in with your Stacks account:
SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173

Welcome to Example App! Click to sign in and accept the Terms of Service.

URI: https://example.com/login
Version: 1
Chain ID: 1
Nonce: a1b2c3d4e5f6g7h8
Issued At: 2025-01-06T12:00:00.000Z
Expiration Time: 2025-01-06T12:15:00.000Z
Resources:
- https://example.com/tos
- https://example.com/privacy
```

## Differences from EIP-4361 (SIWE)

| Aspect | SIP-SIWS | EIP-4361 |
|--------|----------|----------|
| Address format | Stacks principal (SP/ST...) | Ethereum (0x...) |
| Chain ID | SIP-005 format | EIP-155 format |
| Cryptography | secp256k1 (same) | secp256k1 (same) |
| Message hashing | `@stacks/encryption` | keccak256 with prefix |

## Open Discussion Points

From PR #70 comments:

1. **URL length**: 80 chars may be restrictive; 4096 suggested
2. **Expiration**: Consider mandatory expiration or Stacks block height
3. **Resource limit**: Currently max 10 resources

## Implementation

Reference implementation: `sign-in-with-stacks` npm package

```bash
npm install sign-in-with-stacks
```

See `context/siws-guide.md` for usage details.
