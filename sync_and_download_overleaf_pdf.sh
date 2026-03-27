#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="68dce7e04747763f5600a81b"
PDF_URL="https://www.overleaf.com/project/${PROJECT_ID}/download/pdf"

# Create commit when there are tracked or untracked changes.
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "sync: update resume sources"
fi

branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo main)"

# Push to GitHub repo requested by user.
git push -u origin "$branch"

# Push same commit to Overleaf cloud source repo.
git push overleaf "$branch"

# Open Overleaf cloud-compiled PDF download in browser.
open "$PDF_URL"

echo "Synced to GitHub and Overleaf; opened PDF download URL."
