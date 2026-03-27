#!/usr/bin/env bash
set -euo pipefail

REPO="nrenx/resume-job-automation"
WORKFLOW="latex-pdf.yml"
ARTIFACT_NAME="resume-pdf"
POLL_SECONDS=5
MAX_POLLS=60
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
gh run watch "$run_id" --repo "$REPO" --exit-status

echo "Downloading PDF artifact..."
tmp_dir="$(mktemp -d)"
gh run download "$run_id" --repo "$REPO" --name "$ARTIFACT_NAME" --dir "$tmp_dir"

downloaded_pdf="$(find "$tmp_dir" -type f -name "*.pdf" | head -n 1)"

if [[ -z "$downloaded_pdf" ]]; then
  echo "No PDF artifact found in workflow run $run_id"
  rm -rf "$tmp_dir"
  exit 1
fi

base_pdf_path="$target_folder/$PDF_BASE_NAME.pdf"

if [[ ! -f "$base_pdf_path" ]]; then
  final_pdf_path="$base_pdf_path"
else
  max_version=0

  for existing_file in "$target_folder"/"$PDF_BASE_NAME"-v*.pdf; do
    if [[ -f "$existing_file" ]]; then
      file_name="$(basename "$existing_file")"
      version_part="${file_name#${PDF_BASE_NAME}-v}"
      version_number="${version_part%.pdf}"

      if [[ "$version_number" =~ ^[0-9]+$ ]] && (( version_number > max_version )); then
        max_version=$version_number
      fi
    fi
  done

  next_version=$((max_version + 1))
  final_pdf_path="$target_folder/$PDF_BASE_NAME-v$next_version.pdf"
fi

cp "$downloaded_pdf" "$final_pdf_path"
rm -rf "$tmp_dir"

echo "Done. Latest PDF saved to: $final_pdf_path"
