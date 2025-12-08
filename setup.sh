#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run using: sudo ./setup.sh"
  exit 1
fi

echo "========================================="
echo "   Docker + Traefik + WordPress Setup    "
echo "========================================="

# Ask for runtime input
read -p "Enter your domain (example: tarekk.com): " DOMAIN
read -p "Enter subdomain for Portainer (e.g. panel): " PANEL_SUB
read -p "Enter subdomain for WordPress site #1 (e.g. blog1): " BLOG1_SUB
read -p "Enter your email for SSL (Let's Encrypt): " EMAIL

read -sp "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
echo
read -sp "Enter WordPress DB user password: " WP_DB_PASSWORD
echo

# Create .env file
cat > .env <<EOF
DOMAIN=$DOMAIN
PANEL_SUB=$PANEL_SUB
BLOG1_SUB=$BLOG1_SUB
EMAIL=$EMAIL
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
WP_DB_PASSWORD=$WP_DB_PASSWORD
EOF

echo ".env created (ignored by Git)."

echo "Updating system..."
apt update -y
apt upgrade -y

echo "Installing Docker..."
apt install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Creating Traefik directories..."
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json

echo "Creating Docker network..."
docker network create proxy || true

echo "========================================="
echo "Setup complete!"
echo "Next steps:"
echo "1. Configure DNS: $PANEL_SUB.$DOMAIN and $BLOG1_SUB.$DOMAIN"
echo "2. Run: docker compose up -d"
echo "========================================="
