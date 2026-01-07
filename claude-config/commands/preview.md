---
description: Deploy to preview/staging environment
allowed-tools: Bash, Read, AskUserQuestion
argument-hint: [environment name]
---

Deploy to preview/staging environment: $ARGUMENTS

1. **Detect deployment method**
   - Check for Vercel (`vercel.json`)
   - Check for Netlify (`netlify.toml`)
   - Check for GitHub Actions preview workflow
   - Check for Docker (`Dockerfile`, `docker-compose.yml`)
   - Check for custom deploy scripts

2. **Pre-deploy checks**
   ```bash
   # Ensure clean build
   npm run build  # or equivalent

   # Check for uncommitted changes
   git status
   ```

3. **Deploy based on platform**

   **Vercel:**
   ```bash
   vercel --confirm
   ```

   **Netlify:**
   ```bash
   netlify deploy --dir=dist
   ```

   **GitHub Actions:**
   ```bash
   gh workflow run preview.yml
   ```

   **Custom:**
   - Look for `scripts/deploy-preview.sh`
   - Check package.json for deploy script

4. **Report preview URL**
   ```
   PREVIEW DEPLOYED
   ═══════════════════════════════════════
   Environment: [preview/staging]
   URL:         [preview URL]
   Branch:      [branch]
   Commit:      [hash]
   ═══════════════════════════════════════

   Preview will be available in ~[time]
   ```

5. **Offer next steps**
   - Suggest running smoke tests
   - Offer to create PR if not exists
   - Prompt for /approve when ready
