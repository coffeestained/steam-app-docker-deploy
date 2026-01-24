#!/bin/bash
set -e

if [ -z "$STEAM_APP_ID" ]; then
  echo "STEAM_APP_ID not set"
  exit 1
fi

echo "Installing Steam app $STEAM_APP_ID..."

steamcmd \
  +force_install_dir /app \
  +login anonymous \
  +app_update "$STEAM_APP_ID" validate \
  +quit

echo "Starting app..."

cd /app
exec "$@"
