# Clarity Proof of Existence Contract

On-chain attestation for recording that data existed at a specific moment. Captures comprehensive chain context and optionally verifies authorship via SIP-018 signatures.

## Use Cases

- **Document timestamping**: Prove a document existed before a certain date
- **Commit-reveal schemes**: Commit to data before revealing it
- **Audit trails**: Immutable record of file hashes with Bitcoin anchor
- **Signed attestations**: Prove who attested to what and when (SIP-018)
- **Prior art proof**: Establish invention/creation dates
- **Agent coordination**: Record decisions with cryptographic proof

## Design Principles

This contract provides **first-write-wins** semantics - whoever attests to a hash first gets the timestamp. The full chain snapshot proves exactly when the attestation occurred, anchored to both Stacks and Bitcoin blocks.

See `patterns/clarity-registry-contracts.md` for the block snapshot pattern.

## Data Model

### Full Snapshot Per Attestation

| Field | Type | Source | Purpose |
|-------|------|--------|---------|
| `attestor` | `principal` | `tx-sender` or verified signer | Who attested |
| `stacksBlock` | `uint` | `stacks-block-height` | Ordering, age |
| `burnBlock` | `uint` | `burn-block-height` | Bitcoin anchor |
| `tenure` | `uint` | `tenure-height` | Nakamoto timing |
| `blockTime` | `uint` | `stacks-block-time` | Human timestamp |
| `chainId` | `uint` | `chain-id` | Network ID |
| `contractCaller` | `principal` | `contract-caller` | Proxy detection |
| `txSponsor` | `(optional principal)` | `tx-sponsor?` | Sponsored tx |
| `stacksBlockHash` | `(optional (buff 32))` | `get-stacks-block-info?` | Crypto anchor |
| `burnBlockHash` | `(optional (buff 32))` | `get-burn-block-info?` | BTC anchor |
| `memo` | `(optional (string-ascii 64))` | User input | Description |

## Contract Code

```clarity
;; proof-of-existence.clar
;; On-chain attestation with full chain context and SIP-018 signature support

;; ---------------------------------------------------------
;; Constants
;; ---------------------------------------------------------

(define-constant CONTRACT_OWNER tx-sender)

;; Errors
(define-constant ERR_ALREADY_ATTESTED (err u1001))
(define-constant ERR_NOT_FOUND (err u1002))
(define-constant ERR_INVALID_SIGNATURE (err u1003))

;; SIP-018 Structured Data Domain
(define-constant ATTESTATION_DOMAIN {
  name: "ProofOfExistence",
  version: "1",
  chain-id: chain-id
})

;; ---------------------------------------------------------
;; Data
;; ---------------------------------------------------------

(define-map Attestations
  (buff 32)
  {
    attestor: principal,
    stacksBlock: uint,
    burnBlock: uint,
    tenure: uint,
    blockTime: uint,
    chainId: uint,
    contractCaller: principal,
    txSponsor: (optional principal),
    stacksBlockHash: (optional (buff 32)),
    burnBlockHash: (optional (buff 32)),
    memo: (optional (string-ascii 64))
  }
)

;; Secondary index: attestor -> hashes
(define-map AttestorCount principal uint)
(define-map AttestorIndex
  {attestor: principal, index: uint}
  (buff 32)
)

;; Global stats
(define-data-var totalAttestations uint u0)

;; ---------------------------------------------------------
;; Private Functions
;; ---------------------------------------------------------

;; Capture full chain snapshot
(define-private (capture-snapshot (attestor principal) (memo (optional (string-ascii 64))))
  {
    attestor: attestor,
    stacksBlock: stacks-block-height,
    burnBlock: burn-block-height,
    tenure: tenure-height,
    blockTime: stacks-block-time,
    chainId: chain-id,
    contractCaller: contract-caller,
    txSponsor: tx-sponsor?,
    stacksBlockHash: (get-stacks-block-info? id-header-hash (- stacks-block-height u1)),
    burnBlockHash: (get-burn-block-info? header-hash (- burn-block-height u1)),
    memo: memo
  }
)

;; Update attestor's index
(define-private (update-attestor-index (attestor principal) (hash (buff 32)))
  (let ((idx (default-to u0 (map-get? AttestorCount attestor))))
    (map-set AttestorIndex {attestor: attestor, index: idx} hash)
    (map-set AttestorCount attestor (+ idx u1))
  )
)

;; ---------------------------------------------------------
;; Public Functions
;; ---------------------------------------------------------

;; Attest to a hash - first attestor wins
(define-public (attest (hash (buff 32)) (memo (optional (string-ascii 64))))
  (let
    (
      (attestor tx-sender)
      (existing (map-get? Attestations hash))
      (snapshot (capture-snapshot attestor memo))
    )
    ;; Only allow first attestation
    (asserts! (is-none existing) ERR_ALREADY_ATTESTED)

    ;; Record attestation
    (map-set Attestations hash snapshot)

    ;; Update secondary index
    (update-attestor-index attestor hash)

    ;; Update global stats
    (var-set totalAttestations (+ (var-get totalAttestations) u1))

    ;; Emit event
    (print {
      notification: "attestation",
      payload: {
        hash: hash,
        attestor: attestor,
        stacksBlock: (get stacksBlock snapshot),
        burnBlock: (get burnBlock snapshot),
        blockTime: (get blockTime snapshot),
        stacksBlockHash: (get stacksBlockHash snapshot),
        burnBlockHash: (get burnBlockHash snapshot),
        memo: memo
      }
    })

    (ok {
      hash: hash,
      stacksBlock: stacks-block-height,
      burnBlock: burn-block-height,
      blockTime: stacks-block-time,
      stacksBlockHash: (get stacksBlockHash snapshot),
      burnBlockHash: (get burnBlockHash snapshot)
    })
  )
)

;; Attest with SIP-018 signature verification
;; Allows someone to submit an attestation on behalf of the signer
(define-public (attest-with-signature
    (hash (buff 32))
    (memo (optional (string-ascii 64)))
    (signature (buff 65))
    (signer principal))
  (let
    (
      (existing (map-get? Attestations hash))
      ;; SIP-018 message hash: domain separator + structured data
      (messageHash (sha256 (concat
        (unwrap-panic (to-consensus-buff? ATTESTATION_DOMAIN))
        (unwrap-panic (to-consensus-buff? {hash: hash, memo: memo}))
      )))
      (recoveredKey (try! (secp256k1-recover? messageHash signature)))
      (recoveredPrincipal (principal-of? recoveredKey))
      (snapshot (capture-snapshot signer memo))
    )
    ;; Verify signature matches claimed signer
    (asserts! (is-eq (ok signer) recoveredPrincipal) ERR_INVALID_SIGNATURE)

    ;; Only allow first attestation
    (asserts! (is-none existing) ERR_ALREADY_ATTESTED)

    ;; Record attestation (attributed to signer, not tx-sender)
    (map-set Attestations hash snapshot)

    ;; Update signer's index
    (update-attestor-index signer hash)

    ;; Update global stats
    (var-set totalAttestations (+ (var-get totalAttestations) u1))

    ;; Emit event
    (print {
      notification: "attestation-signed",
      payload: {
        hash: hash,
        attestor: signer,
        submitter: tx-sender,
        stacksBlock: (get stacksBlock snapshot),
        burnBlock: (get burnBlock snapshot),
        blockTime: (get blockTime snapshot),
        stacksBlockHash: (get stacksBlockHash snapshot),
        burnBlockHash: (get burnBlockHash snapshot),
        memo: memo
      }
    })

    (ok {
      hash: hash,
      attestor: signer,
      stacksBlock: stacks-block-height,
      burnBlock: burn-block-height,
      blockTime: stacks-block-time,
      stacksBlockHash: (get stacksBlockHash snapshot),
      burnBlockHash: (get burnBlockHash snapshot)
    })
  )
)

;; ---------------------------------------------------------
;; Read-Only Functions
;; ---------------------------------------------------------

;; Get full attestation by hash
(define-read-only (get-attestation (hash (buff 32)))
  (map-get? Attestations hash)
)

;; Check if hash has been attested
(define-read-only (is-attested (hash (buff 32)))
  (is-some (map-get? Attestations hash))
)

;; Get attestor for a hash
(define-read-only (get-attestor (hash (buff 32)))
  (get attestor (map-get? Attestations hash))
)

;; Get block height when hash was attested
(define-read-only (get-attestation-block (hash (buff 32)))
  (get stacksBlock (map-get? Attestations hash))
)

;; Get Bitcoin block when hash was attested
(define-read-only (get-attestation-burn-block (hash (buff 32)))
  (get burnBlock (map-get? Attestations hash))
)

;; Get number of attestations by an address
(define-read-only (get-attestor-count (attestor principal))
  (default-to u0 (map-get? AttestorCount attestor))
)

;; Get hash at index for an attestor (for enumeration)
(define-read-only (get-attestor-hash-at (attestor principal) (index uint))
  (map-get? AttestorIndex {attestor: attestor, index: index})
)

;; Get global stats
(define-read-only (get-stats)
  {
    totalAttestations: (var-get totalAttestations)
  }
)

;; Verify a hash matches expected data (helper for off-chain verification)
(define-read-only (verify-hash (data (buff 1024)) (expectedHash (buff 32)))
  (is-eq (sha256 data) expectedHash)
)

;; Get the message hash for SIP-018 signing
(define-read-only (get-signing-message (hash (buff 32)) (memo (optional (string-ascii 64))))
  (sha256 (concat
    (unwrap-panic (to-consensus-buff? ATTESTATION_DOMAIN))
    (unwrap-panic (to-consensus-buff? {hash: hash, memo: memo}))
  ))
)

;; Get current chain state (for clients)
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
```

## SIP-018 Signature Integration

SIP-018 defines structured data signing for Stacks. This enables:
1. **Off-chain signing**: Sign attestation intent without submitting tx
2. **On-chain verification**: Contract verifies the signer authorized it
3. **Gas sponsorship**: Third party can submit and pay fees

### Signing Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Data Owner     │     │  Submitter       │     │  Contract       │
│                 │     │                  │     │                 │
│ 1. Hash data    │     │                  │     │                 │
│ 2. Sign message │────>│ 3. Submit tx     │────>│ 4. Verify sig   │
│    (off-chain)  │     │    with sig      │     │ 5. Record       │
│                 │     │    (pays fee)    │     │    (attrs to    │
│                 │     │                  │     │     signer)     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

### JavaScript Signing Example

```typescript
import { sha256 } from "@stacks/encryption";
import { signStructuredData, Cl } from "@stacks/transactions";

const DOMAIN = {
  name: "ProofOfExistence",
  version: "1",
  chainId: 1, // mainnet = 1, testnet = 2147483648
};

interface AttestationMessage {
  hash: Uint8Array;
  memo: string | null;
}

async function signAttestation(
  dataHash: Uint8Array,
  memo: string | null,
  privateKey: string
): Promise<string> {
  const message: AttestationMessage = {
    hash: dataHash,
    memo: memo,
  };

  // Sign using SIP-018 structured data format
  const signature = signStructuredData({
    domain: DOMAIN,
    message: message,
    privateKey: privateKey,
  });

  return signature;
}

// Usage
async function attestWithSignature(
  data: string,
  memo: string,
  signerKey: string,
  submitterKey: string
) {
  // 1. Hash the data
  const dataHash = sha256(Buffer.from(data));

  // 2. Signer creates signature (off-chain)
  const signature = await signAttestation(dataHash, memo, signerKey);

  // 3. Submitter broadcasts transaction
  const tx = await makeContractCall({
    contractAddress: CONTRACT_ADDRESS,
    contractName: "proof-of-existence",
    functionName: "attest-with-signature",
    functionArgs: [
      Cl.buffer(dataHash),
      memo ? Cl.some(Cl.stringAscii(memo)) : Cl.none(),
      Cl.buffer(Buffer.from(signature, "hex")),
      Cl.principal(signerAddress),
    ],
    senderKey: submitterKey, // submitter pays fee
    network: "mainnet",
  });

  return await broadcastTransaction(tx);
}
```

## Testing

### Clarinet SDK Test

```typescript
import { Cl, cvToValue } from "@stacks/transactions";
import { sha256 } from "@stacks/encryption";
import { describe, expect, it } from "vitest";

const CONTRACT = "proof-of-existence";

describe("proof-of-existence", function () {
  it("captures full snapshot on attestation", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const testData = "Important document content";
    const hash = sha256(Buffer.from(testData));

    const result = simnet.callPublicFn(
      CONTRACT,
      "attest",
      [Cl.buffer(hash), Cl.some(Cl.stringAscii("Contract v1"))],
      wallet1
    );

    expect(result.result).toBeOk(Cl.tuple({
      hash: Cl.buffer(hash),
      stacksBlock: Cl.uint(simnet.blockHeight),
      burnBlock: Cl.uint(simnet.burnBlockHeight),
      blockTime: Cl.uint(0),
      stacksBlockHash: Cl.some(Cl.buffer(new Uint8Array(32))),
      burnBlockHash: Cl.some(Cl.buffer(new Uint8Array(32))),
    }));
  });

  it("prevents duplicate attestations (first-write-wins)", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const wallet2 = simnet.getAccounts().get("wallet_2")!;
    const hash = sha256(Buffer.from("Unique data"));

    // First attestation succeeds
    const first = simnet.callPublicFn(
      CONTRACT,
      "attest",
      [Cl.buffer(hash), Cl.none()],
      wallet1
    );
    expect(first.result).toBeOk(expect.anything());

    // Second attestation fails
    const second = simnet.callPublicFn(
      CONTRACT,
      "attest",
      [Cl.buffer(hash), Cl.none()],
      wallet2
    );
    expect(second.result).toBeErr(Cl.uint(1001));
  });

  it("stores full attestation data retrievable by hash", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const hash = sha256(Buffer.from("Document with memo"));
    const memo = "Legal Agreement 2024";

    simnet.callPublicFn(
      CONTRACT,
      "attest",
      [Cl.buffer(hash), Cl.some(Cl.stringAscii(memo))],
      wallet1
    );

    const attestation = simnet.callReadOnlyFn(
      CONTRACT,
      "get-attestation",
      [Cl.buffer(hash)],
      wallet1
    );

    const value = cvToValue(attestation.result, true);
    expect(value.value.attestor).toBe(wallet1);
    expect(value.value.memo.value).toBe(memo);
    expect(value.value.chainId).toBe(2147483648n); // testnet
  });

  it("tracks attestor history via secondary index", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const hash1 = sha256(Buffer.from("Doc 1"));
    const hash2 = sha256(Buffer.from("Doc 2"));
    const hash3 = sha256(Buffer.from("Doc 3"));

    simnet.callPublicFn(CONTRACT, "attest", [Cl.buffer(hash1), Cl.none()], wallet1);
    simnet.callPublicFn(CONTRACT, "attest", [Cl.buffer(hash2), Cl.none()], wallet1);
    simnet.callPublicFn(CONTRACT, "attest", [Cl.buffer(hash3), Cl.none()], wallet1);

    // Check count
    const count = simnet.callReadOnlyFn(
      CONTRACT,
      "get-attestor-count",
      [Cl.principal(wallet1)],
      wallet1
    );
    expect(count.result).toBeUint(3);

    // Retrieve by index
    const secondHash = simnet.callReadOnlyFn(
      CONTRACT,
      "get-attestor-hash-at",
      [Cl.principal(wallet1), Cl.uint(1)],
      wallet1
    );
    expect(secondHash.result).toBeSome(Cl.buffer(hash2));
  });

  it("verifies hash matches data", function () {
    const wallet1 = simnet.getAccounts().get("wallet_1")!;
    const testData = "Verify this content";
    const correctHash = sha256(Buffer.from(testData));
    const wrongHash = sha256(Buffer.from("Different content"));

    const correct = simnet.callReadOnlyFn(
      CONTRACT,
      "verify-hash",
      [Cl.buffer(Buffer.from(testData)), Cl.buffer(correctHash)],
      wallet1
    );
    expect(correct.result).toBeBool(true);

    const wrong = simnet.callReadOnlyFn(
      CONTRACT,
      "verify-hash",
      [Cl.buffer(Buffer.from(testData)), Cl.buffer(wrongHash)],
      wallet1
    );
    expect(wrong.result).toBeBool(false);
  });
});
```

### Console Testing

```bash
clarinet console
```

```clarity
;; Create a test hash
(define-data-var test-hash (buff 32) (sha256 "Hello, World!"))

;; Attest to it
(contract-call? .proof-of-existence attest (var-get test-hash) (some "Test document"))

;; Get full attestation
(contract-call? .proof-of-existence get-attestation (var-get test-hash))

;; Check if attested
(contract-call? .proof-of-existence is-attested (var-get test-hash))

;; Get signing message for SIP-018
(contract-call? .proof-of-existence get-signing-message (var-get test-hash) (some "Memo"))

;; Get stats
(contract-call? .proof-of-existence get-stats)
```

## Integration Examples

### Document Attestation Service

```typescript
import { sha256 } from "@stacks/encryption";
import { makeContractCall, broadcastTransaction, Cl } from "@stacks/transactions";
import * as fs from "fs";

const CONTRACT_ADDRESS = "SP...";
const CONTRACT_NAME = "proof-of-existence";

interface AttestationProof {
  txid: string;
  hash: string;
  attestor: string;
  stacksBlock: number;
  burnBlock: number;
  blockTime: number;
  stacksBlockHash: string;
  burnBlockHash: string;
  filePath?: string;
  memo?: string;
}

// Hash a file and attest to it
async function attestFile(
  filePath: string,
  memo: string,
  senderKey: string
): Promise<AttestationProof> {
  // 1. Read and hash the file
  const fileBuffer = fs.readFileSync(filePath);
  const hash = sha256(fileBuffer);

  // 2. Submit attestation
  const tx = await makeContractCall({
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "attest",
    functionArgs: [
      Cl.buffer(hash),
      Cl.some(Cl.stringAscii(memo.slice(0, 64))),
    ],
    senderKey,
    network: "mainnet",
  });

  const result = await broadcastTransaction(tx);

  // 3. Return proof (full data comes after confirmation)
  return {
    txid: result.txid,
    hash: hash.toString("hex"),
    attestor: "", // populated after confirmation
    stacksBlock: 0,
    burnBlock: 0,
    blockTime: 0,
    stacksBlockHash: "",
    burnBlockHash: "",
    filePath,
    memo,
  };
}

// Verify a file against on-chain attestation
async function verifyFile(
  filePath: string
): Promise<{ valid: boolean; attestation?: any; reason?: string }> {
  const fileBuffer = fs.readFileSync(filePath);
  const hash = sha256(fileBuffer);

  const attestation = await getAttestation(hash.toString("hex"));

  if (!attestation) {
    return { valid: false, reason: "Not attested on-chain" };
  }

  return {
    valid: true,
    attestation: {
      attestor: attestation.attestor,
      stacksBlock: attestation.stacksBlock,
      burnBlock: attestation.burnBlock,
      blockTime: new Date(Number(attestation.blockTime) * 1000),
      stacksBlockHash: attestation.stacksBlockHash,
      burnBlockHash: attestation.burnBlockHash,
    },
  };
}
```

### Commit-Reveal Scheme

```typescript
// Use proof-of-existence for commit-reveal games, auctions, etc.

interface Commitment {
  hash: Uint8Array;
  salt: string;
  attestationTxid: string;
}

// Phase 1: Commit (hide your choice)
async function commit(
  secretChoice: string,
  senderKey: string
): Promise<Commitment> {
  // Generate random salt
  const salt = crypto.randomUUID();

  // Hash choice + salt
  const commitment = sha256(Buffer.from(secretChoice + salt));

  // Attest to commitment on-chain
  const tx = await makeContractCall({
    contractAddress: CONTRACT_ADDRESS,
    contractName: "proof-of-existence",
    functionName: "attest",
    functionArgs: [Cl.buffer(commitment), Cl.some(Cl.stringAscii("commitment"))],
    senderKey,
    network: "mainnet",
  });

  const result = await broadcastTransaction(tx);

  return {
    hash: commitment,
    salt: salt, // Keep secret until reveal!
    attestationTxid: result.txid,
  };
}

// Phase 2: Reveal (prove what you committed to)
async function reveal(
  secretChoice: string,
  commitment: Commitment
): Promise<{ valid: boolean; commitBlock?: number }> {
  // Recompute hash
  const computed = sha256(Buffer.from(secretChoice + commitment.salt));

  // Verify matches commitment
  if (!computed.equals(commitment.hash)) {
    return { valid: false };
  }

  // Verify on-chain
  const attestation = await getAttestation(commitment.hash);
  if (!attestation) {
    return { valid: false };
  }

  return {
    valid: true,
    commitBlock: Number(attestation.stacksBlock),
  };
}
```

### Off-Chain Storage Pattern

Store hash on-chain, content off-chain (IPFS, Arweave, S3):

```
┌─────────────────────────────────────────────────────────────┐
│                        On-Chain                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Proof-of-Existence Contract                         │    │
│  │  hash: 0xabc123...                                  │    │
│  │  attestor: SP123...                                 │    │
│  │  burnBlock: 850000 (Bitcoin anchor!)                │    │
│  │  burnBlockHash: 0x000000...                         │    │
│  │  memo: "ipfs://Qm..."                               │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ memo contains content address
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Off-Chain                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  IPFS / Arweave / S3                                 │    │
│  │  - Full document content                            │    │
│  │  - SHA256(content) MUST match on-chain hash         │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Extensions

### Multiple Attestors (Co-Signing)

Allow multiple parties to attest to the same hash:

```clarity
(define-map CoAttestations
  {hash: (buff 32), attestor: principal}
  {
    stacksBlock: uint,
    burnBlock: uint,
    blockTime: uint
  }
)

(define-public (co-attest (hash (buff 32)))
  ;; Anyone can co-attest after first attestation exists
  (begin
    (asserts! (is-attested hash) ERR_NOT_FOUND)
    (map-set CoAttestations {hash: hash, attestor: tx-sender} {...})
    (ok true)))
```

### Revocation

Allow attestors to revoke (but original record remains):

```clarity
(define-map Revocations (buff 32) {revokedAt: uint, reason: (optional (string-ascii 64))})

(define-public (revoke (hash (buff 32)) (reason (optional (string-ascii 64))))
  (let ((attestation (unwrap! (map-get? Attestations hash) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get attestor attestation)) ERR_UNAUTHORIZED)
    (map-set Revocations hash {revokedAt: stacks-block-height, reason: reason})
    (ok true)))

(define-read-only (is-revoked (hash (buff 32)))
  (is-some (map-get? Revocations hash)))
```

### Expiring Attestations

Add validity periods:

```clarity
(define-constant VALIDITY_BLOCKS u52560)  ;; ~1 year

(define-read-only (is-valid (hash (buff 32)))
  (match (map-get? Attestations hash)
    attestation (< (- stacks-block-height (get stacksBlock attestation)) VALIDITY_BLOCKS)
    false))
```

## Deployment Checklist

- [ ] Run `clarinet check` - no errors
- [ ] Run `npm test` - all tests pass
- [ ] Verify SIP-018 domain `chain-id` matches target network (1=mainnet, 2147483648=testnet)
- [ ] Test signature verification with real wallet keys
- [ ] Check execution costs with `::get_costs` - verify block hash lookups are acceptable
- [ ] Deploy to testnet, verify all read-only functions work
- [ ] Test `get-signing-message` matches off-chain computation
- [ ] Document contract address and SIP-018 domain for client integrations

## Cost Analysis

```clarity
;; In Clarinet console
(contract-call? .proof-of-existence attest 0x0000000000000000000000000000000000000000000000000000000000000001 (some "test"))
::get_costs
```

Block hash lookups add ~2 read operations. For high-volume use cases, consider a "lite" version without hashes.

## Related

- `context/sip-018.md` - SIP-018 structured data signing
- `patterns/clarity-registry-contracts.md` - Block snapshot, secondary index patterns
- `patterns/clarity-patterns.md` - Multi-party coordination
- `runbook/clarity-heartbeat-registry.md` - Related address registry pattern
