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
