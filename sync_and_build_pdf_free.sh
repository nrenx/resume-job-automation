#!/usr/bin/env bash
set -euo pipefail

REPO_ACTIONS_URL="https://github.com/nrenx/resume-job-automation/actions/workflows/latex-pdf.yml"

# Create commit when there are tracked or untracked changes.
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "sync: update resume sources"
fi

branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo main)"

git push -u origin "$branch"

echo "Pushed to GitHub. Cloud PDF build starts on GitHub Actions."
open "$REPO_ACTIONS_URL"

echo "Opened workflow page. Download resume-pdf artifact after run completes."
