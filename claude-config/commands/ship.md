---
description: Deploy to production - requires explicit confirmation
allowed-tools: Bash, Read, AskUserQuestion
argument-hint: [version or tag]
---

Ship to production: $ARGUMENTS

⚠️ **This deploys to PRODUCTION** - requires explicit confirmation.

1. **Pre-flight checks**
   ```bash
   # Ensure on main/master
   git branch --show-current

   # Ensure up to date
   git fetch origin
   git status

   # Check CI status
   gh run list --branch main --limit 3
   ```

2. **Show deployment summary**
   ```
   PRODUCTION DEPLOYMENT
   ═══════════════════════════════════════
   ⚠️  DEPLOYING TO PRODUCTION

   Branch:     [branch]
   Commit:     [hash]
   Tag:        [version if applicable]

   Changes since last deploy:
   - [commit 1]
   - [commit 2]

   CI Status:  [status]
   ═══════════════════════════════════════
   ```

3. **Require explicit confirmation**
   Ask: "Type 'ship it' to confirm production deployment"
   - Only proceed on exact match
   - Any other input cancels

4. **Deploy**
   Based on project setup:
   ```bash
   # Vercel
   vercel --prod

   # GitHub release
   gh release create v[version]

   # Custom script
   ./scripts/deploy-prod.sh

   # GitHub Actions
   gh workflow run deploy.yml -f environment=production
   ```

5. **Post-deploy**
   - Log deployment to knowledge base
   - Monitor for errors
   - Suggest rollback command if issues

Version/tag: $ARGUMENTS
