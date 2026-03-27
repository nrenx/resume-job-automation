#!/usr/bin/env bash
set -euo pipefail

REPO="nrenx/resume-job-automation"
WORKFLOW="latex-pdf.yml"
ARTIFACT_NAME="resume-pdf"
POLL_SECONDS=30
MAX_POLLS=10
STATUS_POLL_SECONDS=30
MAX_STATUS_POLLS=15
PDF_BASE_NAME="Bollineni_Narendra_resume"

if [[ $# -lt 2 ]]; then
  echo "Usage: bash .github/push_and_download_pdf.sh <target_folder> <tex_file>"
  echo "Example: bash .github/push_and_download_pdf.sh 1.Google 1.Google/Google.tex"
  exit 1
fi

target_folder="$1"
tex_file="${2:-}"

if [[ -z "$tex_file" ]]; then
  echo "Error: tex_file argument is required."
  echo "Usage: bash .github/push_and_download_pdf.sh <target_folder> <tex_file>"
  exit 1
fi

if [[ ! -f "$tex_file" ]]; then
  echo "Error: TeX file not found: $tex_file"
  exit 1
fi

mkdir -p "$target_folder"

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

echo "Triggering workflow for TeX file: $tex_file"
dispatch_epoch="$(date +%s)"
gh workflow run "$WORKFLOW" \
  --repo "$REPO" \
  --ref "$branch" \
  -f "tex_file=$tex_file"

echo "Waiting for workflow run for commit $head_sha ..."
run_id=""
for _ in $(seq 1 "$MAX_POLLS"); do
  run_id="$(gh run list \
    --repo "$REPO" \
    --workflow "$WORKFLOW" \
    --branch "$branch" \
    --event workflow_dispatch \
    --json databaseId,headSha,status,conclusion,createdAt \
    --jq '[.[] | select(.headSha == "'$head_sha'" and (.createdAt | fromdateiso8601) >= '$dispatch_epoch')][0].databaseId')"

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
run_status=""
run_conclusion=""

for _ in $(seq 1 "$MAX_STATUS_POLLS"); do
  run_status="$(gh run view "$run_id" --repo "$REPO" --json status --jq '.status')"

  if [[ "$run_status" == "completed" ]]; then
    run_conclusion="$(gh run view "$run_id" --repo "$REPO" --json conclusion --jq '.conclusion')"
    break
  fi

  sleep "$STATUS_POLL_SECONDS"
done

if [[ "$run_status" != "completed" ]]; then
  echo "Workflow run $run_id did not complete in expected time."
  echo "Open: https://github.com/$REPO/actions/runs/$run_id"
  exit 1
fi

if [[ "$run_conclusion" != "success" ]]; then
  echo "Workflow run $run_id completed with status: $run_conclusion"
  echo "Open: https://github.com/$REPO/actions/runs/$run_id"
  exit 1
fi

echo "Workflow run $run_id completed successfully."

echo "Downloading PDF artifact..."
tmp_dir="$(mktemp -d)"
gh run download "$run_id" --repo "$REPO" --name "$ARTIFACT_NAME" --dir "$tmp_dir"

downloaded_pdf="$(find "$tmp_dir" -type f -name "*.pdf" | head -n 1)"

if [[ -z "$downloaded_pdf" ]]; then
  echo "No PDF artifact found in workflow run $run_id"
  rm -rf "$tmp_dir"
  exit 1
fi

tex_basename="$(basename "$tex_file" .tex)"

if [[ "$tex_basename" =~ -v([0-9]+)$ ]]; then
  tex_version="${BASH_REMATCH[1]}"
  final_pdf_path="$target_folder/$PDF_BASE_NAME-v$tex_version.pdf"
else
  final_pdf_path="$target_folder/$PDF_BASE_NAME.pdf"
fi

cp "$downloaded_pdf" "$final_pdf_path"
rm -rf "$tmp_dir"

echo "Done. Latest PDF saved to: $final_pdf_path"
