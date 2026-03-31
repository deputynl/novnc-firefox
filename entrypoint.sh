#!/bin/bash
set -e

mkdir -p ~/.vnc

# Start Xvnc on display :1, no auth, localhost-only
Xvnc :1 \
    -SecurityTypes None \
    -rfbport 5901 \
    -geometry 1280x900 \
    -depth 24 \
    -localhost \
    &

# Wait for the X socket to appear
while [ ! -S /tmp/.X11-unix/X1 ]; do sleep 0.1; done

export DISPLAY=:1

# Start a D-Bus session — Firefox benefits from it
eval "$(dbus-launch --sh-syntax)"

# Start window manager
openbox &

# Start terminal
xterm &

# Serve noVNC and proxy WebSocket -> VNC (foreground, keeps container alive)
exec websockify --web /usr/share/novnc 6080 localhost:5901
