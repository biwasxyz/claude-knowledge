# Clarity Knowledge Nuggets

Quick facts and learnings about Clarity smart contracts and the Stacks blockchain.

## Entries

### 2026-01-02
- Clarity does NOT have a `lambda` keyword. Use `define-private` for internal helper functions.
- Always run `clarinet check` before committing contract changes.
- Use `(try!)` not `(unwrap!)` for recoverable errors where you want to propagate the error up.
