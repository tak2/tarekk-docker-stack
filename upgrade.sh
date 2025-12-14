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

echo "Inspecting current stack configuration and running images..."
mapfile -t EXPECTED_IMAGES < <(docker compose config --images | sort -u)
if docker compose ps --format '{{.Image}}' >/tmp/docker-stack-images.$$ 2>/dev/null; then
  mapfile -t RUNNING_IMAGES < <(sort -u /tmp/docker-stack-images.$$)
  rm -f /tmp/docker-stack-images.$$
else
  RUNNING_IMAGES=()
fi

if [ ${#RUNNING_IMAGES[@]} -eq 0 ]; then
  echo "No running containers detected for this project."
else
  echo "Currently running images:"
  printf ' - %s\n' "${RUNNING_IMAGES[@]}"
fi

EXTRA_IMAGES=()
for image in "${RUNNING_IMAGES[@]}"; do
  if ! printf '%s\n' "${EXPECTED_IMAGES[@]}" | grep -Fxq "$image"; then
    EXTRA_IMAGES+=("$image")
  fi
done

if [ ${#EXTRA_IMAGES[@]} -gt 0 ]; then
  echo "The following running images are not part of the current docker-compose configuration:"
  printf ' - %s\n' "${EXTRA_IMAGES[@]}"
  read -p "Do you want to remove these images before upgrading? [y/N]: " DELETE_IMAGES
  DELETE_IMAGES=${DELETE_IMAGES:-n}
  if [[ "$DELETE_IMAGES" =~ ^[Yy]$ ]]; then
    echo "Removing non-matching images..."
    docker image rm "${EXTRA_IMAGES[@]}" || true
  else
    echo "Keeping all current images."
  fi
else
  echo "All running images match the current docker-compose configuration."
fi

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
