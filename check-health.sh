#!/usr/bin/env bash
#
# check-health.sh — Poll the /health endpoint and report status
#
# Usage:
#   ./check-health.sh              # Check once
#   ./check-health.sh --watch 5    # Check every 5 seconds (Ctrl+C to stop)
#
# This is a simple monitoring script for learning purposes.
# In production you'd use Prometheus, Datadog, New Relic, etc.

set -euo pipefail

URL="${HEALTH_URL:-http://localhost:3000/health}"
TIMEOUT=5

check() {
  local http_code
  local response
  local timestamp

  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Make the request, capture HTTP status and response body
  response=$(curl -s -w "\n%{http_code}" --max-time "$TIMEOUT" "$URL" 2>&1)
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [ "$http_code" = "200" ]; then
    echo "[$timestamp] ✅ HEALTHY — HTTP $http_code — $body"
    return 0
  else
    echo "[$timestamp] ❌ UNHEALTHY — HTTP $http_code — $body"
    return 1
  fi
}

# ── Main ──────────────────────────────────────────

if [ "${1:-}" = "--watch" ]; then
  INTERVAL="${2:-10}"
  echo "Watching $URL every ${INTERVAL}s (Ctrl+C to stop)"
  echo ""
  while true; do
    check
    sleep "$INTERVAL"
  done
elif [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "Usage: ./check-health.sh [--watch SECONDS]"
  echo ""
  echo "  No args       Check once and exit"
  echo "  --watch N     Check every N seconds"
  echo "  --help        Show this message"
else
  check
fi
