#!/usr/bin/env bash
set -euo pipefail

REPO="nrenx/resume-job-automation"
WORKFLOW="latex-pdf.yml"
ARTIFACT_NAME="resume-pdf"
POLL_SECONDS=5
MAX_POLLS=60

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install with: brew install gh"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

# Commit local changes if present.
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "sync: update resume sources"
fi

branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo main)"
head_sha="$(git rev-parse HEAD)"

echo "Pushing branch $branch to origin..."
git push -u origin "$branch"

echo "Waiting for workflow run for commit $head_sha ..."
run_id=""
for _ in $(seq 1 "$MAX_POLLS"); do
  run_id="$(gh run list \
    --repo "$REPO" \
    --workflow "$WORKFLOW" \
    --branch "$branch" \
    --json databaseId,headSha,status,conclusion \
    --jq '[.[] | select(.headSha == "'$head_sha'")][0].databaseId')"

  if [[ -n "$run_id" && "$run_id" != "null" ]]; then
    break
  fi

  sleep "$POLL_SECONDS"
done

if [[ -z "$run_id" || "$run_id" == "null" ]]; then
  echo "Could not find a workflow run for commit $head_sha"
  echo "Open: https://github.com/$REPO/actions/workflows/$WORKFLOW"
  exit 1
fi

echo "Found run $run_id. Waiting for completion..."
gh run watch "$run_id" --repo "$REPO" --exit-status

echo "Downloading PDF artifact..."
gh run download "$run_id" --repo "$REPO" --name "$ARTIFACT_NAME" --dir .

# Flatten artifact output if gh created a subdirectory.
if [[ -f "$ARTIFACT_NAME/Bollineni_Narendra_original.pdf" ]]; then
  cp "$ARTIFACT_NAME/Bollineni_Narendra_original.pdf" ./Bollineni_Narendra_original.pdf
fi

echo "Done. Latest PDF is available in this folder."
