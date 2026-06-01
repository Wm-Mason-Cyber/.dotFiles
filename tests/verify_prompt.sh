#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

fail() { echo "FAIL: $*" >&2; exit 2; }

TMP_HOME=$(mktemp -d)
trap 'rm -rf "${TMP_HOME}"' EXIT
export HOME="${TMP_HOME}"
echo "Using fake HOME=${TMP_HOME} for prompt test"

# Provide an empty .bash_aliases so .bashrc sourcing is predictable
touch "${TMP_HOME}/.bash_aliases"

# BASH_TESTING bypasses the [[ $- != *i* ]] guard in .bashrc
export BASH_TESTING=1
# shellcheck source=/dev/null
source ./.bashrc

# ── Required functions exist ──────────────────────────────────────────────────
echo "Checking required functions..."
for fn in build_ps1 prompt_short prompt_verbose git_branch git_dirty \
           dotfiles_prompt_preset; do
    declare -F "$fn" >/dev/null || fail "function not defined: $fn"
done
echo "  OK: all prompt functions defined"

# ── PROMPT_COMMAND is wired up ────────────────────────────────────────────────
echo "Checking PROMPT_COMMAND..."
[ "${PROMPT_COMMAND:-}" = "build_ps1" ] \
    || fail "PROMPT_COMMAND is '${PROMPT_COMMAND:-}', expected 'build_ps1'"
echo "  OK: PROMPT_COMMAND=build_ps1"

# ── Default prompt style and non-empty PS1 ───────────────────────────────────
echo "Checking default prompt..."
[ "${DOTFILES_PROMPT_STYLE:-}" = "short" ] \
    || fail "DOTFILES_PROMPT_STYLE is '${DOTFILES_PROMPT_STYLE:-}', expected 'short'"
build_ps1
[ -n "${PS1:-}" ] || fail "PS1 is empty after build_ps1"
echo "  OK: short PS1 is non-empty"

# ── prompt_short vs prompt_verbose produce different PS1 ─────────────────────
echo "Checking prompt_short vs prompt_verbose..."
prompt_short
short_ps1="${PS1}"
prompt_verbose
verbose_ps1="${PS1}"
[ "$short_ps1" != "$verbose_ps1" ] \
    || fail "short and verbose PS1 are identical (verbose should contain @host)"
echo "  OK: short != verbose"

# ── Presets run without error and rebuild PS1 ────────────────────────────────
echo "Checking presets..."
for preset in school night high-contrast; do
    dotfiles_prompt_preset "$preset" 2>/dev/null   # tput may be limited in CI
    [ -n "${PS1:-}" ] || fail "PS1 empty after preset: $preset"
    echo "  OK: preset $preset"
done

# ── Invalid preset exits non-zero ────────────────────────────────────────────
echo "Checking invalid preset..."
dotfiles_prompt_preset bogus 2>/dev/null \
    && fail "invalid preset should return non-zero" \
    || true
echo "  OK: invalid preset rejected"

echo "verify_prompt.sh OK"
exit 0
