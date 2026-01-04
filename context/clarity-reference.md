# Clarity Language Reference

Comprehensive reference for Clarity smart contract development on Stacks.

## Types

| Type | Description |
|------|-------------|
| `int` | Signed 128-bit integer |
| `uint` | Unsigned 128-bit integer |
| `bool` | `true` or `false` |
| `principal` | Address (standard or contract) |
| `(buff len)` | Byte buffer ≤ `len` |
| `(string-ascii len)` | ASCII string ≤ `len` |
| `(string-utf8 len)` | UTF-8 string ≤ `len` |
| `(list len T)` | List ≤ `len` of type `T` |
| `{label: T, ...}` | Named tuple |
| `(optional T)` | `(some T)` or `none` |
| `(response ok-T err-T)` | Success/failure return type |

**Note**: `sequence` is a meta-type covering list/buff/string-ascii/string-utf8.

## Keywords

| Keyword | Type | Description |
|---------|------|-------------|
| `block-height` | `uint` | Legacy - use `stacks-block-height` |
| `burn-block-height` | `uint` | Bitcoin burn chain height |
| `chain-id` | `uint` | Network ID (1=mainnet) |
| `contract-caller` | `principal` | Immediate caller |
| `contract-hash?` | fn | Get on-chain contract hash (Clarity 4) |
| `current-contract` | `principal` | This contract's principal (Clarity 4) |
| `false`/`true` | `bool` | Boolean literals |
| `is-in-mainnet` | `bool` | True if mainnet |
| `is-in-regtest` | `bool` | True if regtest |
| `is-in-testnet` | `bool` | True if testnet |
| `none` | `(optional ?)` | None value |
| `stacks-block-height` | `uint` | Current Stacks block (Clarity 3+) |
| `stacks-block-time` | `uint` | Block timestamp (Clarity 4) |
| `stx-liquid-supply` | `uint` | Liquid uSTX supply |
| `tenure-height` | `uint` | Tenure count (Clarity 3+) |
| `tx-sender` | `principal` | Transaction originator |
| `tx-sponsor?` | `(optional principal)` | Sponsor if any |

## Contract Structure

```clarity
;; Constants
(define-constant NAME expr)

;; State
(define-data-var var-name T init-val)
(define-map map-name {key-T} value-T)

;; Tokens
(define-fungible-token token-name [supply-cap])
(define-non-fungible-token nft-name id-T)

;; Functions
(define-private (fn (arg T)) body)           ;; Internal only
(define-public (fn (arg T)) (response ok err)) ;; External, mutable
(define-read-only (fn (arg T)) body)         ;; External, pure

;; Traits
(define-trait trait-name ((fn1 (args) resp) ...))
(impl-trait .other-contract.trait-name)
(use-trait alias .deployer.trait-name)
```

## Functions by Category

### Arithmetic
| Fn | Description |
|----|-------------|
| `+` `-` `*` `/` | Basic ops (/ floors, panics on /0) |
| `mod` | Modulo |
| `pow` | Exponentiation |
| `sqrti` | Integer square root |
| `log2` | Log base 2 |

### Bitwise
| Fn | Description |
|----|-------------|
| `bit-and` `bit-or` `bit-xor` | Binary operations |
| `bit-not` | Bitwise complement |
| `bit-shift-left` `bit-shift-right` | Bit shifting |

### Comparisons
| Fn | Description |
|----|-------------|
| `<` `<=` `>` `>=` | Numeric/string/buffer comparison |
| `is-eq` | Equality (any same type) |

### Logic
| Fn | Description |
|----|-------------|
| `and` | Short-circuit AND |
| `or` | Short-circuit OR |
| `not` | Negation |

### Control Flow
```clarity
(if pred then else)                    ;; Conditional (branches same type)
(let ((x val) (y val)) body)           ;; Scoped bindings
(begin expr1 expr2 ... last)           ;; Sequence, returns last
(match opt some-val none-val)          ;; Optional destructure
(match resp {ok v ok-body} {err e err-body}) ;; Response destructure
(try! resp-or-opt)                     ;; Unwrap or early return err/none
(unwrap! opt default)                  ;; Unwrap or return default
(unwrap-panic! opt)                    ;; Unwrap or panic
(asserts! bool err-val)                ;; Assert or early err
```

### Sequences (list/buff/string)
| Fn | Description |
|----|-------------|
| `list` | Create list literal |
| `len` | Get length |
| `concat` | Join two sequences |
| `append` | Add element to list |
| `element-at?` | Get element by index |
| `index-of?` | Find index of element |
| `slice?` | Get subsequence |
| `map` | Transform elements |
| `filter` | Select matching elements |
| `fold` | Reduce to single value |
| `as-max-len?` | Convert max-len (panics if exceeds) |

### Persistence
| Fn | Description |
|----|-------------|
| `var-get` | Read data-var |
| `var-set` | Write data-var → `true` |
| `map-get?` | Read map → `(some val)` or `none` |
| `map-insert` | Insert if absent → `true`/`false` |
| `map-set` | Insert or overwrite → `true` |
| `map-delete` | Remove entry → `true`/`false` |

### Fungible Tokens
| Fn | Args | Returns |
|----|------|---------|
| `ft-mint?` | token uint principal | `(ok true)` |
| `ft-transfer?` | token uint from to | `(ok true)` |
| `ft-burn?` | token uint from | `(ok true)` |
| `ft-get-balance` | token principal | `uint` |
| `ft-get-supply` | token | `uint` |

### Non-Fungible Tokens
| Fn | Args | Returns |
|----|------|---------|
| `nft-mint?` | nft id principal | `(ok true)` |
| `nft-transfer?` | nft id from to | `(ok true)` |
| `nft-burn?` | nft id from | `(ok true)` |
| `nft-get-owner?` | nft id | `(some principal)` or `none` |

### STX Operations
| Fn | Description |
|----|-------------|
| `stx-get-balance` | Get uSTX balance |
| `stx-transfer?` | Transfer STX |
| `stx-burn?` | Burn STX |
| `stx-transfer-memo?` | Transfer with memo |
| `stx-account` | Get full account info |

### Contract Calls
| Fn | Description |
|----|-------------|
| `contract-call?` | Call another contract |
| `contract-of` | Get principal from trait |
| `as-contract` | Execute as contract principal |
| `restrict-assets?` | Limit asset movements (Clarity 4) |

### Clarity 4 Asset Allowances
```clarity
(with-stx uint)                        ;; Allow STX amount
(with-ft principal token-name uint)    ;; Allow FT amount (or "*")
(with-nft principal token-name ids)    ;; Allow specific NFTs (or "*")
(with-stacking uint)                   ;; Allow stacking
(with-all-assets-unsafe)               ;; DANGER: unrestricted
```

### Crypto/Hash
| Fn | Returns |
|----|---------|
| `hash160` | `(buff 20)` |
| `sha256` | `(buff 32)` |
| `sha512` | `(buff 64)` |
| `sha512/256` | `(buff 32)` |
| `keccak256` | `(buff 32)` |
| `secp256k1-recover?` | Recover pubkey from sig |
| `secp256k1-verify` | Verify signature |
| `secp256r1-verify` | Passkey verification (Clarity 4) |

### Conversions
| Fn | Description |
|----|-------------|
| `to-int` | uint → int (panics if ≥2^127) |
| `to-uint` | int → uint (panics if <0) |
| `int-to-ascii` | Number to string |
| `buff-to-int-be/le` | Buffer to int |
| `buff-to-uint-be/le` | Buffer to uint |

### Utilities
| Fn | Description |
|----|-------------|
| `ok` `err` | Wrap response |
| `some` | Wrap optional |
| `default-to` | Provide default for optional |
| `merge` | Combine tuples |
| `print` | Log value (for events) |
| `at-block` | Read historic state |

## Execution Cost Limits

| Category | Block | Read-Only |
|----------|-------|-----------|
| Runtime | 5e9 | 1e9 |
| Read count | 15,000 | 30 |
| Read bytes | 100MB | 100KB |
| Write count | 15,000 | 0 |
| Write bytes | 15MB | 0 |

## Stacking (PoX-4+)

| Function | Description |
|----------|-------------|
| `stack-stx` | Solo stacking |
| `delegate-stx` | Delegate to pool |
| `delegate-stack-stx` | Pool partial stack |
| `stack-aggregation-commit-indexed` | Pool commit |
| `stack-aggregation-increase` | Pool extend |

## BNS Operations

| Function | Description |
|----------|-------------|
| `name-preorder` | Preorder name hash |
| `name-register` | Register after preorder |
| `name-renewal` | Renew registration |
| `name-transfer` | Transfer ownership |
| `name-update` | Update zonefile |

---
Version: Clarity 4 (post Bitcoin #923222)
