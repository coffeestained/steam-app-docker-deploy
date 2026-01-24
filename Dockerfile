FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMCMD_DIR=/steamcmd
ENV APP_DIR=/app

RUN dpkg --add-architecture i386 \
 && apt update \
 && apt install -y \
    steamcmd \
    lib32gcc-s1 \
    lib32stdc++6 \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${STEAMCMD_DIR} ${APP_DIR}

WORKDIR ${STEAMCMD_DIR}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
