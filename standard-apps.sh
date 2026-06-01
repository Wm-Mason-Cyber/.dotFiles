#!/usr/bin/env bash
# standard-apps.sh - classroom package installer
# Supports Debian/Ubuntu (apt), Fedora (dnf/yum), and Arch Linux (pacman).
# Package names differ per distro — each has its own list below.
#
# Usage: ./standard-apps.sh [list|install|security|all]

set -euo pipefail

# --- Base packages ---

APT_BASE=(
    git vim curl wget
    python3 python3-pip python3-flask python3-fastapi
    bash-completion build-essential net-tools
)

DNF_BASE=(
    git vim curl wget
    python3 python3-pip python3-flask python3-fastapi
    bash-completion "@development-tools" net-tools
)

PACMAN_BASE=(
    git vim curl wget
    python python-pip python-flask python-fastapi
    bash-completion base-devel net-tools
)

# --- Security / lab tools (AP Cybersecurity) ---
# Install with: ./standard-apps.sh security

APT_SECURITY=(
    nmap tcpdump netcat-openbsd wireshark john hydra binutils gdb
)

DNF_SECURITY=(
    nmap tcpdump nmap-ncat wireshark john hydra binutils gdb
)

PACMAN_SECURITY=(
    nmap tcpdump openbsd-netcat wireshark-qt john thc-hydra binutils gdb
)

# --- Package manager detection ---
# Check dnf before yum: modern Fedora uses dnf; yum is a compatibility shim.

detect_pm() {
    if   command -v apt    >/dev/null 2>&1; then echo apt
    elif command -v dnf    >/dev/null 2>&1; then echo dnf
    elif command -v yum    >/dev/null 2>&1; then echo yum
    elif command -v pacman >/dev/null 2>&1; then echo pacman
    else echo none
    fi
}

# --- Commands ---

list() {
    local pm; pm=$(detect_pm)
    printf "Detected package manager: %s\n" "$pm"
    printf "\nBase packages (./standard-apps.sh install):\n"
    case "$pm" in
        apt)     for p in "${APT_BASE[@]}";     do printf "  %s\n" "$p"; done ;;
        dnf|yum) for p in "${DNF_BASE[@]}";     do printf "  %s\n" "$p"; done ;;
        pacman)  for p in "${PACMAN_BASE[@]}";  do printf "  %s\n" "$p"; done ;;
        *)       printf "  (unknown distro — cannot list)\n" ;;
    esac
    printf "\nSecurity/lab tools (./standard-apps.sh security):\n"
    case "$pm" in
        apt)     for p in "${APT_SECURITY[@]}";    do printf "  %s\n" "$p"; done ;;
        dnf|yum) for p in "${DNF_SECURITY[@]}";    do printf "  %s\n" "$p"; done ;;
        pacman)  for p in "${PACMAN_SECURITY[@]}"; do printf "  %s\n" "$p"; done ;;
        *)       printf "  (unknown distro)\n" ;;
    esac
}

install_base() {
    local pm; pm=$(detect_pm)
    case "$pm" in
        apt)
            sudo apt update
            sudo apt install -y "${APT_BASE[@]}"
            ;;
        dnf)
            sudo dnf install -y "${DNF_BASE[@]}"
            ;;
        yum)
            sudo yum install -y "${DNF_BASE[@]}"
            ;;
        pacman)
            sudo pacman -Syu --noconfirm "${PACMAN_BASE[@]}"
            ;;
        *)
            printf "No supported package manager found. Run '%s list' for package names.\n" "$0" >&2
            exit 2
            ;;
    esac
}

install_security() {
    local pm; pm=$(detect_pm)
    case "$pm" in
        apt)
            sudo apt update
            sudo apt install -y "${APT_SECURITY[@]}"
            ;;
        dnf)
            sudo dnf install -y "${DNF_SECURITY[@]}"
            ;;
        yum)
            sudo yum install -y "${DNF_SECURITY[@]}"
            ;;
        pacman)
            sudo pacman -Syu --noconfirm "${PACMAN_SECURITY[@]}"
            ;;
        *)
            printf "No supported package manager found.\n" >&2
            exit 2
            ;;
    esac
}

case "${1:-list}" in
    list)
        list
        ;;
    install)
        install_base
        ;;
    security)
        install_security
        ;;
    all)
        install_base
        install_security
        ;;
    *)
        printf "Usage: %s [list|install|security|all]\n" "$0" >&2
        exit 1
        ;;
esac
