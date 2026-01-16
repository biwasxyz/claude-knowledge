# Check Production Ready

Verify code is ready for production deployment.

## Overview

This procedure validates that code meets production standards: builds cleanly, tests pass, no security issues, and configuration is correct.

## Checks

### 1. Build Verification

```bash
# Node.js projects
npm run build
# or
pnpm build

# Check for build warnings that should be errors
npm run build 2>&1 | grep -i "warning"
```

**Pass criteria:**
- Build completes without errors
- No critical warnings (unused vars are OK, type errors are not)

### 2. Test Suite

```bash
# Run all tests
npm test

# Check coverage if configured
npm run test:coverage
```

**Pass criteria:**
- All tests pass
- No skipped tests (`.skip()`) without documented reason
- Coverage meets project threshold (if defined)

### 3. Linting and Type Checking

```bash
# Linting
npm run lint

# TypeScript type check (if applicable)
npx tsc --noEmit

# Clarity contracts
clarinet check
clarinet format --check
```

**Pass criteria:**
- No linting errors
- No type errors
- Contracts pass syntax check

### 4. Security Checks

```bash
# Dependency vulnerabilities
npm audit
# or
pnpm audit

# Check for hardcoded secrets
grep -rn "password\s*=" --include="*.ts" --include="*.js" --exclude-dir=node_modules
grep -rn "api[_-]?key\s*=" --include="*.ts" --include="*.js" --exclude-dir=node_modules
grep -rn "secret\s*=" --include="*.ts" --include="*.js" --exclude-dir=node_modules
```

**Pass criteria:**
- No high/critical vulnerabilities (or documented exceptions)
- No hardcoded credentials
- Secrets loaded from environment variables

### 5. Environment Configuration

Check that production configuration is correct:

```bash
# Verify .env.example exists and documents all vars
ls -la .env.example

# Check for development-only settings
grep -rn "localhost" --include="*.ts" --include="*.js" --exclude-dir=node_modules
grep -rn "127.0.0.1" --include="*.ts" --include="*.js" --exclude-dir=node_modules
```

**Pass criteria:**
- All required env vars documented in .env.example
- No hardcoded localhost/dev URLs in production code paths
- Production URLs use environment variables

### 6. Dependencies Check

```bash
# Check for dev dependencies that might be in production
cat package.json | grep -A 100 '"dependencies"'

# Look for test/dev packages in wrong section
# These should be in devDependencies:
# - jest, vitest, mocha
# - eslint, prettier
# - @types/* packages
```

### 7. Git Status

```bash
# No uncommitted changes
git status

# On correct branch (main/master)
git branch --show-current

# Up to date with remote
git fetch && git status
```

## Output Format

```
## Production Readiness Check

### Build
- [x] Build completes successfully
- [x] No blocking warnings

### Tests
- [x] All tests pass (47 passed, 0 failed)
- [ ] 2 skipped tests - review needed
  - src/api.test.ts: "handles timeout" - skipped
  - src/auth.test.ts: "refreshes token" - skipped

### Linting & Types
- [x] ESLint passes
- [x] TypeScript compiles
- [x] Clarinet check passes

### Security
- [x] No critical vulnerabilities
- [x] No hardcoded secrets found
- [ ] 1 moderate vulnerability in dependency
  - lodash < 4.17.21 - prototype pollution

### Environment
- [x] .env.example exists
- [x] No hardcoded dev URLs

### Git
- [x] Working directory clean
- [x] On main branch
- [x] Up to date with origin

### Summary
READY with 2 warnings - review skipped tests and lodash vulnerability
```

## When to Run

- Before tagging a release
- Before production deployment
- After merging significant features
- As part of release checklist

## Common Blockers

| Issue | Resolution |
|-------|------------|
| Build fails | Fix compilation errors |
| Tests fail | Fix failing tests or document known issues |
| Security vulnerabilities | Update dependencies or document exception |
| Uncommitted changes | Commit or stash |
| Wrong branch | Checkout main/master |
