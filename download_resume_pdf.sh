#!/usr/bin/env bash
set -euo pipefail

REPO="nrenx/resume-job-automation"
WORKFLOW="latex-pdf.yml"
ARTIFACT_NAME="resume-pdf"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install with: brew install gh"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

echo "Looking for the latest successful run..."
run_id="$(gh run list \
  --repo "$REPO" \
  --workflow "$WORKFLOW" \
  --branch main \
  --json databaseId,status,conclusion \
  --jq '[.[] | select(.status == "completed" and .conclusion == "success")][0].databaseId')"

if [[ -z "$run_id" || "$run_id" == "null" ]]; then
  echo "No successful workflow run found yet. Push changes first and wait for Actions to finish."
  exit 1
fi

echo "Downloading artifact from run $run_id ..."
gh run download "$run_id" --repo "$REPO" --name "$ARTIFACT_NAME" --dir .

echo "Done. PDF downloaded to this folder."
