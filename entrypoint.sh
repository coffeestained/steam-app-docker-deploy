#!/bin/bash
set -e

APP_PID=""

update_app() {
  echo "[Updater] Checking for updates..."
  steamcmd \
    +force_install_dir /app \
    +login anonymous \
    +app_update "$STEAM_APP_ID" validate \
    +quit
}

start_app() {
  echo "[Runner] Starting app..."
  cd /app
  "$@" &
  APP_PID=$!
}

stop_app() {
  if [ -n "$APP_PID" ]; then
    echo "[Runner] Stopping app..."
    kill "$APP_PID"
    wait "$APP_PID" || true
  fi
}

# Initial install
update_app
start_app "$@"

# Midnight update loop
while true; do
  sleep 60
  NOW=$(date +%H:%M)

  if [ "$NOW" = "00:00" ]; then
    stop_app
    update_app
    start_app "$@"
    sleep 61
  fi
done
