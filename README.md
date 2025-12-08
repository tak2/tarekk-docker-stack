# 🐳 Modern Docker Hosting Stack (Traefik + WordPress + APIs + Monitoring)

A production-ready, fully automated Docker hosting stack for VPS environments.

This setup includes:

- **Traefik v2** — Reverse Proxy + Automatic HTTPS (Let's Encrypt)  
- **Portainer** — Docker Management UI  
- **Multiple WordPress Sites**  
- **Node.js API Template**  
- **Python FastAPI Template**  
- **Netdata Monitoring Dashboard**  
- **Secure Firewall + Fail2Ban Protection**  
- **Zero Secrets in GitHub (runtime .env generation)**

Works on **Ubuntu 22.04 LTS** with **2 GB RAM or more**, ideal for multi-site hosting and API workloads.

---

## 🚀 Features

### 🔐 Security
- No passwords or secrets in repo  
- `.env` auto-generated at runtime  
- UFW firewall with only essential ports open  
- Fail2Ban protection against brute-force attacks  
- Optional Cloudflare compatibility  

### 🌍 Domain & SSL
- Automatic Let’s Encrypt certificates  
- Every subdomain routed through Traefik  
- All traffic forced through HTTPS  

### 📰 WordPress Multi-Site Support
- Host **3 WordPress sites by default**  
- Fully isolated networks & databases  
- Persistent volumes for DB & WP files  
- Easy to add more sites (blog4, shop, news, etc.)  

### 🧑‍💻 Developer-Friendly APIs
Includes templates to host your own APIs:

- `nodeapi.<domain>` → Node.js Express  
- `api.<domain>` → Python FastAPI  

Use them for:
- bots  
- EGX trading tools  
- webhooks  
- automations  
- dashboards  
- internal APIs  

### 📊 Monitoring
- Netdata dashboard at `monitor.<domain>`  
- Real-time CPU, memory, disk, network, Docker metrics  
- Lightweight, automatic, secure  

---

## 📦 Requirements

- VPS with Ubuntu **22.04 LTS**  
- Root or sudo access  
- Domain name (e.g. `tarekk.com`)  
- DNS access to create A records  

---

## 🛠 Installation

### 1. Clone this repo

```bash
git clone https://github.com/<your-user>/<your-repo>.git
cd <your-repo>
2. Run the setup script (Docker + Traefik + env builder)
bash
Copy code
sudo ./setup.sh
You will be asked for:

domain

subdomains

email for SSL

MySQL root password

WordPress DB passwords

This script:

✓ Installs Docker
✓ Installs Compose
✓ Creates proxy network
✓ Creates .env (ignored by Git)
✓ Prepares Traefik folders

3. (Optional) Security Hardening
bash
Copy code
sudo ./security-harden.sh
This enables:

UFW firewall

Fail2Ban

SSH rate-limiting

4. Start all services
bash
Copy code
docker compose up -d
🌍 Configure DNS
Create the following A records:

java
Copy code
panel.<domain>    → VPS IP (Portainer)
blog1.<domain>    → VPS IP (WordPress 1)
blog2.<domain>    → VPS IP (WordPress 2)
blog3.<domain>    → VPS IP (WordPress 3)
monitor.<domain>  → VPS IP (Netdata)
nodeapi.<domain>  → VPS IP (Node Express API)
api.<domain>      → VPS IP (Python FastAPI)
Example:

Copy code
panel.tarekk.com   → 193.42.60.234
blog1.tarekk.com   → 193.42.60.234
Traefik automatically requests SSL certificates once DNS is correct.

🏗 Stack Architecture
php-template
Copy code
Internet
   │
   ▼
┌─────────────┐     SSL + Reverse Proxy
│   Traefik   │  ← auto HTTPS via Let's Encrypt
└─────┬───────┘
      │
      ├── panel.<domain>   → Portainer (Docker UI)
      ├── blog1.<domain>   → WordPress Site 1
      ├── blog2.<domain>   → WordPress Site 2
      ├── blog3.<domain>   → WordPress Site 3
      ├── monitor.<domain> → Netdata Dashboard
      ├── nodeapi.<domain> → Node.js API
      └── api.<domain>     → Python FastAPI
📰 WordPress Sites
Your stack includes 3 WordPress sites:

blog1.<domain>

blog2.<domain>

blog3.<domain>

Each has:

Its own MariaDB container

Its own WP container

Its own isolated Docker network

Persistent volumes for DB & WP files

Adding More WordPress Sites
Duplicate the wp3 block in docker-compose.yml, rename to wp4, update env vars and labels.

I can generate that for you on request.

🧑‍💻 API Endpoints
Node API
Location: /api-node/

URL: https://nodeapi.<domain>/

Default returns:

json
Copy code
{
  "message": "Hello from Node API!",
  "time": "2025-01-01T00:00:00Z"
}
Python FastAPI
Location: /api-python/

URL: https://api.<domain>/

Default returns:

json
Copy code
{
  "message": "Hello from Python FastAPI!",
  "time": "2025-01-01T00:00:00Z"
}
📊 Monitoring
Netdata available at:

arduino
Copy code
https://monitor.<domain>
Shows:

CPU usage

Memory usage

Docker container stats

Disk I/O

Network traffic

Database performance

🧰 Useful Commands
View logs
bash
Copy code
docker logs -f traefik
docker logs -f wp1
Restart a service
bash
Copy code
docker compose restart wp1
Bring down everything
bash
Copy code
docker compose down
🔐 Security Notes
NEVER commit your .env file.

SSH should ideally use key authentication.

Keep Ubuntu updated:

bash
Copy code
sudo apt update && sudo apt upgrade -y
For maximum safety, use Cloudflare in front of your domain.