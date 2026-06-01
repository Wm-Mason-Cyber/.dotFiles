#!/usr/bin/env bash
set -euo pipefail

# Run the prompt verification inside a temporary HOME to avoid sourcing
# or modifying the contributor's real dotfiles.
TMP_HOME=$(mktemp -d)
trap 'rm -rf "${TMP_HOME}"' EXIT
export HOME="${TMP_HOME}"
echo "Using fake HOME=${HOME} for prompt test"

# Optionally create an empty .bash_aliases so sourcing in .bashrc is predictable
touch "${HOME}/.bash_aliases"

# BASH_TESTING bypasses the interactive-shell guard in .bashrc so it can be
# sourced from this non-interactive test script.
export BASH_TESTING=1

# Verify that .bashrc defines prompt helpers and PS1 can be built
# shellcheck source=/dev/null
source ./.bashrc

# Ensure functions exist
declare -F build_ps1 >/dev/null
declare -F prompt_short >/dev/null
declare -F prompt_verbose >/dev/null
declare -F git_branch >/dev/null
declare -F git_dirty >/dev/null

echo "Found prompt helper functions"

# Build PS1 and ensure non-empty
build_ps1
if [ -z "${PS1:-}" ]; then
  echo "PS1 is empty" >&2
  exit 2
fi

echo "PS1 is non-empty"

# Test presets and switching
if declare -F dotfiles_prompt_preset >/dev/null 2>&1; then
  dotfiles_prompt_preset school >/dev/null 2>&1 || true
  prompt_short >/dev/null 2>&1 || true
  dotfiles_prompt_preset night >/dev/null 2>&1 || true
  prompt_verbose >/dev/null 2>&1 || true
  echo "Presets and toggles exercised"
fi

exit 0
