#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run using: sudo ./upgrade.sh"
  exit 1
fi

if [ ! -f .env ]; then
  echo "Missing .env file. Run ./setup.sh first to generate environment settings."
  exit 1
fi

echo "========================================="
echo "        Upgrade Docker Stack           "
echo "========================================="
echo "This script pulls newer images, rebuilds local services, and recreates containers."

docker --version >/dev/null

docker network create proxy >/dev/null 2>&1 || true

read -p "Delete current containers before upgrading? [y/N]: " DELETE_CONTAINERS
DELETE_CONTAINERS=${DELETE_CONTAINERS:-n}

if [[ "$DELETE_CONTAINERS" =~ ^[Yy]$ ]]; then
  echo "Stopping and removing existing containers..."
  docker compose down
else
  echo "Keeping existing containers running until the new ones are ready."
fi

echo "Pulling updated images..."
docker compose pull

echo "Rebuilding local images (Node API, Python API)..."
docker compose build --pull

echo "Starting stack with latest images..."
docker compose up -d

echo "Upgrade complete. Current service status:"
docker compose ps
