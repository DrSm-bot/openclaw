#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${RIMWORLD_GM_URL:-http://localhost:18800}"

usage() {
  cat <<EOF
Usage:
  rimworld-gm.sh status
  rimworld-gm.sh state [include_colonists] [include_resources]
  rimworld-gm.sh event <event_type> [points]
  rimworld-gm.sh message <text> [type]

Environment:
  RIMWORLD_GM_URL   Override API base URL (default: http://localhost:18800)
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

as_bool() {
  local val="${1:-true}"
  case "${val,,}" in
    1|true|yes|y|on) echo "true" ;;
    0|false|no|n|off) echo "false" ;;
    *) echo "true" ;;
  esac
}

http_get() {
  local url="$1"
  curl -sS -H "Accept: application/json" "$url"
}

http_post_json() {
  local url="$1"
  local payload="$2"
  curl -sS -X POST "$url" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$payload"
}

main() {
  require_cmd curl

  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    status)
      http_get "$BASE_URL/health"
      ;;

    state)
      local include_colonists include_resources
      include_colonists="$(as_bool "${1:-true}")"
      include_resources="$(as_bool "${2:-true}")"
      http_get "$BASE_URL/state?include_colonists=${include_colonists}&include_resources=${include_resources}"
      ;;

    event)
      local event_type points payload
      event_type="${1:-}"
      points="${2:-500}"
      if [[ -z "$event_type" ]]; then
        echo "event_type is required" >&2
        usage
        exit 2
      fi
      payload="{\"event_type\":\"${event_type}\",\"params\":{\"points\":${points}}}"
      http_post_json "$BASE_URL/event" "$payload"
      ;;

    message)
      local text style payload
      text="${1:-}"
      style="${2:-info}"
      if [[ -z "$text" ]]; then
        echo "message text is required" >&2
        usage
        exit 2
      fi
      payload="{\"text\":$(printf '%s' "$text" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'),\"type\":\"${style}\"}"
      http_post_json "$BASE_URL/message" "$payload"
      ;;

    -h|--help|help|"")
      usage
      ;;

    *)
      echo "Unknown command: $cmd" >&2
      usage
      exit 2
      ;;
  esac
}

main "$@"
