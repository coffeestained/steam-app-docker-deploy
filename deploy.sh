#!/usr/bin/env bash
# Build the image and run one server. Flags, not prompts, so it scripts.
#
#   ./deploy.sh -a 380870 -n zomboid -p 16261/udp -p 16262/udp -- ./start-server.sh -servername mine
#
#   -a  steam app id (required)      -n  container name (default: steam-<appid>)
#   -p  port to publish, repeatable  -t  update time HH:MM (default 00:00)
#   -d  host data dir (default ./data/<name>)   --  everything after is the start command
set -euo pipefail

APP_ID="" NAME="" DATA="" UPDATE_TIME="00:00"
PORTS=()

usage() { sed -n '2,9p' "$0" >&2; exit 1; }

while getopts "a:n:p:t:d:" opt; do
  case "$opt" in
    a) APP_ID="$OPTARG" ;;
    n) NAME="$OPTARG" ;;
    p) PORTS+=(-p "$OPTARG:$OPTARG") ;;
    t) UPDATE_TIME="$OPTARG" ;;
    d) DATA="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

[[ -n "$APP_ID" && $# -gt 0 ]] || usage
NAME="${NAME:-steam-$APP_ID}"
DATA="${DATA:-$PWD/data/$NAME}"
mkdir -p "$DATA"

docker build -t steam-server-docker .

# Replace an old container of the same name so re-running is an upgrade.
docker rm -f "$NAME" 2>/dev/null || true
docker run -d --name "$NAME" \
  --restart unless-stopped \
  -e STEAM_APP_ID="$APP_ID" \
  -e UPDATE_TIME="$UPDATE_TIME" \
  -v "$DATA:/app" \
  "${PORTS[@]}" \
  steam-server-docker "$@"

echo "started $NAME  (logs: docker logs -f $NAME)"
