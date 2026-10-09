# steam-server-docker

Run any Steam dedicated server in Docker. One image, app id at run time, nightly auto-update.

The container installs the app with SteamCMD, runs your start command as a non-root user, restarts it if it dies, and once a day stops → updates → restarts. Game data lives in a host volume so rebuilds are free.

## Runbook

```bash
git clone https://github.com/coffeestained/steam-server-docker && cd steam-server-docker

# compose (edit the app id / ports / command first)
docker compose up -d && docker compose logs -f

# or the script
./deploy.sh -a 380870 -n zomboid -p 16261/udp -p 16262/udp -- ./start-server.sh -servername mine
docker logs -f zomboid

# ops
docker stop zomboid              # clean shutdown (TERM is forwarded to the server)
docker restart zomboid           # forces an update check on the way up
sudo ufw allow 16261:16262/udp   # open the game ports; see linux-firewall-recipes for full hosts
```

## Knobs

| env | default | |
|---|---|---|
| `STEAM_APP_ID` | required | find it on steamdb.info |
| `UPDATE_TIME` | `00:00` | `HH:MM` container time, or `never` |
| `STEAM_BETA` | – | beta branch name |
| `STEAM_LOGIN` | `anonymous` | most dedicated servers allow anonymous |

Pairs with [linux-firewall-recipes](https://github.com/coffeestained/linux-firewall-recipes) (`steam-server` recipe) for host lockdown.

MIT © Matthew Grady
