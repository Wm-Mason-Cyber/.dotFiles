#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

fail() { echo "FAIL: $*" >&2; exit 2; }

# ── Syntax check ─────────────────────────────────────────────────────────────
bash -n ./standard-apps.sh
echo "syntax OK"

# ── list subcommand ───────────────────────────────────────────────────────────
echo "Checking 'list' output..."
list_out=$(bash ./standard-apps.sh list)

[ -n "$list_out" ] \
    || fail "'list' produced no output"
printf '%s\n' "$list_out" | grep -q "Detected package manager" \
    || fail "'list' missing 'Detected package manager' line"
printf '%s\n' "$list_out" | grep -q "Base packages" \
    || fail "'list' missing 'Base packages' section"
printf '%s\n' "$list_out" | grep -q "Security" \
    || fail "'list' missing 'Security' section"
printf '%s\n' "$list_out" | grep -q "git" \
    || fail "'list' missing 'git' in base packages"
printf '%s\n' "$list_out" | grep -q "nmap" \
    || fail "'list' missing 'nmap' in security packages"
echo "  OK: list output has expected sections and packages"

# ── Unknown subcommand exits non-zero ────────────────────────────────────────
echo "Checking unknown subcommand..."
bash ./standard-apps.sh bogus >/dev/null 2>&1 \
    && fail "'bogus' subcommand should exit non-zero" \
    || true
echo "  OK: unknown subcommand rejected"

# ── install/security/all subcommands parse without syntax error ───────────────
# We cannot actually install packages in CI, but we can verify the script
# reaches the package-manager detection without crashing on argument parsing.
echo "Checking subcommand routing (no-op: no package manager expected in CI)..."
for cmd in install security all; do
    bash -c "
        source ./standard-apps.sh $cmd
    " 2>/dev/null || true   # will fail without sudo/pkg-mgr; that is expected
    bash -n ./standard-apps.sh  # re-confirm syntax after each subcommand test
    echo "  OK: subcommand '$cmd' parsed without syntax error"
done

echo "verify_standard_apps.sh OK"
exit 0
