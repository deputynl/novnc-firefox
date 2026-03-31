FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server \
    openbox \
    xterm \
    firefox-esr \
    novnc \
    python3-websockify \
    fonts-dejavu-core \
    dbus-x11 \
    iputils-ping \
    net-tools \
    openssh-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash user \
    && echo 'user ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/user \
    && chmod 440 /etc/sudoers.d/user

# noVNC: redirect / straight into the connected session
RUN printf '<html><head><meta http-equiv="refresh" content="0;url=vnc.html?autoconnect=true&resize=remote"/></head></html>' \
    > /usr/share/novnc/index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080

USER user
WORKDIR /home/user

ENTRYPOINT ["/entrypoint.sh"]
