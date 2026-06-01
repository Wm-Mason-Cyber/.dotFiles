#!/usr/bin/env bash
# standard-apps.sh - dead-simple list + installer for classroom VMs
# This script is intentionally simple: it lists a recommended set of packages
# and offers to install them using the distro's package manager (apt, yum, pacman)

set -euo pipefail

RECOMMENDED=(
  git
  vim
  curl
  wget
  python3
  python3-pip
  python3-flask
  python3-fastapi
  bash-completion
  build-essential
  net-tools
)

list() {
  printf "Recommended packages:\n"
  for p in "${RECOMMENDED[@]}"; do
    printf " - %s\n" "$p"
  done
}

install_apt() {
  sudo apt update
  sudo apt install -y "${RECOMMENDED[@]}"
}

install_yum() {
  sudo yum install -y "${RECOMMENDED[@]}"
}

install_pacman() {
  sudo pacman -Sy --noconfirm "${RECOMMENDED[@]}"
}

case "${1:-list}" in
  list)
    list
    ;;
  install)
    if command -v apt >/dev/null 2>&1; then
      install_apt
    elif command -v yum >/dev/null 2>&1; then
      install_yum
    elif command -v pacman >/dev/null 2>&1; then
      install_pacman
    else
      echo "No supported package manager found. Run list to see recommended packages."
      exit 2
    fi
    ;;
  *)
    echo "Usage: $0 [list|install]"
    exit 1
    ;;
esac
