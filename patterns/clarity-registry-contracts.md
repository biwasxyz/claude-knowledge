# Clarity Registry Contract Patterns

Reusable patterns for building registry/attestation contracts. Common building blocks for agent coordination, proof systems, and on-chain record keeping.

## Block Snapshot Pattern

Capture a comprehensive snapshot of chain state at transaction time. This is the "receipt" that makes a transaction worth the fee.

### Full Snapshot Structure

```clarity
;; Maximum chain context at transaction time
(define-read-only (get-block-snapshot)
  {
    ;; Block heights
    stacksBlock: stacks-block-height,
    burnBlock: burn-block-height,
    tenure: tenure-height,

    ;; Timing (Clarity 4)
    blockTime: stacks-block-time,

    ;; Chain identity
    chainId: chain-id,

    ;; Transaction context
    txSender: tx-sender,
    contractCaller: contract-caller,
    txSponsor: tx-sponsor?,

    ;; Block hashes (historical proof)
    stacksBlockHash: (get-stacks-block-info? id-header-hash (- stacks-block-height u1)),
    burnBlockHash: (get-burn-block-info? header-hash (- burn-block-height u1))
  }
)
```

### Snapshot Fields Explained

| Field | Type | Description | Use Case |
|-------|------|-------------|----------|
| `stacksBlock` | `uint` | Current Stacks block height | Ordering, age calculation |
| `burnBlock` | `uint` | Current Bitcoin block height | Bitcoin-anchored time |
| `tenure` | `uint` | Miner tenure count | Nakamoto-aware timing |
| `blockTime` | `uint` | Unix timestamp (Clarity 4) | Human-readable time |
| `chainId` | `uint` | Network ID (1=mainnet) | Replay protection |
| `txSender` | `principal` | Transaction originator | Attribution |
| `contractCaller` | `principal` | Immediate caller | Proxy detection |
| `txSponsor` | `(optional principal)` | Fee sponsor if any | Sponsored tx tracking |
| `stacksBlockHash` | `(optional (buff 32))` | Previous Stacks block hash | Cryptographic anchor |
| `burnBlockHash` | `(optional (buff 32))` | Previous Bitcoin block hash | BTC anchor |

### Why Previous Block Hashes?

We capture `block-height - 1` because the current block's hash isn't finalized until after our transaction. The previous block's hash is:
- Immutable and verifiable
- Proves the transaction happened after that block
- Can be independently verified against block explorers

### Cost Considerations

```clarity
;; Minimal snapshot (cheapest)
{stacksBlock: stacks-block-height, burnBlock: burn-block-height}

;; Standard snapshot (balanced)
{
  stacksBlock: stacks-block-height,
  burnBlock: burn-block-height,
  blockTime: stacks-block-time,
  txSender: tx-sender
}

;; Full snapshot (comprehensive - use for high-value records)
;; Includes block hashes - adds ~2 read operations
```

### Helper Functions

```clarity
;; Get snapshot for storage (call at transaction time)
(define-private (capture-snapshot)
  {
    stacksBlock: stacks-block-height,
    burnBlock: burn-block-height,
    tenure: tenure-height,
    blockTime: stacks-block-time,
    chainId: chain-id,
    txSender: tx-sender,
    contractCaller: contract-caller,
    txSponsor: tx-sponsor?,
    stacksBlockHash: (get-stacks-block-info? id-header-hash (- stacks-block-height u1)),
    burnBlockHash: (get-burn-block-info? header-hash (- burn-block-height u1))
  }
)

;; Type for storage
(define-constant SNAPSHOT_TYPE
  {
    stacksBlock: uint,
    burnBlock: uint,
    tenure: uint,
    blockTime: uint,
    chainId: uint,
    txSender: principal,
    contractCaller: principal,
    txSponsor: (optional principal),
    stacksBlockHash: (optional (buff 32)),
    burnBlockHash: (optional (buff 32))
  }
)
```

---

## Registry Key Patterns

### Principal-Keyed Registry

Use when tracking state **per address** (heartbeats, profiles, balances):

```clarity
(define-map Registry
  principal           ;; Key: who
  {
    ;; ... snapshot fields
    count: uint       ;; Address-specific counter
  }
)

;; Lookup
(map-get? Registry address)

;; Update (overwrites previous)
(map-set Registry tx-sender {...})
```

**Characteristics:**
- One entry per address
- Overwrites on subsequent calls
- Natural for "last known state" patterns

### Hash-Keyed Registry

Use when tracking **unique data** (attestations, commitments):

```clarity
(define-map Registry
  (buff 32)           ;; Key: hash of data
  {
    ;; ... snapshot fields
    attestor: principal
  }
)

;; Lookup
(map-get? Registry hash)

;; Insert (first-write-wins)
(asserts! (is-none (map-get? Registry hash)) ERR_ALREADY_EXISTS)
(map-set Registry hash {...})
```

**Characteristics:**
- One entry per unique hash
- First attestor wins
- Immutable once written

### Composite-Keyed Registry

Use for **multi-dimensional** tracking (votes per proposal, actions per agent):

```clarity
(define-map Registry
  {entity: principal, action: uint}
  {
    ;; ... snapshot fields
  }
)

;; Lookup
(map-get? Registry {entity: address, action: action-id})
```

---

## Secondary Index Pattern

Enable enumeration of entries by address when primary key isn't the address.

```clarity
;; Primary: hash -> data
(define-map Attestations (buff 32) {...})

;; Secondary: address + index -> hash
(define-map AttestorIndex
  {attestor: principal, index: uint}
  (buff 32)
)

;; Counter for next index
(define-map AttestorCount principal uint)

;; On insert:
(let ((idx (default-to u0 (map-get? AttestorCount attestor))))
  (map-set AttestorIndex {attestor: attestor, index: idx} hash)
  (map-set AttestorCount attestor (+ idx u1)))

;; Enumerate:
(define-read-only (get-attestor-hash-at (attestor principal) (index uint))
  (map-get? AttestorIndex {attestor: attestor, index: index}))
```

### Paginated Retrieval

```clarity
;; Get page of entries (client calls repeatedly with offset)
(define-read-only (get-attestor-hashes (attestor principal) (offset uint))
  (let ((count (default-to u0 (map-get? AttestorCount attestor))))
    {
      total: count,
      items: (list
        (get-attestor-hash-at attestor offset)
        (get-attestor-hash-at attestor (+ offset u1))
        (get-attestor-hash-at attestor (+ offset u2))
        ;; ... up to page size
      )
    }
  )
)
```

---

## Global Stats Pattern

Track aggregate metrics without iterating:

```clarity
(define-data-var totalEntries uint u0)
(define-data-var uniqueAddresses uint u0)

;; On new entry:
(var-set totalEntries (+ (var-get totalEntries) u1))
(if isNewAddress
  (var-set uniqueAddresses (+ (var-get uniqueAddresses) u1))
  true)

;; Read stats:
(define-read-only (get-stats)
  {
    totalEntries: (var-get totalEntries),
    uniqueAddresses: (var-get uniqueAddresses)
  }
)
```

---

## Event Emission Pattern

Structured events for off-chain indexers:

```clarity
(print {
  notification: "registry-action",  ;; Event type identifier
  payload: {
    ;; Include all relevant data for indexers
    key: key,
    actor: tx-sender,
    action: "create",  ;; or "update", "delete"
    ;; ... snapshot fields
  }
})
```

**Conventions:**
- `notification`: String identifier for event routing
- `payload`: Tuple with camelCase keys
- Include enough data that indexers don't need to make follow-up calls

---

## Write Semantics

### First-Write-Wins (Attestations)

```clarity
(define-constant ERR_ALREADY_EXISTS (err u1001))

(define-public (attest (key (buff 32)))
  (begin
    (asserts! (is-none (map-get? Registry key)) ERR_ALREADY_EXISTS)
    (map-set Registry key {...})
    (ok true)))
```

### Last-Write-Wins (Heartbeats)

```clarity
(define-public (check-in)
  (begin
    ;; Always overwrites previous
    (map-set Registry tx-sender {...})
    (ok true)))
```

### Append-Only (History)

```clarity
(define-map History
  {address: principal, index: uint}
  {...snapshot...}
)

(define-public (record)
  (let ((idx (default-to u0 (map-get? HistoryCount tx-sender))))
    (map-set History {address: tx-sender, index: idx} {...})
    (map-set HistoryCount tx-sender (+ idx u1))
    (ok idx)))
```

---

## Access Control Patterns

### Open Registry (Anyone Can Write)

```clarity
(define-public (register)
  (ok (map-set Registry tx-sender {...})))
```

### Self-Only Updates

```clarity
(define-public (update (data (buff 64)))
  (begin
    (asserts! (is-some (map-get? Registry tx-sender)) ERR_NOT_REGISTERED)
    (map-set Registry tx-sender {...})
    (ok true)))
```

### Admin-Gated Registration

```clarity
(define-data-var admin principal CONTRACT_OWNER)

(define-public (register-address (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (map-set Registry address {...})
    (ok true)))
```

---

## Rate Limiting

Prevent spam by requiring minimum time between actions:

```clarity
(define-constant MIN_BLOCKS u10)
(define-constant ERR_TOO_SOON (err u1002))

(define-public (action)
  (let ((existing (map-get? Registry tx-sender)))
    (asserts!
      (>= (- stacks-block-height (default-to u0 (get stacksBlock existing)))
          MIN_BLOCKS)
      ERR_TOO_SOON)
    ;; ... proceed
  ))
```

---

## Contract Template

Minimal registry contract combining these patterns:

```clarity
;; registry-template.clar

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1000))
(define-constant ERR_NOT_FOUND (err u1001))

;; Data
(define-map Registry
  principal
  {
    stacksBlock: uint,
    burnBlock: uint,
    blockTime: uint,
    chainId: uint,
    count: uint
  }
)

(define-data-var totalEntries uint u0)
(define-data-var uniqueAddresses uint u0)

;; Public
(define-public (register)
  (let
    (
      (existing (map-get? Registry tx-sender))
      (isNew (is-none existing))
      (newCount (+ (default-to u0 (get count existing)) u1))
    )
    (map-set Registry tx-sender {
      stacksBlock: stacks-block-height,
      burnBlock: burn-block-height,
      blockTime: stacks-block-time,
      chainId: chain-id,
      count: newCount
    })
    (var-set totalEntries (+ (var-get totalEntries) u1))
    (if isNew
      (var-set uniqueAddresses (+ (var-get uniqueAddresses) u1))
      true)
    (print {notification: "register", payload: {address: tx-sender, count: newCount}})
    (ok newCount)
  )
)

;; Read-only
(define-read-only (get-entry (address principal))
  (map-get? Registry address))

(define-read-only (get-stats)
  {totalEntries: (var-get totalEntries), uniqueAddresses: (var-get uniqueAddresses)})
```

---

## Related

- `runbook/clarity-heartbeat-registry.md` - Principal-keyed heartbeat example
- `runbook/clarity-proof-of-existence.md` - Hash-keyed attestation example
- `patterns/clarity-patterns.md` - Additional patterns (events, rate limiting, etc.)
- `context/clarity-reference.md` - Language reference
