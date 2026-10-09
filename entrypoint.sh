#!/usr/bin/env bash
# Installs/updates STEAM_APP_ID into /app, runs the start command, and
# restarts it after a daily update at UPDATE_TIME.
#
#   STEAM_APP_ID   required   e.g. 380870 (Project Zomboid)
#   UPDATE_TIME    00:00      HH:MM in the container's TZ, or "never"
#   STEAM_BETA     ""         optional beta branch name
#   STEAM_LOGIN    anonymous  most dedicated servers allow anonymous
#   $@             required   start command, run from /app
set -euo pipefail

: "${STEAM_APP_ID:?STEAM_APP_ID is required}"
UPDATE_TIME="${UPDATE_TIME:-00:00}"
STEAM_LOGIN="${STEAM_LOGIN:-anonymous}"
[[ $# -gt 0 ]] || { echo "no start command given" >&2; exit 1; }

APP_PID=""
LAST_UPDATE_DAY=""

log() { echo "[$(date +%H:%M:%S)] $*"; }

update_app() {
  log "steamcmd: updating app $STEAM_APP_ID"
  local beta=()
  [[ -n "${STEAM_BETA:-}" ]] && beta=(-beta "$STEAM_BETA")
  "$STEAMCMD_DIR/steamcmd.sh" \
    +force_install_dir "$APP_DIR" \
    +login "$STEAM_LOGIN" \
    +app_update "$STEAM_APP_ID" "${beta[@]}" validate \
    +quit
  LAST_UPDATE_DAY=$(date +%F)
}

start_app() {
  log "starting: $*"
  cd "$APP_DIR"
  "$@" &
  APP_PID=$!
}

stop_app() {
  [[ -n "$APP_PID" ]] || return 0
  log "stopping pid $APP_PID"
  kill -TERM "$APP_PID" 2>/dev/null || true
  wait "$APP_PID" 2>/dev/null || true
  APP_PID=""
}

# docker stop sends TERM; pass it on so the server saves and exits cleanly.
trap 'stop_app; exit 0' TERM INT

update_app
start_app "$@"

while true; do
  sleep 30
  # Restart if the server died on its own (crash, admin /quit).
  if ! kill -0 "$APP_PID" 2>/dev/null; then
    log "app exited; restarting"
    start_app "$@"
  fi
  if [[ "$UPDATE_TIME" != "never" && "$(date +%H:%M)" == "$UPDATE_TIME" && "$LAST_UPDATE_DAY" != "$(date +%F)" ]]; then
    stop_app
    update_app
    start_app "$@"
  fi
done
