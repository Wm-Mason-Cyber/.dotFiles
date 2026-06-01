#!/usr/bin/env bash
set -euo pipefail

# Verify syntax of every script in scripts/
echo "Checking scripts/ syntax..."
shopt -s nullglob
count=0
for s in scripts/mason-cyber-*; do
    bash -n "$s"
    echo "  OK: $s"
    count=$((count + 1))
done
shopt -u nullglob

if [ "$count" -eq 0 ]; then
    echo "No scripts found in scripts/" >&2
    exit 2
fi

# Verify install.sh registers all scripts/ files in its SCRIPTS array
echo "Checking SCRIPTS array in install.sh covers all scripts/..."
missing=0
for s in scripts/mason-cyber-*; do
    name=$(basename "$s")
    if ! grep -q "$name" install.sh; then
        echo "  MISSING from install.sh SCRIPTS array: $name" >&2
        missing=1
    fi
done
if [ "$missing" -ne 0 ]; then
    exit 2
fi

echo "$count scripts OK"
exit 0
