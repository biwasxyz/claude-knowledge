# Sign In with Stacks (SIWS) - Usage Guide

SIWS enables decentralized authentication using Stacks wallets. Users sign a structured message to prove ownership of their address.

- **Library**: `sign-in-with-stacks`
- **Specification**: SIP-SIWS (draft) - see `context/sip-siws.md`
- **Local repo**: `~/sign-in-with-stacks`
- **Docs**: https://pradel.github.io/sign-in-with-stacks/

## Installation

```bash
npm install sign-in-with-stacks
```

## Core Functions

| Function | Purpose |
|----------|---------|
| `createSiwsMessage()` | Create a message for the user to sign |
| `verifySiwsMessage()` | Verify signature on the server |
| `generateSiwsNonce()` | Generate secure random nonce (96 hex chars) |
| `parseSiwsMessage()` | Parse message string back to object |
| `validateSiwsMessage()` | Validate message fields without signature check |

## Authentication Flow

```
┌─────────┐                    ┌─────────┐                    ┌─────────┐
│ Client  │                    │ Server  │                    │ Wallet  │
└────┬────┘                    └────┬────┘                    └────┬────┘
     │                              │                              │
     │  1. Request nonce            │                              │
     │─────────────────────────────>│                              │
     │                              │                              │
     │  2. Return nonce             │                              │
     │<─────────────────────────────│                              │
     │                              │                              │
     │  3. Create message with nonce                               │
     │  4. Request signature        │                              │
     │─────────────────────────────────────────────────────────────>
     │                              │                              │
     │  5. User approves, returns signature                        │
     │<─────────────────────────────────────────────────────────────
     │                              │                              │
     │  6. Send message + signature │                              │
     │─────────────────────────────>│                              │
     │                              │                              │
     │                              │  7. Verify signature         │
     │                              │  8. Create session           │
     │                              │                              │
     │  9. Return session token     │                              │
     │<─────────────────────────────│                              │
```

## Client-Side Implementation

```typescript
import { createSiwsMessage, generateSiwsNonce } from "sign-in-with-stacks";
import { STACKS_MAINNET } from "@stacks/network";
import { openSignatureRequestPopup } from "@stacks/connect";

// Step 1: Get nonce from server (server should store it)
const { nonce } = await fetch("/api/auth/nonce").then(r => r.json());

// Step 2: Create the SIWS message
const message = createSiwsMessage({
  address: userAddress,                    // From connected wallet
  chainId: STACKS_MAINNET.chainId,         // 1 for mainnet
  domain: window.location.host,            // Your domain
  nonce,                                   // From server
  uri: window.location.origin,             // Your origin
  version: "1",                            // Always "1"
  // Optional fields:
  statement: "Sign in to MyApp",           // Human-readable message
  expirationTime: new Date(Date.now() + 15 * 60 * 1000), // 15 min
});

// Step 3: Request signature from wallet
await openSignatureRequestPopup({
  message,
  onFinish: async ({ signature }) => {
    // Step 4: Send to server for verification
    const result = await fetch("/api/auth/verify", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message, signature }),
    });
    // Handle session token from result
  },
});
```

## Server-Side Implementation

```typescript
import { verifySiwsMessage, generateSiwsNonce } from "sign-in-with-stacks";

// Nonce endpoint - store nonce in session/cache with expiry
app.get("/api/auth/nonce", (req, res) => {
  const nonce = generateSiwsNonce();
  // Store nonce with 15 min expiry (Redis, session, etc.)
  storeNonce(req.sessionId, nonce, 15 * 60);
  res.json({ nonce });
});

// Verify endpoint
app.post("/api/auth/verify", (req, res) => {
  const { message, signature } = req.body;

  // Retrieve stored nonce
  const storedNonce = getNonce(req.sessionId);
  if (!storedNonce) {
    return res.status(400).json({ error: "Nonce expired or invalid" });
  }

  // Verify the signature
  const valid = verifySiwsMessage({
    message,
    signature,
    domain: "example.com",     // Your domain - MUST match
    nonce: storedNonce,        // Verify against stored nonce
    // Optional: additional validation
    // address: expectedAddress,
    // time: new Date(),        // Custom time for expiration check
  });

  if (!valid) {
    return res.status(401).json({ error: "Invalid signature" });
  }

  // Delete used nonce (prevent replay)
  deleteNonce(req.sessionId);

  // Extract address from message and create session
  const { address } = parseSiwsMessage(message);
  const token = createSessionToken(address);

  res.json({ token, address });
});
```

## Message Parameters

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `string` | Stacks address (SP... or SM...) |
| `chainId` | `number` | SIP-005 chain ID (1 = mainnet, 2147483648 = testnet) |
| `domain` | `string` | RFC 3986 authority (e.g., `example.com`) |
| `nonce` | `string` | Random string, min 8 alphanumeric chars |
| `uri` | `string` | RFC 3986 URI (e.g., `https://example.com`) |
| `version` | `"1"` | Must be `"1"` |

### Optional

| Parameter | Type | Description |
|-----------|------|-------------|
| `statement` | `string` | Human-readable message shown to user |
| `expirationTime` | `Date` | When message expires |
| `issuedAt` | `Date` | When message was created (defaults to now) |
| `notBefore` | `Date` | When message becomes valid |
| `requestId` | `string` | System-specific request identifier |
| `resources` | `string[]` | URIs to resolve during auth |
| `scheme` | `string` | URI scheme (e.g., `https`) |

## Verification Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `message` | `string` | Yes | The signed message string |
| `signature` | `string` | Yes | Wallet signature |
| `address` | `string` | No | Validate address matches |
| `domain` | `string` | No | Validate domain matches |
| `nonce` | `string` | No | Validate nonce matches |
| `scheme` | `string` | No | Validate scheme matches |
| `time` | `Date` | No | Time for expiration check (default: now) |

## Message Format

The message follows a human-readable format:

```
example.com wants you to sign in with your Stacks account:
SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173

Sign in to MyApp

URI: https://example.com
Version: 1
Chain ID: 1
Nonce: abc123def456
Issued At: 2025-01-06T12:00:00.000Z
Expiration Time: 2025-01-06T12:15:00.000Z
```

## Security Best Practices

1. **Always validate domain** - Prevents phishing attacks
2. **Always validate nonce** - Prevents replay attacks
3. **Use short expiration times** - 5-15 minutes recommended
4. **Delete nonces after use** - One-time use only
5. **Store nonces server-side** - Never trust client-provided nonces
6. **Use HTTPS** - Prevent message interception

## Relationship to SIP-018

SIWS uses a different signing mechanism than SIP-018:

| Aspect | SIWS (SIP-SIWS) | SIP-018 |
|--------|-----------------|---------|
| Purpose | User authentication | Arbitrary structured data signing |
| Message format | Human-readable text | Clarity tuples (wire format) |
| Verification | Off-chain only | On-chain + off-chain |
| Use case | Web app login | Meta-transactions, voting, approvals |

SIWS is specifically designed for authentication flows. For signing arbitrary data that may be verified on-chain, use SIP-018.

## Error Handling

The library throws specific errors:

- `SiwsInvalidMessageFieldError` - Invalid field in message
- `InvalidAddressError` - Invalid Stacks address format

```typescript
import { SiwsInvalidMessageFieldError } from "sign-in-with-stacks";

try {
  const valid = verifySiwsMessage({ message, signature, domain, nonce });
} catch (error) {
  if (error instanceof SiwsInvalidMessageFieldError) {
    console.error(`Invalid field: ${error.field}`);
  }
}
```
