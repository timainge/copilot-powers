#!/usr/bin/env bash
# Session Start Hook: KB Freshness Check
# Reads hook input from stdin, checks if KB is stale relative to source files.
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')

BUILD_STATE="$CWD/kb/.build-state.json"
LAST_BUILD="$CWD/kb/.last-build"

# Check if KB has ever been built
if [ ! -f "$BUILD_STATE" ] || [ "$(jq -r '.last_full_build_sha' "$BUILD_STATE")" = "null" ]; then
  echo "KB INFO: Knowledge base has not been built yet. Run explore-codebase prompt to start."
  exit 0
fi

# Count source files changed since last KB build
LAST_BUILD_TIME=0
if [ -f "$LAST_BUILD" ]; then
  LAST_BUILD_TIME=$(stat -c %Y "$LAST_BUILD" 2>/dev/null || stat -f %m "$LAST_BUILD" 2>/dev/null || echo 0)
fi

# Find source files newer than last build (adapt extensions to your repo)
CHANGED_COUNT=0
if [ "$LAST_BUILD_TIME" -gt 0 ]; then
  CHANGED_COUNT=$(find "$CWD/src" -type f \( -name "*.cs" -o -name "*.ts" -o -name "*.py" \) -newer "$LAST_BUILD" 2>/dev/null | wc -l || echo 0)
fi

if [ "$CHANGED_COUNT" -gt 0 ]; then
  echo "KB WARNING: $CHANGED_COUNT source files changed since last KB build. Consider running kb-refresh."
fi

# Check coverage
if [ -f "$CWD/kb/.explorer-coverage.json" ]; then
  COVERAGE=$(jq -r '.coverage' "$CWD/kb/.explorer-coverage.json")
  echo "KB STATUS: Current coverage is ${COVERAGE}%."
fi
