# Clarity Knowledge Nuggets

Quick facts and learnings about Clarity smart contracts and the Stacks blockchain.

## Core Principles
- **Decidable**: No unbounded loops/recursion; static cost analysis; no gas exhaustion
- **Interpreted**: Source committed as-is; human-readable; no compiler bugs
- **Secure**: No reentrancy; overflow/underflow aborts tx; responses must be checked
- **Public functions**: Must return `(response ok-type err-type)`; `ok` commits, `err` reverts

## Language Gotchas
- Clarity does NOT have a `lambda` keyword - use `define-private` for internal functions
- `sequence` is a meta-type covering list/buff/string-ascii/string-utf8
- Use `as-max-len?` to convert sequence max-len (panics if exceeds)
- Division `/` floors the result and panics on divide-by-zero
- `to-int` panics for uint >= 2^127; `to-uint` panics for negative int

## Block Height Keywords (Important!)
- `block-height` - LEGACY, use `stacks-block-height` instead (Clarity 3+)
- `stacks-block-height` - Current Stacks block height
- `burn-block-height` - Bitcoin burn chain height
- `tenure-height` - Tenure count (Clarity 3+)
- `stacks-block-time` - Block timestamp (Clarity 4)

## Error Handling
- Use `(try!)` to unwrap and early-return err/none (propagates errors up)
- Use `(unwrap!)` when you KNOW it's `some` and want to panic otherwise
- Use `(asserts!)` for guards that return an error on failure
- Never use `unwrap-panic!` unless you're absolutely certain of the value

## Security Guards
- Token side-effects: check `tx-sender` (post-conditions protect assets)
- Non-token guards: check `contract-caller` (anti-phishing)
- Pro tip: Add 1μSTX tx for tx-sender flexibility in post-conditions

## Naming Conventions
- Constants: `UPPER_CASE` (e.g., `ERR_NOT_AUTHORIZED`)
- Vars/Maps: `PascalCase` or `camelCase`
- Functions: `kebab-case`
- Tuple keys: `camelCase`
- Errors: `(define-constant ERR_NAME (err uN))` with u1000+ ranges per contract

## Testing & Development
- Always run `clarinet check` before committing contract changes
- Test with `clarinet test` not `npm test` for Clarity projects
- Use `::get-costs` in Clarinet console to check execution costs
- Run-only checks are stricter: 1e9 runtime vs 5e9 for writes

## Entries

### 2026-01-02
- Clarity does NOT have a `lambda` keyword. Use `define-private` for internal helper functions.
- Always run `clarinet check` before committing contract changes.
- Use `(try!)` not `(unwrap!)` for recoverable errors where you want to propagate the error up.

### 2026-01-03
- `as-contract` changes both `tx-sender` AND `contract-caller` to the contract principal
- Clarity 4 adds `contract-hash?` for on-chain contract verification
- Clarity 4 adds asset restrictions with `restrict-assets?` and allowances
- Fixed-point math: use `(* amount SCALE) / SCALE` where SCALE=`(pow u10 u8)`
- Traits require whitelisting: `(asserts! (default-to false (map-get? TrustedTraits (contract-of t))) ERR_UNTRUSTED)`
