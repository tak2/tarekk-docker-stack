#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run using: sudo ./security-harden.sh"
  exit 1
fi

echo "========================================="
echo "   Security Hardening: UFW + Fail2Ban    "
echo "========================================="

# Ask if using custom SSH port
read -p "Enter your SSH port [22]: " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

echo "Installing UFW and Fail2Ban..."
apt update -y
apt install -y ufw fail2ban

echo "Configuring UFW firewall..."
ufw default deny incoming
ufw default allow outgoing

ufw allow ${SSH_PORT}/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Optional: rate-limit SSH
ufw limit ${SSH_PORT}/tcp

echo "Enabling UFW..."
ufw --force enable

echo "Configuring Fail2Ban..."
cat >/etc/fail2ban/jail.local <<EOF
[sshd]
enabled  = true
port     = ${SSH_PORT}
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
bantime  = 3600

# You can add more jails later for nginx/traefik/wp-login etc.
EOF

systemctl enable fail2ban
systemctl restart fail2ban

echo "========================================="
echo "Security hardening done."
echo "UFW is active and Fail2Ban is running."
echo "========================================="
