# Clarity Testing Quick Reference

Quick reference for the Clarity testing toolkit: Clarinet SDK, Clarunit, RV, and Stxer.

## Testing Pyramid

```
┌─────────────────────────────────────┐
│  Stxer (Historical Simulation)      │  Mainnet fork, pre-deployment validation
├─────────────────────────────────────┤
│  RV (Property-Based Fuzzing)        │  Invariants, edge cases, battle-grade
├─────────────────────────────────────┤
│  Vitest + Clarinet SDK              │  Integration tests, TypeScript
├─────────────────────────────────────┤
│  Clarunit                           │  Unit tests in Clarity itself
└─────────────────────────────────────┘
```

## When to Use Each Tool

| Tool | Use When | Skip When |
|------|----------|-----------|
| **Clarinet SDK** | Standard testing, CI/CD, type-safe | - |
| **Clarunit** | Testing Clarity logic in Clarity, simple assertions | Complex multi-account flows |
| **RV** | Treasuries, DAOs, high-value contracts, finding edge cases | Simple contracts, time pressure |
| **Stxer** | Pre-mainnet validation, governance simulations | Early development, testnet-only |

---

## Clarinet SDK (vitest)

### Setup

```bash
npm install @hirosystems/clarinet-sdk vitest vitest-environment-clarinet
```

**vitest.config.js:**
```javascript
import { defineConfig } from "vitest/config";
import { vitestSetupFilePath, getClarinetVitestsArgv } from "@hirosystems/clarinet-sdk/vitest";

export default defineConfig({
  test: {
    environment: "clarinet",
    singleThread: true,
    setupFiles: [vitestSetupFilePath],
    environmentOptions: {
      clarinet: getClarinetVitestsArgv(),
    },
  },
});
```

### Key Gotchas

- **NO `beforeAll`/`beforeEach`** - Simnet resets each test file session
- **Single thread required** - `singleThread: true` for simnet isolation
- **120s timeout for MXS** - Increase timeout when using mainnet fork

### Test Structure (Arrange-Act-Assert)

```typescript
import { Cl } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

describe("my-contract", () => {
  it("transfers tokens correctly", () => {
    // ARRANGE
    const deployer = simnet.deployer;
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const amount = 100;

    // ACT
    const result = simnet.callPublicFn(
      "my-contract",
      "transfer",
      [Cl.uint(amount), Cl.principal(wallet1)],
      deployer
    );

    // ASSERT
    expect(result.result).toBeOk(Cl.bool(true));
  });
});
```

### Clarity Value Conversions

```typescript
import { Cl, cvToValue, cvToJSON } from "@stacks/transactions";

// Building Clarity values
Cl.uint(100)                           // uint
Cl.int(-50)                            // int
Cl.bool(true)                          // bool
Cl.principal("SP123...")               // principal
Cl.standardPrincipal("SP123...")       // standard principal
Cl.contractPrincipal("SP123", "name")  // contract principal
Cl.stringAscii("hello")                // (string-ascii N)
Cl.stringUtf8("hello")                 // (string-utf8 N)
Cl.bufferFromHex("deadbeef")           // (buff N)
Cl.tuple({ amount: Cl.uint(100) })     // tuple
Cl.list([Cl.uint(1), Cl.uint(2)])      // list
Cl.some(Cl.uint(100))                  // (some value)
Cl.none()                              // none

// Extracting JS values
cvToValue(result.result)               // Generic conversion
cvToValue(result.result, true)         // With bigint for uints
cvToJSON(result.result)                // JSON-friendly format
```

### Custom Matchers

```typescript
expect(result.result).toBeOk(Cl.uint(100));
expect(result.result).toBeErr(Cl.uint(1));
expect(result.result).toBeBool(true);
expect(result.result).toBeUint(100);
expect(result.result).toBePrincipal("SP123...");
```

### Reusable Helpers Pattern

```typescript
// helpers/my-contract.ts
export function transfer(
  simnet: Simnet,
  amount: number,
  recipient: string,
  sender: string
) {
  return simnet.callPublicFn(
    "my-contract",
    "transfer",
    [Cl.uint(amount), Cl.principal(recipient)],
    sender
  );
}

export function getBalance(simnet: Simnet, owner: string) {
  const result = simnet.callReadOnlyFn(
    "my-contract",
    "get-balance",
    [Cl.principal(owner)],
    owner
  );
  return cvToValue(result.result);
}
```

### Type Generation Tools

| Tool | Description |
|------|-------------|
| [clarigen](https://github.com/mechanismHQ/clarigen) | Generate TypeScript types from contracts |
| [secondlayer](https://github.com/ryanwaits/secondlayer) | Alternative type generator |

---

## Clarunit

Test Clarity with Clarity. Useful for pure logic testing.

### Setup

```bash
npm install @stacks/clarunit
```

**tests/clarunit.test.ts:**
```typescript
import { clarunit } from "@stacks/clarunit";
clarunit(simnet);
```

### Test File Convention

- File: `tests/my-contract_test.clar`
- Functions: Start with `test-`
- Add to `Clarinet.toml` under `[contracts]`

### Basic Test

```clarity
;; @name Multiplication works correctly
(define-public (test-multiply)
  (begin
    (asserts! (is-eq u8 (contract-call? .math multiply u2 u4))
      (err "2 * 4 should equal 8"))
    (ok true)))
```

### Annotations

| Annotation | Purpose |
|------------|---------|
| `@name` | Descriptive test name |
| `@caller` | Override tx-sender (wallet name or `'SP...` principal) |
| `@prepare` | Custom setup function |
| `@no-prepare` | Skip default prepare |
| `@mine-blocks-before N` | Mine N blocks before test |

### Prepare Function

```clarity
(define-public (prepare)
  (begin
    (try! (contract-call? .my-contract init))
    (ok true)))
```

### Flow Tests (Multi-Account)

File: `tests/my-contract_flow_test.clar`

```clarity
;; @name Vote and execute proposal
;; @format-ignore
(define-public (test-vote-flow)
  (begin
    ;; @caller wallet_1
    (unwrap! (contract-call? .dao vote-yes) (err "vote failed"))
    ;; @caller wallet_2
    (unwrap! (contract-call? .dao vote-yes) (err "vote failed"))
    ;; @caller deployer
    (unwrap! (contract-call? .dao execute) (err "execute failed"))
    (ok true)))
```

---

## RV (Rendezvous) - Fuzzy Testing

Property-based testing for battle-grade contracts.

### Setup

```bash
npm install @stacks/rendezvous
```

### Test File Convention

- File: `contracts/my-contract.tests.clar`
- Properties: `test-*` (public functions)
- Invariants: `invariant-*` (read-only functions)

### Run Commands

```bash
npx rv . my-contract test              # Property tests
npx rv . my-contract invariant         # Invariant tests
npx rv . my-contract test --runs=1000  # Custom iterations
npx rv . my-contract test --seed=12345 # Reproduce failure
```

### Property Test

```clarity
;; Property: loan amount always increases correctly
(define-public (test-borrow (amount uint))
  (if (is-eq amount u0)
    (ok false)  ;; Discard invalid input
    (let ((initial (get-loan tx-sender)))
      (try! (borrow amount))
      (asserts! (is-eq (get-loan tx-sender) (+ initial amount))
        (err u999))
      (ok true))))
```

### Invariant Test

```clarity
;; Invariant: total supply never exceeds cap
(define-read-only (invariant-supply-capped)
  (<= (var-get total-supply) MAX_SUPPLY))
```

### Return Values

| Return | Meaning |
|--------|---------|
| `(ok true)` | Test passed |
| `(ok false)` | Discard (invalid precondition) |
| `(err ...)` | Test failed |

---

## Stxer - Mainnet Simulations

Simulate against real mainnet state before deployment.

### Setup

```bash
npm install stxer
```

### Basic Simulation

```typescript
import { SimulationBuilder } from "stxer";
import { boolCV, uintCV } from "@stacks/transactions";

SimulationBuilder.new()
  .useBlockHeight(3491155)  // Fork mainnet at this block
  .addContractDeploy({
    contract_name: "my-contract",
    source_code: contractSource,
    deployer: "SP123..."
  })
  .addContractCall({
    contract_id: "SP123.my-contract",
    function_name: "init",
    function_args: [boolCV(true)],
    sender: "SP123...",
    nonce: 1
  })
  .run()
  .then(result => console.log(`View: https://stxer.xyz/simulations/${result.id}`));
```

### When to Use

- Pre-mainnet deployment validation
- Governance proposal testing
- Testing with real token balances
- Multi-transaction sequence validation

---

## Project Structure (Full Stack)

```
my-project/
├── Clarinet.toml
├── vitest.config.js
├── package.json
├── contracts/
│   ├── my-contract.clar
│   └── my-contract.tests.clar      # RV tests
├── tests/
│   ├── my-contract.test.ts         # Vitest
│   ├── my-contract_test.clar       # Clarunit
│   └── clarunit.test.ts            # Clarunit runner
└── simulations/
    └── my-contract-stxer.ts        # Stxer
```

### package.json Scripts

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:rv": "npx rv . my-contract test",
    "test:rv:invariant": "npx rv . my-contract invariant",
    "test:stxer": "npx tsx simulations/my-contract-stxer.ts"
  }
}
```

---

## Style Guide

### Prefer Functions Over Arrow Functions

```typescript
// Good
function getBalance(owner: string) {
  return simnet.callReadOnlyFn(...);
}

// Avoid
const getBalance = (owner: string) => {
  return simnet.callReadOnlyFn(...);
};
```

### Constants for Reusable Values

```typescript
const DEPLOYER = simnet.deployer;
const WALLET_1 = simnet.getAccounts().get("wallet_1")!;
const CONTRACT_NAME = "my-contract";
const ERR_UNAUTHORIZED = Cl.uint(1);
```

### Strong Typing

```typescript
interface TransferResult {
  success: boolean;
  sender: string;
  recipient: string;
  amount: bigint;
}

function parseTransferResult(cv: ClarityValue): TransferResult {
  // Type-safe parsing
}
```

---

## References

- Example repo: https://github.com/friedger/clarity-ccip-026
- Clarinet docs: https://docs.hiro.so/clarinet
- RV docs: https://stacks-network.github.io/rendezvous/
- Stxer SDK: https://github.com/stxer/stxer-sdk
- Clarigen: https://github.com/mechanismHQ/clarigen
- Secondlayer: https://github.com/ryanwaits/secondlayer
