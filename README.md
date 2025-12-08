# 🐳 Tarekk Docker Stack  
A secure, production-ready Docker environment for hosting:

- Traefik (reverse proxy + automatic SSL)
- Portainer (Docker management UI)
- Multiple WordPress sites
- Custom apps (PHP/Node/Python)
- Fully isolated networks per site

Designed for VPS environments (e.g. 2–4GB RAM).  
Tested on **Ubuntu Server 22.04 LTS**.

---

## 🚀 Features

### ✔ Zero secrets in GitHub  
All credentials are requested at runtime and stored in a local `.env` file (ignored by Git).

### ✔ Automatic SSL (Let’s Encrypt)  
Traefik handles certificates for all sites and subdomains.

### ✔ Multi-WordPress support  
Each WordPress site has its own database + isolated network + URL.

### ✔ Simple one-command deployment  
sudo ./setup.sh
docker compose up -d

yaml
Copy code

### ✔ Clean architecture  
Reverse proxy → isolated apps → secure networks.

---

## 📦 Requirements

- Ubuntu 22.04 LTS  
- Root or sudo access  
- DNS access for your domain (A records)

---

## 🧩 Installation

### 1. Clone the repo
git clone https://github.com/<your-user>/tarekk-docker-stack.git
cd tarekk-docker-stack

bash
Copy code

### 2. Run setup script
This installs Docker, creates networks, and generates `.env`.

sudo ./setup.sh

shell
Copy code

### 3. Start the stack

docker compose up -d

yaml
Copy code

---

## 🌍 DNS Configuration

Add DNS A records:

panel.<domain> → VPS IP
blog1.<domain> → VPS IP
blog2.<domain> → VPS IP (optional)
api.<domain> → VPS IP (optional)

makefile
Copy code

Example:  
panel.tarekk.com → 193.42.60.234
blog1.tarekk.com → 193.42.60.234

yaml
Copy code

---

## 🔐 TLS / HTTPS

Traefik will request SSL certificates automatically on first access.

Visit:

- Portainer → https://panel.<domain>  
- WordPress → https://blog1.<domain>

---

## ✏️ Adding More WordPress Sites

Duplicate the WordPress block in `docker-compose.yml`:

wp2_db
wp2
wp2_net
wp2_db_data
wp2_wp_data

diff
Copy code

Change:

- router Host rule  
- DB credentials  
- volumes  
- subdomain  

Then run:

docker compose up -d

yaml
Copy code

---

## 🛠 Useful Commands

View logs for Traefik:
docker logs -f traefik

cpp
Copy code

Restart stack:
docker compose restart

vbnet
Copy code

Stop everything:
docker compose down

yaml
Copy code

---

## 📁 Folder Structure After Setup

.
├── .env # Generated automatically, ignored by Git
├── docker-compose.yml
├── setup.sh
├── traefik/
│ └── letsencrypt/
│ └── acme.json # Certificates stored here

yaml
Copy code

---

## 🛡 Security Notes

- Never commit `.env` or database passwords.
- SSH should use key authentication.
- Keep your VPS updated:
sudo apt update && sudo apt upgrade -y

yaml
Copy code

---

## 🧑‍💻 Author

Created for Tarek's VPS environment.  
Supports WordPress hosting, API apps, bots, and modern infrastructure.

---
