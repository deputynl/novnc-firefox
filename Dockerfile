FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server \
    openbox \
    xterm \
    novnc \
    python3-websockify \
    fonts-dejavu-core \
    dbus-x11 \
    iputils-ping \
    net-tools \
    openssh-client \
    sudo \
    wget \
    ca-certificates \
    && install -d -m 0755 /etc/apt/keyrings \
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
       > /etc/apt/sources.list.d/mozilla.list \
    && apt-get update && apt-get install -y --no-install-recommends firefox \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user \
    && echo 'user ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/user \
    && chmod 440 /etc/sudoers.d/user

# noVNC: redirect / straight into the connected session
RUN printf '<html><head><meta http-equiv="refresh" content="0;url=vnc.html?autoconnect=true&resize=remote"/></head></html>' \
    > /usr/share/novnc/index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Reduce memory footprint: single content process, no separate network/media-decoder
# processes, and a capped cache — this is a single-user, single-tab kiosk browser, so
# the isolation those processes normally buy has little value here.
COPY policies.json /usr/lib/firefox/distribution/policies.json

LABEL org.opencontainers.image.source="https://github.com/deputynl/novnc-firefox"
LABEL org.opencontainers.image.description="Minimal Docker container serving Firefox over a browser-accessible VNC session via noVNC"
LABEL org.opencontainers.image.licenses="MIT"

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:6080/ > /dev/null || exit 1

EXPOSE 6080

USER user
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]
