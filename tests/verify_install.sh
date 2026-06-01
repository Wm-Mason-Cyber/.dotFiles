#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

fail() { echo "FAIL: $*" >&2; exit 2; }

# ── Syntax check ─────────────────────────────────────────────────────────────
bash -n ./install.sh
echo "syntax OK"

# ── Actual install into a temp HOME ──────────────────────────────────────────
# --force skips overwrite prompts; stdin from /dev/null feeds the git-identity
# read so it exits cleanly without hanging.
TMP_HOME=$(mktemp -d)
trap 'rm -rf "${TMP_HOME}"' EXIT
export HOME="${TMP_HOME}"
echo "Using fake HOME=${TMP_HOME}"

# Pre-create .gitconfig so the "already exists" code path is exercised
touch "${TMP_HOME}/.gitconfig"

# Pipe two empty lines so any read prompts (e.g. git identity) return
# immediately with empty input, making stdin non-terminal so the tty
# check in setup_git_identity also skips cleanly.
printf '\n\n' | bash ./install.sh --force

# Verify dotfiles are symlinks pointing to real files
echo "Checking dotfile symlinks..."
for f in .bashrc .bash_aliases .vimrc .gitconfig; do
    dst="${TMP_HOME}/${f}"
    [ -L "$dst" ]            || fail "${f} is not a symlink"
    src="$(readlink "$dst")"
    [ -f "$src" ]            || fail "symlink target missing: $src"
    echo "  OK: ${f} -> ${src}"
done

# Verify scripts are installed and executable
echo "Checking scripts in ~/.local/bin/..."
for s in mason-cyber-colors mason-cyber-escape-root mason-cyber-hashme \
          mason-cyber-netinfo mason-cyber-sysinfo; do
    dst="${TMP_HOME}/.local/bin/${s}"
    [ -f "$dst" ] || fail "missing script: $s"
    [ -x "$dst" ] || fail "not executable: $s"
    echo "  OK: ${s}"
done

# Verify vim directories were created
echo "Checking vim directories..."
[ -d "${TMP_HOME}/.vim/tmp" ]    || fail "~/.vim/tmp not created"
[ -d "${TMP_HOME}/.vim/backup" ] || fail "~/.vim/backup not created"
echo "  OK: ~/.vim/tmp and ~/.vim/backup"

# ── Dry-run mode (separate pass, reuses same temp HOME) ──────────────────────
echo "Checking dry-run mode..."
# Capture output first; piping long-running commands into grep -q triggers
# SIGPIPE when grep exits early, which pipefail misreads as a failure.
dry_out=$(bash ./install.sh --dry-run --backup --force 2>&1 || true)
printf '%s\n' "$dry_out" | grep -q "DRY-RUN" \
    || fail "dry-run produced no DRY-RUN lines"
echo "  OK: dry-run output looks correct"

echo "install.sh OK"
exit 0
