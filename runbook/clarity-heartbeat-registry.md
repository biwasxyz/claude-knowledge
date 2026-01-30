# Clarity Heartbeat Registry Contract

A simple address registry where any address can "check in" and record a comprehensive chain snapshot. Useful for agent heartbeats, activity tracking, and coordination primitives.

## Use Cases

- **Agent heartbeat**: Autonomous agents prove they're alive and operational
- **Activity tracking**: Record when addresses interact with a system
- **Coordination checkpoint**: Agents record state at known points
- **Chain anchor**: Capture block hashes for cryptographic proofs
- **Learning example**: Simple contract to test wallet interactions

## Design Principles

This contract captures **maximum useful context** at transaction time. The snapshot is the "receipt" that justifies the transaction fee - it anchors the check-in to a specific moment in both Stacks and Bitcoin chains.

See `patterns/clarity-registry-contracts.md` for the block snapshot pattern.

## Data Model

### Full Snapshot Per Check-In

| Field | Type | Source | Purpose |
|-------|------|--------|---------|
| `stacksBlock` | `uint` | `stacks-block-height` | Ordering, age |
| `burnBlock` | `uint` | `burn-block-height` | Bitcoin anchor |
| `tenure` | `uint` | `tenure-height` | Nakamoto timing |
| `blockTime` | `uint` | `stacks-block-time` | Human timestamp |
| `chainId` | `uint` | `chain-id` | Network ID |
| `contractCaller` | `principal` | `contract-caller` | Proxy detection |
| `txSponsor` | `(optional principal)` | `tx-sponsor?` | Sponsored tx |
| `stacksBlockHash` | `(optional (buff 32))` | `get-stacks-block-info?` | Crypto anchor |
| `burnBlockHash` | `(optional (buff 32))` | `get-burn-block-info?` | BTC anchor |
| `count` | `uint` | Computed | Check-in counter |

## Contract Code

```clarity
;; heartbeat-registry.clar
;; Agent coordination primitive - on-chain heartbeat with full chain context

;; ---------------------------------------------------------
;; Constants
;; ---------------------------------------------------------

(define-constant CONTRACT_OWNER tx-sender)

;; ---------------------------------------------------------
;; Data
;; ---------------------------------------------------------

(define-map Registry
  principal
  {
    ;; Block context
    stacksBlock: uint,
    burnBlock: uint,
    tenure: uint,
    blockTime: uint,
    chainId: uint,
    ;; Transaction context
    contractCaller: principal,
    txSponsor: (optional principal),
    ;; Block hashes (cryptographic anchors)
    stacksBlockHash: (optional (buff 32)),
    burnBlockHash: (optional (buff 32)),
    ;; Counter
    count: uint
  }
)

;; Global stats
(define-data-var totalAddresses uint u0)
(define-data-var totalCheckIns uint u0)

;; Secondary index: index -> address (for enumeration)
(define-map AddressIndex uint principal)

;; ---------------------------------------------------------
;; Private Functions
;; ---------------------------------------------------------

;; Capture full chain snapshot at transaction time
(define-private (capture-snapshot (existingCount uint))
  {
    stacksBlock: stacks-block-height,
    burnBlock: burn-block-height,
    tenure: tenure-height,
    blockTime: stacks-block-time,
    chainId: chain-id,
    contractCaller: contract-caller,
    txSponsor: tx-sponsor?,
    stacksBlockHash: (get-stacks-block-info? id-header-hash (- stacks-block-height u1)),
    burnBlockHash: (get-burn-block-info? header-hash (- burn-block-height u1)),
    count: (+ existingCount u1)
  }
)

;; ---------------------------------------------------------
;; Public Functions
;; ---------------------------------------------------------

;; Check in - records full chain snapshot for tx-sender
(define-public (check-in)
  (let
    (
      (caller tx-sender)
      (existing (map-get? Registry caller))
      (existingCount (default-to u0 (get count existing)))
      (isNew (is-none existing))
      (snapshot (capture-snapshot existingCount))
    )
    ;; Update registry
    (map-set Registry caller snapshot)

    ;; Update counters and index
    (var-set totalCheckIns (+ (var-get totalCheckIns) u1))
    (if isNew
      (begin
        (map-set AddressIndex (var-get totalAddresses) caller)
        (var-set totalAddresses (+ (var-get totalAddresses) u1))
      )
      true
    )

    ;; Emit event for indexers
    (print {
      notification: "check-in",
      payload: {
        address: caller,
        stacksBlock: (get stacksBlock snapshot),
        burnBlock: (get burnBlock snapshot),
        blockTime: (get blockTime snapshot),
        stacksBlockHash: (get stacksBlockHash snapshot),
        burnBlockHash: (get burnBlockHash snapshot),
        count: (get count snapshot)
      }
    })

    (ok snapshot)
  )
)

;; ---------------------------------------------------------
;; Read-Only Functions
;; ---------------------------------------------------------

;; Get full registration for an address
(define-read-only (get-registration (address principal))
  (map-get? Registry address)
)

;; Check if address has ever registered
(define-read-only (is-registered (address principal))
  (is-some (map-get? Registry address))
)

;; Get check-in count for an address
(define-read-only (get-check-in-count (address principal))
  (default-to u0 (get count (map-get? Registry address)))
)

;; Get last check-in block for an address
(define-read-only (get-last-block (address principal))
  (default-to u0 (get stacksBlock (map-get? Registry address)))
)

;; Get global stats
(define-read-only (get-stats)
  {
    totalAddresses: (var-get totalAddresses),
    totalCheckIns: (var-get totalCheckIns)
  }
)

;; Get address at index (for enumeration)
(define-read-only (get-address-at (index uint))
  (map-get? AddressIndex index)
)

;; Get current chain state (useful for clients before submitting)
(define-read-only (get-current-block-info)
  {
    stacksBlock: stacks-block-height,
    burnBlock: burn-block-height,
    tenure: tenure-height,
    blockTime: stacks-block-time,
    chainId: chain-id,
    stacksBlockHash: (get-stacks-block-info? id-header-hash (- stacks-block-height u1)),
    burnBlockHash: (get-burn-block-info? header-hash (- burn-block-height u1))
  }
)

;; Check if address checked in within N blocks (liveness check)
(define-read-only (is-alive (address principal) (maxBlocks uint))
  (match (map-get? Registry address)
    entry (<= (- stacks-block-height (get stacksBlock entry)) maxBlocks)
    false
  )
)

;; Get addresses that are "alive" from a list (batch liveness check)
(define-read-only (filter-alive (addresses (list 20 principal)) (maxBlocks uint))
  (filter is-alive-check addresses)
)

;; Helper for filter (uses fixed threshold - customize as needed)
(define-private (is-alive-check (address principal))
  (is-alive address u144)  ;; ~1 day of blocks
)
```

## Testing

### Clarinet SDK Test

```typescript
import { Cl, cvToValue } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

const CONTRACT = "heartbeat-registry";

describe("heartbeat-registry", function () {
  it("captures full chain snapshot on check-in", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;

    const result = simnet.callPublicFn(CONTRACT, "check-in", [], wallet1);

    expect(result.result).toBeOk(Cl.tuple({
      stacksBlock: Cl.uint(simnet.blockHeight),
      burnBlock: Cl.uint(simnet.burnBlockHeight),
      tenure: Cl.uint(0),
      blockTime: Cl.uint(0),
      chainId: Cl.uint(2147483648), // testnet
      contractCaller: Cl.principal(wallet1),
      txSponsor: Cl.none(),
      stacksBlockHash: Cl.some(Cl.buffer(new Uint8Array(32))), // simnet returns zeros
      burnBlockHash: Cl.some(Cl.buffer(new Uint8Array(32))),
      count: Cl.uint(1),
    }));
  });

  it("increments count on subsequent check-ins", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;

    simnet.callPublicFn(CONTRACT, "check-in", [], wallet1);
    simnet.callPublicFn(CONTRACT, "check-in", [], wallet1);
    const result = simnet.callPublicFn(CONTRACT, "check-in", [], wallet1);

    const value = cvToValue(result.result);
    expect(value.value.count).toBe(3n);
  });

  it("tracks unique addresses in stats", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const wallet2 = simnet.getAccounts().get("wallet_2")!;
    const wallet3 = simnet.getAccounts().get("wallet_3")!;

    simnet.callPublicFn(CONTRACT, "check-in", [], wallet1);
    simnet.callPublicFn(CONTRACT, "check-in", [], wallet2);
    simnet.callPublicFn(CONTRACT, "check-in", [], wallet1); // repeat
    simnet.callPublicFn(CONTRACT, "check-in", [], wallet3);

    const stats = simnet.callReadOnlyFn(CONTRACT, "get-stats", [], wallet1);

    expect(stats.result).toStrictEqual(Cl.tuple({
      totalAddresses: Cl.uint(3),
      totalCheckIns: Cl.uint(4),
    }));
  });

  it("enumerates registered addresses via index", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const wallet2 = simnet.getAccounts().get("wallet_2")!;
    const wallet3 = simnet.getAccounts().get("wallet_3")!;

    simnet.callPublicFn(CONTRACT, "check-in", [], wallet1);
    simnet.callPublicFn(CONTRACT, "check-in", [], wallet2);
    simnet.callPublicFn(CONTRACT, "check-in", [], wallet3);

    // Enumerate all registered addresses
    const addr0 = simnet.callReadOnlyFn(CONTRACT, "get-address-at", [Cl.uint(0)], wallet1);
    const addr1 = simnet.callReadOnlyFn(CONTRACT, "get-address-at", [Cl.uint(1)], wallet1);
    const addr2 = simnet.callReadOnlyFn(CONTRACT, "get-address-at", [Cl.uint(2)], wallet1);
    const addr3 = simnet.callReadOnlyFn(CONTRACT, "get-address-at", [Cl.uint(3)], wallet1);

    expect(addr0.result).toBeSome(Cl.principal(wallet1));
    expect(addr1.result).toBeSome(Cl.principal(wallet2));
    expect(addr2.result).toBeSome(Cl.principal(wallet3));
    expect(addr3.result).toBeNone(); // Out of bounds
  });

  it("detects alive vs stale addresses", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;

    simnet.callPublicFn(CONTRACT, "check-in", [], wallet1);

    // Immediately after check-in: alive
    let alive = simnet.callReadOnlyFn(
      CONTRACT,
      "is-alive",
      [Cl.principal(wallet1), Cl.uint(10)],
      wallet1
    );
    expect(alive.result).toBeBool(true);

    // Mine blocks to make stale
    simnet.mineEmptyBlocks(15);

    alive = simnet.callReadOnlyFn(
      CONTRACT,
      "is-alive",
      [Cl.principal(wallet1), Cl.uint(10)],
      wallet1
    );
    expect(alive.result).toBeBool(false);
  });

  it("returns none for unregistered addresses", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const wallet2 = simnet.getAccounts().get("wallet_2")!;

    const reg = simnet.callReadOnlyFn(
      CONTRACT,
      "get-registration",
      [Cl.principal(wallet2)],
      wallet1
    );

    expect(reg.result).toBeNone();
  });
});
```

### Console Testing

```bash
clarinet console
```

```clarity
;; Check in
(contract-call? .heartbeat-registry check-in)

;; View your registration (full snapshot)
(contract-call? .heartbeat-registry get-registration tx-sender)

;; Check if you're alive (within 100 blocks)
(contract-call? .heartbeat-registry is-alive tx-sender u100)

;; Check stats
(contract-call? .heartbeat-registry get-stats)

;; Enumerate all registered addresses
(contract-call? .heartbeat-registry get-address-at u0)
(contract-call? .heartbeat-registry get-address-at u1)

;; Get current chain state
(contract-call? .heartbeat-registry get-current-block-info)
```

## Integration Examples

### Agent Heartbeat Service

```typescript
import { makeContractCall, broadcastTransaction, callReadOnlyFunction, cvToValue } from "@stacks/transactions";

const CONTRACT_ADDRESS = "SP...";
const CONTRACT_NAME = "heartbeat-registry";

interface HeartbeatResult {
  txid: string;
  stacksBlock: number;
  burnBlock: number;
  blockTime: number;
  count: number;
}

// Check in (write)
async function checkIn(senderKey: string): Promise<HeartbeatResult> {
  const txOptions = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "check-in",
    functionArgs: [],
    senderKey,
    network: "mainnet",
  };

  const tx = await makeContractCall(txOptions);
  const result = await broadcastTransaction(tx);

  // Note: actual values come from transaction result after confirmation
  return {
    txid: result.txid,
    stacksBlock: 0, // populated after confirmation
    burnBlock: 0,
    blockTime: 0,
    count: 0,
  };
}

// Check if agent is alive
async function isAlive(address: string, maxBlocks: number = 144): Promise<boolean> {
  const result = await callReadOnlyFunction({
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "is-alive",
    functionArgs: [principalCV(address), uintCV(maxBlocks)],
    senderAddress: address,
  });
  return cvToValue(result);
}

// Get agent status
async function getAgentStatus(address: string) {
  const reg = await callReadOnlyFunction({
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "get-registration",
    functionArgs: [principalCV(address)],
    senderAddress: address,
  });

  const data = cvToValue(reg);
  if (!data) return null;

  return {
    lastCheckIn: new Date(Number(data.blockTime) * 1000),
    checkInCount: Number(data.count),
    stacksBlock: Number(data.stacksBlock),
    burnBlock: Number(data.burnBlock),
    stacksBlockHash: data.stacksBlockHash,
    burnBlockHash: data.burnBlockHash,
  };
}

// Enumerate all registered addresses
async function getAllRegisteredAddresses(): Promise<string[]> {
  const stats = await callReadOnlyFunction({
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "get-stats",
    functionArgs: [],
    senderAddress: CONTRACT_ADDRESS,
  });

  const { totalAddresses } = cvToValue(stats);
  const addresses: string[] = [];

  for (let i = 0; i < Number(totalAddresses); i++) {
    const result = await callReadOnlyFunction({
      contractAddress: CONTRACT_ADDRESS,
      contractName: CONTRACT_NAME,
      functionName: "get-address-at",
      functionArgs: [uintCV(i)],
      senderAddress: CONTRACT_ADDRESS,
    });

    const addr = cvToValue(result);
    if (addr) addresses.push(addr);
  }

  return addresses;
}
```

### Cron-Based Heartbeat

```typescript
// heartbeat-worker.ts
// Run via cron every hour: 0 * * * * node heartbeat-worker.js

import { checkIn, isAlive } from "./heartbeat-client";

const AGENT_KEY = process.env.AGENT_PRIVATE_KEY!;
const AGENT_ADDRESS = process.env.AGENT_ADDRESS!;
const ALERT_WEBHOOK = process.env.ALERT_WEBHOOK;

async function heartbeat() {
  try {
    // Check if we're still marked as alive
    const alive = await isAlive(AGENT_ADDRESS, 200); // ~33 hours
    console.log(`Agent alive status: ${alive}`);

    // Submit heartbeat
    const result = await checkIn(AGENT_KEY);
    console.log(`Heartbeat submitted: ${result.txid}`);

    return { success: true, txid: result.txid };
  } catch (error) {
    console.error("Heartbeat failed:", error);

    // Alert on failure
    if (ALERT_WEBHOOK) {
      await fetch(ALERT_WEBHOOK, {
        method: "POST",
        body: JSON.stringify({
          text: `Agent heartbeat failed: ${error.message}`,
          agent: AGENT_ADDRESS,
        }),
      });
    }

    return { success: false, error: error.message };
  }
}

heartbeat();
```

### Multi-Agent Monitoring

```typescript
// Monitor a fleet of agents
async function checkFleetHealth(agents: string[]): Promise<Map<string, boolean>> {
  const health = new Map<string, boolean>();

  for (const agent of agents) {
    const alive = await isAlive(agent, 144); // 1 day threshold
    health.set(agent, alive);
  }

  return health;
}

// Alert on stale agents
async function alertStaleAgents(agents: string[]) {
  const health = await checkFleetHealth(agents);

  const stale = [...health.entries()]
    .filter(([_, alive]) => !alive)
    .map(([agent, _]) => agent);

  if (stale.length > 0) {
    console.warn(`Stale agents detected: ${stale.join(", ")}`);
    // Send alerts...
  }
}
```

## Extensions

### Add Metadata

Store optional context with each check-in:

```clarity
(define-public (check-in-with-memo (memo (string-ascii 64)))
  ;; Include memo in snapshot
)
```

### Rate Limiting

See `patterns/clarity-registry-contracts.md` for rate limiting pattern.

### History Tracking

Store last N check-ins per address for audit trail - see patterns doc for append-only pattern.

## Deployment Checklist

- [ ] Run `clarinet check` - no errors
- [ ] Run `npm test` - all tests pass
- [ ] Verify Clarity version compatibility (needs Clarity 4 for `stacks-block-time`)
- [ ] Test `get-stacks-block-info?` and `get-burn-block-info?` return values
- [ ] Check execution costs with `::get_costs` in console
- [ ] Deploy to testnet, verify all read-only functions
- [ ] Document contract address after mainnet deployment

## Cost Analysis

After deployment, verify costs in Clarinet console:

```clarity
(contract-call? .heartbeat-registry check-in)
::get_costs
```

The block hash lookups add ~2 read operations. If cost is prohibitive, consider a "lite" version without hashes.

## Related

- `patterns/clarity-registry-contracts.md` - Block snapshot, registry patterns
- `patterns/clarity-patterns.md` - Rate limiting, event patterns
- `context/clarity-reference.md` - Block info functions
- `runbook/clarity-proof-of-existence.md` - Related attestation pattern
