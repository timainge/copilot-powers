#!/usr/bin/env bash
# Post-Tool Hook: Progress Tracking
# Tracks successful KB write operations for build progress monitoring.
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.toolName // "unknown"')
RESULT=$(echo "$INPUT" | jq -r '.toolResult.resultType // "unknown"')

# Track KB write progress
if [ "$TOOL" = "edit" ] && [ "$RESULT" = "success" ]; then
  LOG_DIR="$(dirname "$0")/../../"
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ),edit,success" >> "${LOG_DIR}/.kb-build-progress.csv"
fi
