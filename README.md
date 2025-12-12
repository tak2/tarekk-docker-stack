# 🐳 Modern Docker Hosting Stack (Traefik + WordPress + APIs + Monitoring)

A production-ready Docker hosting stack for Ubuntu 22.04+ that bundles Traefik, Portainer, a WordPress site, Node.js and Python API templates, and Netdata monitoring. Secrets stay out of Git, certificates are issued automatically, and everything lives behind a hardened reverse proxy.

## 🚀 Features

### 🔐 Security
- No passwords or secrets in repo (.env generated at runtime)
- UFW firewall + Fail2Ban hardening script
- Optional Cloudflare compatibility
- Traefik dashboard gated by basic auth at `https://monitor.<domain>/traefik`

### 🌍 Domain & SSL
- Automatic Let’s Encrypt certificates
- Every subdomain routed through Traefik
- All traffic forced through HTTPS

### 📰 WordPress Hosting
- Host **1 WordPress site by default**
- Isolated network & database with persistent volumes
- Easy to add more sites if desired

### 🧑‍💻 Developer-Friendly APIs
- `nodeapi.<domain>` → Node.js Express
- `api.<domain>` → Python FastAPI

### 📊 Monitoring
- Netdata dashboard at `monitor.<domain>`
- Real-time CPU, memory, disk, network, and Docker metrics

## 📦 Requirements

- VPS with Ubuntu **22.04 LTS**
- Root or sudo access
- Domain name (e.g. `tarekk.com`) and DNS access to create A records

## 🛠 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-user>/<your-repo>.git
   cd <your-repo>
   ```

2. **Run the setup script (installs Docker + Compose, prepares Traefik, builds .env)**
   ```bash
   sudo ./setup.sh
   ```
   The script asks for your domain, subdomains, SSL email, and database passwords. It installs Docker, prepares Traefik folders, generates `.env`, and ensures the shared proxy network exists. If you ever need to recreate the network manually:
   ```bash
   docker network create proxy
   ```

3. **(Optional) Apply security hardening**
   ```bash
   sudo ./security-harden.sh
   ```
   See [Security Hardening](#-security-hardening) for details about what this script changes and links to upstream documentation.

4. **Start all services**
   ```bash
   docker compose up -d
   ```

5. **Verify containers**
   ```bash
   docker compose ps
   ```

## 🌍 DNS Configuration

1. Point the following subdomains to your server’s public IP (A records):
   ```
   panel.<domain>    → VPS IP (Portainer)
   blog1.<domain>    → VPS IP (WordPress)
   monitor.<domain>  → VPS IP (Netdata)
   nodeapi.<domain>  → VPS IP (Node Express API)
   api.<domain>      → VPS IP (Python FastAPI)
   ```
2. After DNS propagates, Traefik automatically requests SSL certificates.

## 🏗 Stack Architecture

```
Internet
   │
   ▼
┌─────────────┐     SSL + Reverse Proxy
│   Traefik   │  ← auto HTTPS via Let's Encrypt
└─────┬───────┘
      │
      ├── panel.<domain>   → Portainer (Docker UI)
      ├── blog1.<domain>   → WordPress
      ├── monitor.<domain> → Netdata Dashboard
      ├── nodeapi.<domain> → Node.js API
      └── api.<domain>     → Python FastAPI
```

## 🔎 Access points (domains and direct host ports)

| Service            | Traefik route                          | No-domain / direct access       | Notes |
| ------------------ | -------------------------------------- | ------------------------------- | ----- |
| Portainer          | `https://panel.<domain>`               | `https://<server-ip>:9443`      | 9443 uses Portainer’s bundled TLS cert; Traefik route stays on 443. |
| Traefik dashboard  | `https://monitor.<domain>/traefik`     | —                               | Protected by the sample basic-auth hash in `docker-compose.yml`; replace with your own `htpasswd` output. |
| Netdata            | `https://monitor.<domain>/netdata`     | `http://localhost:19999`        | `netdata-strip` middleware trims `/netdata` before forwarding. |
| Monitoring landing | `https://monitor.<domain>/`            | —                               | Simple nginx site with shortcuts to Netdata and Traefik. |
| WordPress          | `https://blog1.<domain>`               | `http://<server-ip>:8081`       | Direct ports are for testing without DNS/SSL. |
| Node API           | `https://nodeapi.<domain>`             | —                               | Served only through Traefik. |
| Python FastAPI     | `https://api.<domain>`                 | —                               | Served only through Traefik. |

Use these direct host ports when DNS is unavailable or while testing locally; production traffic should still flow through Traefik for TLS.

## 📰 WordPress Sites

- Default site: `blog1.<domain>`
- The site has its own MariaDB container, WordPress container, isolated network, and persistent volumes.
- To add a new site, duplicate the WordPress block in `docker-compose.yml` (e.g., copy `wp1` to create `wp2`) and adjust the subdomain, database, and labels.
- Direct, no-domain access for testing is available on the host at `http://<server-ip>:8081`.

## 🧑‍💻 API Endpoints

### Node API
- Location: `/api-node/`
- URL: `https://nodeapi.<domain>/`
- Default response:
  ```json
  {
    "message": "Hello from Node API!",
    "time": "2025-01-01T00:00:00Z"
  }
  ```

### Python FastAPI
- Location: `/api-python/`
- URL: `https://api.<domain>/`
- Install dependencies with the pinned requirements file:
  ```bash
  pip install -r api-python/requirements.txt
  ```
- Default response:
  ```json
  {
    "message": "Hello from Python FastAPI!",
    "time": "2025-01-01T00:00:00Z"
  }
  ```

## 📊 Monitoring

- Landing page: `https://monitor.<domain>/` (links to Netdata and Traefik)
- Netdata: `https://monitor.<domain>/netdata`
- Traefik dashboard: `https://monitor.<domain>/traefik`
- Direct Netdata container health check (from host): `curl http://localhost:19999/api/v1/info`

The monitoring host keeps all tooling on a single domain using `PathPrefix` routes. StripPrefix middlewares remove `/netdata` and `/traefik` before forwarding to the respective services, so internal apps still see root-relative paths.

## 🧰 Useful Commands

- View logs:
  ```bash
  docker logs -f traefik
  docker logs -f wp1
  ```
- Restart a service:
  ```bash
  docker compose restart wp1
  ```
- Bring down everything:
  ```bash
  docker compose down
  ```

## 🔐 Security Hardening

Running `sudo ./security-harden.sh` installs and configures:
- **UFW firewall**: denies incoming traffic by default, allows SSH (your chosen port), and opens ports 80/443; SSH is rate-limited to reduce brute-force attempts. See the Ubuntu UFW guide: https://help.ubuntu.com/community/UFW
- **Fail2Ban**: enables the SSH jail with a 1-hour ban after 5 failed attempts, tied to `/var/log/auth.log`. See the Fail2Ban documentation: https://www.fail2ban.org/wiki/index.php/Main_Page

The script immediately enforces these settings, which may affect remote access if ports are misconfigured. Confirm your SSH port and access method before running it.

## 🔒 Security Notes

- NEVER commit your `.env` file.
- Use SSH key authentication whenever possible.
- Keep Ubuntu updated:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
- For maximum safety, consider placing Cloudflare in front of your domain.
