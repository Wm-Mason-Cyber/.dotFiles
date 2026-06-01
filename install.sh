#!/usr/bin/env bash
# install.sh - safer installer for dotfiles in this repo
# Supports copying or creating symlinks. Conservative by default.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(.bashrc .bash_aliases .vimrc .gitconfig)

SCRIPTS=(
    scripts/mason-cyber-colors
    scripts/mason-cyber-escape-root
    scripts/mason-cyber-hashme
    scripts/mason-cyber-netinfo
    scripts/mason-cyber-sysinfo
)

MODE=symlink   # symlink (default) or copy
FORCE=0
DRY_RUN=0
BACKUP=0
RESTORE=0

usage() {
    cat <<'EOF'
Usage: install.sh [OPTIONS]

Creates symlinks by default (recommended):
  ~/.bashrc → ~/dotfiles/.bashrc, etc.
Edits you make in ~ go directly into the repo with no copying needed.

Options:
  --copy, -c       Copy files instead of symlinking
  --force, -f      Overwrite existing files without prompting
  --dry-run        Show actions but do not perform them
  --backup         Back up existing files before replacing
  --restore, -r    Restore backups (*.bak*) created by this installer
  -h, --help       Show this help

Examples:
  ./install.sh               # symlink (recommended)
  ./install.sh --copy        # copy files instead of symlinking
  ./install.sh --force       # overwrite without confirmation
  ./install.sh --dry-run     # show what would happen
  ./install.sh --restore     # interactively restore any backups
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --copy|-c)     MODE=copy; shift ;;
        --symlink|-s)  MODE=symlink; shift ;;   # kept for compatibility
        --force|-f)    FORCE=1; shift ;;
        --backup)      BACKUP=1; shift ;;
        --dry-run)     DRY_RUN=1; shift ;;
        --restore|-r)  RESTORE=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        *)             echo "Unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done

confirm() {
    if [ "$FORCE" -eq 1 ]; then return 0; fi
    read -r -p "$1 [y/N]: " resp
    case "$resp" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

perform_action() {
    local src="$1" dst="$2"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "DRY-RUN: would ${MODE} $src -> $dst"
        return
    fi
    if [ "$MODE" = "symlink" ]; then
        ln -sfn "$src" "$dst"
        echo "Linked $dst -> $src"
    else
        cp -a "$src" "$dst"
        echo "Installed $dst"
    fi
}

perform_restore() {
    local bak="$1" dst="$2"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "DRY-RUN: would restore $bak -> $dst"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if confirm "Overwrite $dst with backup $bak?"; then
            rm -rf "$dst"
            mv "$bak" "$dst"
            echo "Restored $dst from $bak"
        else
            echo "Left $dst unchanged"
        fi
    else
        mv "$bak" "$dst"
        echo "Restored $dst from $bak"
    fi
}

restore_backups() {
    shopt -s nullglob
    echo "Searching for backups for managed files..."
    local found=0
    for f in "${FILES[@]}"; do
        for bak in "$HOME/${f}.bak" "$HOME/${f}.bak."*; do
            [ -e "$bak" ] || [ -L "$bak" ] || continue
            found=1
            local dst="$HOME/$f"
            echo "Found backup: $bak"
            if confirm "Restore $bak -> $dst?"; then
                perform_restore "$bak" "$dst"
            else
                echo "Skipping $bak"
            fi
        done
    done
    [ "$found" -eq 0 ] && echo "No backups found."
    shopt -u nullglob
}

# Install mason-cyber-* scripts to ~/.local/bin/ and make them executable.
install_scripts() {
    local bin_dir="$HOME/.local/bin"
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "DRY-RUN: would mkdir -p $bin_dir"
    else
        mkdir -p "$bin_dir"
    fi

    for s in "${SCRIPTS[@]}"; do
        local src="$REPO_DIR/$s"
        local name; name=$(basename "$s")
        local dst="$bin_dir/$name"

        if [ ! -e "$src" ]; then
            echo "Skipping $name (missing in repo)"
            continue
        fi

        if [ -e "$dst" ] && ! confirm "Overwrite existing $dst?"; then
            echo "Left $dst unchanged"
            continue
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            echo "DRY-RUN: would install $name -> $dst"
        elif [ "$MODE" = "symlink" ]; then
            ln -sfn "$src" "$dst"
            chmod +x "$dst"
            echo "Linked $dst"
        else
            cp -a "$src" "$dst"
            chmod +x "$dst"
            echo "Installed $dst"
        fi
    done
}

# Prompt for git name/email if .gitconfig still has placeholder values.
setup_git_identity() {
    local cfg="$HOME/.gitconfig"
    [ -f "$cfg" ] || return 0
    grep -q "CHANGE_ME" "$cfg" 2>/dev/null || return 0
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "DRY-RUN: would prompt for git identity"
        return
    fi
    echo ""
    echo "=== Git Identity Setup ==="
    echo "Your .gitconfig still has placeholder values."
    read -r -p "Full name (e.g. Jane Smith): " git_name
    read -r -p "School email: " git_email
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        git config --file "$cfg" user.name  "$git_name"
        git config --file "$cfg" user.email "$git_email"
        echo "Git identity saved to ~/.gitconfig"
    else
        echo "Skipped. Edit ~/.gitconfig manually before your first commit."
    fi
}

if [ "$RESTORE" -eq 1 ]; then
    restore_backups
    exit 0
fi

for f in "${FILES[@]}"; do
    src="$REPO_DIR/$f"
    dst="$HOME/$f"
    if [ ! -e "$src" ]; then
        echo "Skipping $f (missing in repo)"
        continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        echo "$dst already exists."
        if confirm "Overwrite $dst?"; then
            if [ "$DRY_RUN" -eq 1 ]; then
                echo "DRY-RUN: would remove or backup existing $dst"
            else
                if [ "$BACKUP" -eq 1 ]; then
                    bak="$dst.bak"
                    i=0
                    while [ -e "$bak" ] || [ -L "$bak" ]; do
                        i=$((i+1))
                        bak="$dst.bak.$i"
                    done
                    mv "$dst" "$bak"
                    echo "Backed up $dst -> $bak"
                else
                    rm -rf "$dst"
                fi
            fi
            perform_action "$src" "$dst"
        else
            echo "Left $dst unchanged"
        fi
    else
        perform_action "$src" "$dst"
    fi
done

# Ensure vim swap/backup/undo directories exist (required by .vimrc settings)
for d in "$HOME/.vim/tmp" "$HOME/.vim/backup"; do
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "DRY-RUN: would mkdir -p $d"
    else
        mkdir -p "$d"
    fi
done

install_scripts
setup_git_identity

echo ""
echo "Done. To apply shell changes: source ~/.bashrc"
