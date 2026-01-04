# ADR-0002: Clarity Contract Design Principles

## Status
Accepted

## Context
Clarity is a decidable smart contract language for the Stacks blockchain. Unlike Solidity, it has fundamental design constraints that eliminate entire classes of bugs but require different patterns.

## Decision

### Core Language Properties

| Property | Implication |
|----------|-------------|
| **Decidable** | No unbounded loops, no recursion, static cost analysis |
| **Interpreted** | Source code is committed as-is, human-readable on-chain |
| **Non-reentrant** | Contract calls complete before returning, no reentrancy bugs |
| **Fail-safe arithmetic** | Overflow/underflow abort the transaction |

### Design Principles

#### 1. Composition Over Inheritance
Clarity has no inheritance. Use traits for polymorphism:
```clarity
(define-trait transferable ((transfer (uint principal principal) (response bool uint))))
```
- Define small, focused traits
- Whitelist trait implementations before trusting them
- Use `contract-of` to verify trait source

#### 2. Explicit Error Handling
All public functions return `(response ok-type err-type)`:
- `ok` commits all state changes
- `err` reverts everything
- Never swallow errors - propagate with `try!` or handle with `match`

#### 3. Principal-Based Security
Two principals matter for authorization:
- `tx-sender`: Original transaction signer (use for token operations)
- `contract-caller`: Immediate caller (use for non-token guards, anti-phishing)

#### 4. Post-Conditions for Asset Safety
Clarity's post-conditions are a unique safety feature:
- Define expected token movements in the transaction
- Transaction fails if post-conditions aren't met
- Protects users even from malicious contracts

#### 5. Immutable Once Deployed
Contracts cannot be upgraded. Plan for:
- Versioned contract names (`my-contract-v2`)
- Proxy patterns with trait-based dispatch
- Migration functions for state transfer

### Security Guidelines

#### Trust Boundaries
```
┌─────────────────────────────────────────┐
│ EXTERNAL (untrusted)                     │
│  - User input                            │
│  - Trait implementations                 │
│  - External contract calls               │
├─────────────────────────────────────────┤
│ INTERNAL (trusted after validation)      │
│  - Own contract state                    │
│  - Whitelisted contracts                 │
│  - Validated principals                  │
└─────────────────────────────────────────┘
```

#### Authorization Pattern
```clarity
;; For token operations - use tx-sender
(asserts! (is-eq tx-sender (var-get owner)) ERR_NOT_OWNER)

;; For non-token guards - use contract-caller
(asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
```

#### Rate Limiting
Prevent spam/abuse with block-based limits:
```clarity
(asserts! (> burn-block-height (var-get last-action-block)) ERR_RATE_LIMIT)
```

### Clarity 4 Additions

| Feature | Use Case |
|---------|----------|
| `contract-hash?` | Verify contract hasn't been replaced |
| `restrict-assets?` | Limit what assets a call can move |
| `stacks-block-time` | Access block timestamp |
| `secp256r1-verify` | Passkey/WebAuthn support |

### Coding Standards

| Element | Convention | Example |
|---------|------------|---------|
| Constants | UPPER_CASE | `ERR_NOT_AUTHORIZED` |
| Data vars | PascalCase | `TokenBalance` |
| Maps | PascalCase | `UserBalances` |
| Functions | kebab-case | `get-balance` |
| Tuple keys | camelCase | `{tokenId: u1}` |
| Errors | u1000+ per contract | `(err u1001)` |

## Consequences

### Benefits
- Predictable execution costs (no gas surprises)
- No reentrancy vulnerabilities by design
- Human-readable contracts on-chain
- Strong type safety

### Trade-offs
- No unbounded iteration (must paginate or pre-size)
- No upgradeable contracts (requires migration strategy)
- Limited computation per transaction
- Learning curve for developers from other languages

### References
- Clarity Language Book: `~/dev/clarity-lang/book/`
- Security Handbook: `~/dev/stx-labs/security-handbook/`
- Example Contracts: `~/dev/aibtc/aibtcdev-daos/contracts/`
