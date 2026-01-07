---
description: Run build pipeline for the current project
allowed-tools: Bash, Read, Glob
---

Run the build pipeline for the current project:

1. **Detect project type**
   - Check for `package.json` (Node/TypeScript)
   - Check for `Clarinet.toml` (Clarity)
   - Check for `requirements.txt` / `pyproject.toml` (Python)
   - Check for `Cargo.toml` (Rust)

2. **Run appropriate build**

   **Node/TypeScript:**
   ```bash
   npm run build
   # or
   npm run typecheck && npm run build
   ```

   **Clarity:**
   ```bash
   clarinet check
   clarinet test
   ```

   **Python:**
   ```bash
   python -m pytest
   # or
   ruff check .
   ```

3. **Run tests** (if separate from build)
   ```bash
   npm test
   # or
   clarinet test
   ```

4. **Report results**
   ```
   BUILD: [project name]
   ═══════════════════════════════════════
   Type:    [project type]
   Command: [command run]
   Status:  [PASS/FAIL]
   Time:    [duration]

   [output summary or errors]
   ═══════════════════════════════════════
   ```

5. **On failure**
   - Parse error messages
   - Suggest fixes
   - Offer to auto-fix if possible
