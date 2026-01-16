# Check Code Complete

Verify code is complete with no unfinished work, stubs, or dead code.

## Overview

This procedure scans the codebase for indicators of incomplete work that shouldn't be merged or deployed.

## Checks

### 1. TODO/FIXME Comments

Search for work-in-progress markers:

```bash
# Common patterns
grep -rn "TODO" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx"
grep -rn "FIXME" --include="*.ts" --include="*.js"
grep -rn "HACK" --include="*.ts" --include="*.js"
grep -rn "XXX" --include="*.ts" --include="*.js"

# Clarity contracts
grep -rn "TODO\|FIXME" --include="*.clar"
```

**Acceptable TODOs:**
- Documented technical debt with issue reference: `TODO(#123): refactor when API v2 releases`
- Future enhancements clearly marked as non-blocking

**Unacceptable TODOs:**
- `TODO: implement this`
- `FIXME: this is broken`
- Any TODO without context

### 2. Stub Implementations

Look for placeholder code:

```bash
# Empty function bodies
grep -rn "{ }" --include="*.ts" --include="*.js"
grep -rn "=> {}" --include="*.ts" --include="*.js"

# Throw not implemented
grep -rn "throw.*not implemented" --include="*.ts" --include="*.js"
grep -rn "NotImplementedError" --include="*.py"

# Console placeholders
grep -rn "console.log.*TODO\|console.log.*implement" --include="*.ts" --include="*.js"

# Return placeholders
grep -rn "return null.*TODO\|return undefined.*TODO" --include="*.ts" --include="*.js"
```

**Patterns to flag:**
- Empty function bodies (unless intentional no-op)
- Functions that only throw "not implemented"
- Hardcoded return values with TODO comments
- Pass statements in Python without docstring explaining why

### 3. Dead Code

Identify unused code that should be removed:

```bash
# Commented-out code blocks (not comments)
grep -rn "^[[:space:]]*//" --include="*.ts" | grep -v "^[[:space:]]*//[[:space:]]*[A-Z]"

# Unreachable code after return
# (manual review - look for code after return/throw statements)
```

**Dead code indicators:**
- Large commented-out code blocks
- Unused imports (TypeScript compiler can flag)
- Unused variables (linter can flag)
- Unreachable code paths
- Deprecated functions still in codebase

### 4. Debug/Test Artifacts

Check for development artifacts:

```bash
# Console statements
grep -rn "console.log\|console.debug" --include="*.ts" --include="*.tsx" --exclude-dir=node_modules

# Debugger statements
grep -rn "debugger" --include="*.ts" --include="*.js"

# Test-only code in production files
grep -rn "\.only(" --include="*.test.ts" --include="*.spec.ts"
```

## Output Format

```
## Code Completeness Check

### TODOs Found (3)
- src/api/client.ts:45 - TODO: add retry logic
- src/utils/parse.ts:12 - FIXME: handle edge case
- contracts/token.clar:89 - TODO: implement burn function

### Stub Implementations (1)
- src/services/analytics.ts:23 - Empty function body: `trackEvent() {}`

### Dead Code (2)
- src/old-handler.ts - Entire file unused (not imported anywhere)
- src/utils/helpers.ts:100-150 - Commented out code block

### Debug Artifacts (1)
- src/components/Form.tsx:34 - console.log statement

### Summary
7 issues found - review before merge
```

## When to Run

- Before creating a PR
- Before tagging a release
- During code review
- After large refactors

## Fixing Issues

| Issue | Action |
|-------|--------|
| Blocking TODO | Implement or create issue and reference it |
| Stub function | Implement or remove if not needed |
| Dead code | Delete it (git history preserves if needed) |
| Debug artifacts | Remove before merge |
