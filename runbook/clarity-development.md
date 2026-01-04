# Clarity Development Runbook

Operational procedures for Clarity smart contract development.

## Project Setup

### Initialize New Clarinet Project
```bash
clarinet new my-project
cd my-project
```

### Add New Contract
```bash
clarinet contract new my-contract
```

This creates:
- `contracts/my-contract.clar`
- Test file in `tests/`
- Updates `Clarinet.toml`

## Development Workflow

### 1. Check Syntax
Always run before committing:
```bash
clarinet check
```

### 2. Run Tests
```bash
clarinet test
```

For specific test files:
```bash
clarinet test tests/my-contract_test.ts
```

### 3. Interactive Console
```bash
clarinet console
```

Useful console commands:
- `::get_costs` - Show execution costs of last call
- `::get_assets_maps` - Show all token balances
- `::advance_chain_tip N` - Mine N blocks
- `(contract-call? .contract fn args)` - Call functions

### 4. Check Costs
In Clarinet console:
```clarity
(contract-call? .my-contract expensive-function u100)
::get_costs
```

## Execution Cost Limits

| Category   | Block Limit | Read-Only Limit |
|------------|-------------|-----------------|
| Runtime    | 5,000,000,000 | 1,000,000,000 |
| Read count | 15,000 | 30 |
| Read bytes | 100,000,000 | 100,000 |
| Write count| 15,000 | 0 |
| Write bytes| 15,000,000 | 0 |

## Cost Optimization Tips

1. **Inline single-use values** - Avoid unnecessary `let` bindings
2. **Constants over data-vars** - Constants are cheaper to read
3. **Bulk operations** - Single call with list beats multiple calls
4. **Separate params vs tuples** - Flat params are cheaper for function calls
5. **Off-chain computation** - Move non-essential logic to UI/indexer

## Security Audit Checklist

### Color-Coded Risk Assessment
- **GREEN**: Harmless read-only functions
- **YELLOW**: State changes with proper guards
- **ORANGE**: Token transfers, external calls
- **RED**: Critical - admin functions, treasury access

### Per-Function Checklist
- [ ] Input validation with `asserts!`
- [ ] Proper principal checks (`tx-sender` vs `contract-caller`)
- [ ] Error codes for all failure paths
- [ ] No unbounded iteration
- [ ] Token operations use `try!`
- [ ] Post-conditions for asset protection

### Contract-Wide Checklist
- [ ] All public functions return `(response ok err)`
- [ ] Error codes are unique and documented
- [ ] Traits are whitelisted before use
- [ ] `as-contract` has explicit asset allowances (Clarity 4)
- [ ] Rate limiting on sensitive operations
- [ ] Admin functions have proper access control

## Deployment

### Testnet Deployment
```bash
clarinet deployments generate --testnet
clarinet deployments apply -p deployments/default.testnet-plan.yaml
```

### Mainnet Deployment
```bash
clarinet deployments generate --mainnet
clarinet deployments apply -p deployments/default.mainnet-plan.yaml
```

## Common Issues & Solutions

### "Contract too large"
- Split into multiple contracts using traits
- Move read-only helpers to separate contract
- Reduce string/buffer constants

### "Cost limit exceeded"
- Use `::get_costs` to identify expensive operations
- Paginate large data reads
- Cache computed values in data-vars

### "Trait not found"
- Ensure trait contract is deployed first
- Check deployment plan order in Clarinet.toml

### "Principal mismatch in tests"
- Use `Cl.standardPrincipal()` for addresses
- Use `Cl.contractPrincipal(deployer, "contract")` for contracts

## Useful Tools

| Tool | Purpose |
|------|---------|
| Clarinet | Local dev, testing, deployment |
| Stacks Explorer | Verify transactions, view contracts |
| Stacks.js | Build and broadcast transactions |
| Hiro API | Query chain data |

## Reference Contracts

Good examples to study:
- `~/dev/aibtc/aibtcdev-daos/contracts/` - DAO patterns
- `~/dev/citycoins/protocol/contracts/` - Token and treasury patterns
- `~/dev/stx-labs/clarity-starter/` - Basic templates
