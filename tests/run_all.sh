#!/usr/bin/env bash
set -euo pipefail

# Portable test runner: prefer make test when available, otherwise run scripts directly
if command -v make >/dev/null 2>&1; then
  make test
else
  echo "make not found; running tests directly"
  ./tests/verify_prompt.sh
  ./tests/verify_standard_apps.sh
  ./tests/verify_install.sh
  ./tests/verify_scripts.sh
fi

echo "All tests completed"
