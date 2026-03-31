# novnc-firefox

A minimal Docker container that serves a Firefox ESR browser session accessible from any web browser via noVNC. Designed as a remote browser for managing applications with a web UI.

## What's inside

| Component | Package |
|---|---|
| Base OS | Debian bookworm-slim |
| Browser | Firefox ESR (latest from Debian repos) |
| X server + VNC | TigerVNC (`Xvnc`) |
| Web VNC client | noVNC + websockify |
| Window manager | Openbox |
| Terminal | xterm |
| Network tools | `ping`, `netstat`, `ssh` |
| Privileges | `sudo` with passwordless access |

## Quick start

```bash
docker run -d -p 6080:6080 ghcr.io/deputynl/novnc-firefox:latest
```

Open **http://localhost:6080/** in your browser — you land directly in the live Firefox session. No VNC client, no password.

## With Docker Compose

Save the following as `docker-compose.yml` and run `docker compose up -d`:

```yaml
services:
  firefox:
    image: ghcr.io/deputynl/novnc-firefox:latest
    ports:
      - "6080:6080"
    restart: unless-stopped
```

Open **http://localhost:6080/** — the session starts automatically.

If you are running this behind a reverse proxy and want to bind only to localhost:

```yaml
services:
  firefox:
    image: ghcr.io/deputynl/novnc-firefox:latest
    ports:
      - "127.0.0.1:6080:6080"
    restart: unless-stopped
```

## Features

- **No authentication** — designed to sit behind your own security/proxy layer (e.g. Authelia, Traefik, Caddy, VPN)
- **Dynamic resize** — the virtual desktop automatically resizes to match your browser window
- **Passwordless sudo** — from the xterm terminal, run `sudo apt install <package>` to add tools on the fly (changes are lost on container restart; add them to the Dockerfile to make them permanent)
- **Multi-arch** — images published for `linux/amd64` and `linux/arm64`

## Ports

| Port | Purpose |
|---|---|
| `6080` | noVNC web UI (HTTP) |

The raw VNC port (5901) is bound to localhost only inside the container and is not exposed.

## Building and publishing

Requires Docker buildx. Authenticate to the GitHub Container Registry first:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u deputynl --password-stdin
```

Then build and push a versioned multi-arch image:

```bash
./build.sh 1.0.0
```

This tags the image as both `1.0.0` and `latest`.

## Security considerations

This container has no VNC password and runs `sudo` without a password. It is intended to be deployed behind an additional authentication layer and should **not** be exposed directly to the internet.
