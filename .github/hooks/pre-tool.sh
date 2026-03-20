#!/usr/bin/env bash
# Pre-Tool Hook: Audit Log + Scope Enforcement
# Logs all tool invocations and enforces write restrictions for read-only agents.
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.toolName // "unknown"')
ARGS=$(echo "$INPUT" | jq -c '.toolArgs // {}')

# Audit log (always)
LOG_DIR="$(dirname "$0")/../../"
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"tool\":\"$TOOL\",\"args\":$ARGS}" \
  >> "${LOG_DIR}/.agent-audit.jsonl"

# Scope enforcement for read-only agents
# Set AGENT_MODE=kb-reader in the agent's environment to restrict writes
if [ "${AGENT_MODE:-}" = "kb-reader" ] && [ "$TOOL" = "edit" ]; then
  PATH_ARG=$(echo "$ARGS" | jq -r '.path // empty')
  if [[ ! "$PATH_ARG" =~ ^(kb/|tasks/) ]]; then
    echo '{"permissionDecision":"deny","permissionDecisionReason":"Read-only agent cannot edit source files"}'
    exit 0
  fi
fi
