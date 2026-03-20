#!/usr/bin/env bash
# Session End Hook: Coverage Validation
# Calculates KB coverage after a session completes.
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
REASON=$(echo "$INPUT" | jq -r '.reason // "unknown"')

if [ "$REASON" = "complete" ] || [ "$REASON" = "unknown" ]; then
  KB_INDEX="$CWD/kb/index"
  SRC_DIR="$CWD/src"

  if [ -d "$KB_INDEX" ] && [ -d "$SRC_DIR" ]; then
    INDEXED=$(find "$KB_INDEX" -name "*.json" ! -name "_dir.json" ! -name "_subsystem.json" ! -name "_system.json" 2>/dev/null | wc -l)
    TOTAL=$(find "$SRC_DIR" -type f \( -name "*.cs" -o -name "*.ts" -o -name "*.py" \) 2>/dev/null | wc -l)

    if [ "$TOTAL" -gt 0 ]; then
      COVERAGE=$(echo "scale=1; $INDEXED * 100 / $TOTAL" | bc 2>/dev/null || echo "0")
    else
      COVERAGE=0
    fi

    echo "{\"indexed\":$INDEXED,\"total\":$TOTAL,\"coverage\":$COVERAGE}" \
      > "$CWD/kb/.explorer-coverage.json"
  fi
fi
