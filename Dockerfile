# Generic SteamCMD runner. The app id and start command come in at run time,
# so one image serves any dedicated server.
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    STEAMCMD_DIR=/home/steam/steamcmd \
    APP_DIR=/app

# steamcmd is 32-bit; the i386 libs are the whole reason for the first line.
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl locales \
      lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 \
 && sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen \
 && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Never run game servers as root.
RUN useradd -m -d /home/steam steam \
 && mkdir -p ${STEAMCMD_DIR} ${APP_DIR} \
 && chown -R steam:steam /home/steam ${APP_DIR}

USER steam
WORKDIR ${STEAMCMD_DIR}

# Valve's tarball is the supported install; the first +quit self-updates it.
RUN curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar xz \
 && ./steamcmd.sh +quit

COPY --chown=steam:steam entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/app"]
WORKDIR ${APP_DIR}
ENTRYPOINT ["/entrypoint.sh"]
