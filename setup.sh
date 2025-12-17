#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run using: sudo ./setup.sh"
  exit 1
fi

echo "========================================="
echo "   Docker + Traefik + WP + APIs Setup    "
echo "========================================="

# --- Ask for basic domain info ---
read -p "Enter your domain (example: example.com): " DOMAIN

read -p "Enter subdomain for Portainer [panel]: " PANEL_SUB
PANEL_SUB=${PANEL_SUB:-panel}

read -p "Enter subdomain for WordPress site [test]: " WP_SUB
WP_SUB=${WP_SUB:-test}

read -p "Enter subdomain for Moodle [moodle]: " MOODLE_SUB
MOODLE_SUB=${MOODLE_SUB:-moodle}

read -p "Enter subdomain for Netdata monitor [monitor]: " MONITOR_SUB
MONITOR_SUB=${MONITOR_SUB:-monitor}

read -p "Enter subdomain for Node API [nodeapi]: " NODE_SUB
NODE_SUB=${NODE_SUB:-nodeapi}

read -p "Enter subdomain for Python API [api]: " PY_SUB
PY_SUB=${PY_SUB:-api}

read -p "Enter your email for SSL (Let's Encrypt): " EMAIL

# --- Secrets (NOT committed, go only in .env) ---
generate_password() {
  openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 24
}

DEFAULT_MYSQL_ROOT_PASSWORD=$(generate_password)
read -p "Enter MySQL root password [generated if empty]: " MYSQL_ROOT_PASSWORD
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-$DEFAULT_MYSQL_ROOT_PASSWORD}

DEFAULT_WP_DB_PASSWORD=$(generate_password)
read -p "Enter WordPress DB user password [generated if empty]: " WP_DB_PASSWORD
WP_DB_PASSWORD=${WP_DB_PASSWORD:-$DEFAULT_WP_DB_PASSWORD}

DEFAULT_MOODLE_DB_ROOT_PASSWORD=$(generate_password)
read -p "Enter Moodle DB root password [generated if empty]: " MOODLE_DB_ROOT_PASSWORD
MOODLE_DB_ROOT_PASSWORD=${MOODLE_DB_ROOT_PASSWORD:-$DEFAULT_MOODLE_DB_ROOT_PASSWORD}

DEFAULT_MOODLE_DB_PASSWORD=$(generate_password)
read -p "Enter Moodle DB user password [generated if empty]: " MOODLE_DB_PASSWORD
MOODLE_DB_PASSWORD=${MOODLE_DB_PASSWORD:-$DEFAULT_MOODLE_DB_PASSWORD}

read -p "Enter Moodle DB name [moodle_db]: " MOODLE_DB_NAME
MOODLE_DB_NAME=${MOODLE_DB_NAME:-moodle_db}
read -p "Enter Moodle DB username [moodle_user]: " MOODLE_DB_USER
MOODLE_DB_USER=${MOODLE_DB_USER:-moodle_user}
read -p "Enter Moodle admin username [admin]: " MOODLE_ADMIN_USER
MOODLE_ADMIN_USER=${MOODLE_ADMIN_USER:-admin}
DEFAULT_MOODLE_ADMIN_PASSWORD=$(generate_password)
read -p "Enter Moodle admin password [generated if empty]: " MOODLE_ADMIN_PASSWORD
MOODLE_ADMIN_PASSWORD=${MOODLE_ADMIN_PASSWORD:-$DEFAULT_MOODLE_ADMIN_PASSWORD}
read -p "Enter Moodle admin email [admin@$DOMAIN]: " MOODLE_ADMIN_EMAIL
MOODLE_ADMIN_EMAIL=${MOODLE_ADMIN_EMAIL:-admin@$DOMAIN}
read -p "Enter Moodle site name [My Moodle]: " MOODLE_SITE_NAME
MOODLE_SITE_NAME=${MOODLE_SITE_NAME:-My Moodle}

# Create .env file (ignored by Git)
cat > .env <<EOF
DOMAIN=$DOMAIN
PANEL_SUB=$PANEL_SUB
WP_SUB=$WP_SUB
MOODLE_SUB=$MOODLE_SUB
MONITOR_SUB=$MONITOR_SUB
NODE_SUB=$NODE_SUB
PY_SUB=$PY_SUB
EMAIL=$EMAIL
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
WP_DB_PASSWORD=$WP_DB_PASSWORD
MOODLE_DB_ROOT_PASSWORD=$MOODLE_DB_ROOT_PASSWORD
MOODLE_DB_NAME=$MOODLE_DB_NAME
MOODLE_DB_USER=$MOODLE_DB_USER
MOODLE_DB_PASSWORD=$MOODLE_DB_PASSWORD
MOODLE_ADMIN_USER=$MOODLE_ADMIN_USER
MOODLE_ADMIN_PASSWORD=$MOODLE_ADMIN_PASSWORD
MOODLE_ADMIN_EMAIL=$MOODLE_ADMIN_EMAIL
MOODLE_SITE_NAME=$MOODLE_SITE_NAME
EOF

echo ".env created with your configuration (this file is ignored by Git)."

echo "Updating system..."
apt update -y
apt upgrade -y

echo "Installing base packages..."
apt install -y ca-certificates curl gnupg lsb-release

echo "Setting up Docker repository..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker Engine + Compose plugin..."
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

if ! command -v docker-compose >/dev/null 2>&1; then
  if [ -x /usr/libexec/docker/cli-plugins/docker-compose ]; then
    ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
  elif [ -x /usr/lib/docker/cli-plugins/docker-compose ]; then
    ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
  fi
fi

echo "Enabling Docker..."
systemctl enable docker
systemctl restart docker

echo "Creating Traefik directories..."
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json

echo "Creating Docker 'proxy' network (if not exists)..."
docker network create proxy || true

echo "========================================="
echo "Base setup complete!"
echo "Next steps:"
echo "1) Configure DNS for:"
echo "   - $PANEL_SUB.$DOMAIN"
echo "   - $WP_SUB.$DOMAIN"
echo "   - $MOODLE_SUB.$DOMAIN"
echo "   - $MONITOR_SUB.$DOMAIN"
echo "   - $NODE_SUB.$DOMAIN"
echo "   - $PY_SUB.$DOMAIN"
echo "2) Run: docker compose up -d"
echo "========================================="

echo "Generated credentials (store them securely):"
echo "- MySQL root password: $MYSQL_ROOT_PASSWORD"
echo "- WordPress DB user password: $WP_DB_PASSWORD"
echo "- Moodle DB root password: $MOODLE_DB_ROOT_PASSWORD"
echo "- Moodle DB user password: $MOODLE_DB_PASSWORD"
echo "- Moodle admin password: $MOODLE_ADMIN_PASSWORD"
