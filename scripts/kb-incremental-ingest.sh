#!/usr/bin/env bash
# Git pre-commit hook companion: identifies changed files and triggers KB re-extraction.
# Install as a pre-commit hook or run manually.
#
# Usage: ./scripts/kb-incremental-ingest.sh [base_sha]
#   base_sha: defaults to value from kb/.build-state.json
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
BUILD_STATE="$REPO_ROOT/kb/.build-state.json"

if [ ! -f "$BUILD_STATE" ]; then
  echo "ERROR: No build state found. Run full exploration first."
  exit 1
fi

BASE_SHA="${1:-$(jq -r '.last_delta_sha // .last_full_build_sha' "$BUILD_STATE")}"

if [ "$BASE_SHA" = "null" ]; then
  echo "ERROR: No baseline SHA in build state. Run full exploration first."
  exit 1
fi

echo "Checking for changes since $BASE_SHA..."

# Find changed source files (adapt extensions to your stack)
CHANGED_FILES=$(git diff --name-only "$BASE_SHA" HEAD -- '*.cs' '*.csproj' '*.ts' '*.tsx' '*.py' 2>/dev/null || true)

if [ -z "$CHANGED_FILES" ]; then
  echo "No source files changed since $BASE_SHA. KB is up to date."
  exit 0
fi

CHANGE_COUNT=$(echo "$CHANGED_FILES" | wc -l)
echo "Found $CHANGE_COUNT changed files:"
echo "$CHANGED_FILES" | head -20
if [ "$CHANGE_COUNT" -gt 20 ]; then
  echo "... and $((CHANGE_COUNT - 20)) more"
fi

# Write change manifest for the kb-refresh prompt to consume
echo "$CHANGED_FILES" > "$REPO_ROOT/kb/.pending-changes.txt"
echo ""
echo "Change manifest written to kb/.pending-changes.txt"
echo "Run the kb-refresh prompt to process these changes."
