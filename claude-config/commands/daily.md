---
description: Generate daily work summary from all git repos in ~/dev
allowed-tools: Bash, Read, Write
argument-hint: [optional: date as YYYY-MM-DD, defaults to today]
---

Generate a concise daily summary of work across all git repositories for a non-technical audience.

## Instructions

1. **Run the daily git summary script**

   ```bash
   ~/.claude/skills/daily/daily-git-summary.sh $ARGUMENTS
   ```

   This scans all repos under `~/dev` and returns commits for the date.

2. **Analyze the output**
   - Group commits by project/repo
   - Identify themes (features, fixes, documentation, etc.)
   - Note any patterns across repos

3. **Generate non-technical summary**

   Output a summary with these sections:

   ```
   ## Daily Summary: [Date]

   ### What I Worked On
   [2-3 bullet points in plain English, no technical jargon]
   - Example: "Added documentation for our smart contract testing tools"
   - Example: "Fixed a bug in the user login flow"

   ### Projects Touched
   [Simple list of project names with one-line descriptions]

   ### Progress Made
   [Brief narrative: what moved forward today, any blockers resolved]
   ```

4. **Keep it brief**
   - Max 150 words total
   - No commit hashes, file names, or technical terms
   - Focus on outcomes and value delivered
   - Suitable for sharing in Slack or stand-up meetings

5. **Save the summary**
   - Save to `~/logs/YYYY-MM-DD-daily-summary.md`
   - Create ~/logs directory if it doesn't exist

Date: $ARGUMENTS (defaults to today's date)
