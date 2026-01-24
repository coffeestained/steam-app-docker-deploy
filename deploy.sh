#!/bin/bash

read -p "Steam App ID: " STEAM_APP_ID
read -p "Container name: " CONTAINER_NAME
read -p "Host port to expose: " HOST_PORT
read -p "Container port (app listens on): " CONTAINER_PORT

docker build -t steam-app-runner .

docker run -d \
  --name "$CONTAINER_NAME" \
  -e STEAM_APP_ID="$STEAM_APP_ID" \
  -p "$HOST_PORT:$CONTAINER_PORT/udp" \
  --restart unless-stopped \
  steam-app-runner \
  ./start.sh
