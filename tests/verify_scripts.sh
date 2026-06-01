#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

fail() { echo "FAIL: $*" >&2; exit 2; }

# ── Syntax check all scripts ──────────────────────────────────────────────────
echo "Checking scripts/ syntax..."
shopt -s nullglob
count=0
for s in scripts/mason-cyber-*; do
    bash -n "$s"
    echo "  OK: $s"
    count=$((count + 1))
done
shopt -u nullglob
[ "$count" -gt 0 ] || fail "no scripts found in scripts/"

# ── Every script is registered in install.sh SCRIPTS array ───────────────────
echo "Checking SCRIPTS array coverage..."
for s in scripts/mason-cyber-*; do
    name=$(basename "$s")
    grep -q "$name" install.sh || fail "$name missing from SCRIPTS array in install.sh"
done
echo "  OK: all scripts registered"

# ── mason-cyber-hashme: string mode ──────────────────────────────────────────
echo "Checking mason-cyber-hashme -s ..."
hash_out=$(bash scripts/mason-cyber-hashme -s "mason-test-string")
printf '%s\n' "$hash_out" | grep -q "MD5"    || fail "hashme -s: missing MD5 line"
printf '%s\n' "$hash_out" | grep -q "SHA-1"  || fail "hashme -s: missing SHA-1 line"
printf '%s\n' "$hash_out" | grep -q "SHA-256" || fail "hashme -s: missing SHA-256 line"
printf '%s\n' "$hash_out" | grep -q "SHA-512" || fail "hashme -s: missing SHA-512 line"
echo "  OK: hashme -s produces all four hash types"

# ── mason-cyber-hashme: file mode ────────────────────────────────────────────
echo "Checking mason-cyber-hashme <file> ..."
hash_out=$(bash scripts/mason-cyber-hashme install.sh)
printf '%s\n' "$hash_out" | grep -q "SHA-256" || fail "hashme file: missing SHA-256"
echo "  OK: hashme file mode works"

# ── mason-cyber-hashme: error cases ──────────────────────────────────────────
echo "Checking mason-cyber-hashme error handling..."
if bash scripts/mason-cyber-hashme /nonexistent/file 2>/dev/null; then
    fail "hashme: should exit non-zero for missing file"
fi
if bash scripts/mason-cyber-hashme 2>/dev/null; then
    fail "hashme: should exit non-zero with no args"
fi
echo "  OK: hashme error handling correct"

# ── mason-cyber-sysinfo ───────────────────────────────────────────────────────
echo "Checking mason-cyber-sysinfo..."
sysinfo_out=$(bash scripts/mason-cyber-sysinfo)
[ -n "$sysinfo_out" ]                             || fail "sysinfo: no output"
printf '%s\n' "$sysinfo_out" | grep -q "User:"   || fail "sysinfo: missing User field"
printf '%s\n' "$sysinfo_out" | grep -q "Kernel:" || fail "sysinfo: missing Kernel field"
printf '%s\n' "$sysinfo_out" | grep -q "Disk:"   || fail "sysinfo: missing Disk field"
echo "  OK: sysinfo output has expected fields"

# ── mason-cyber-netinfo ───────────────────────────────────────────────────────
echo "Checking mason-cyber-netinfo..."
netinfo_out=$(bash scripts/mason-cyber-netinfo)
[ -n "$netinfo_out" ]                                         || fail "netinfo: no output"
printf '%s\n' "$netinfo_out" | grep -q "Network Information" || fail "netinfo: missing header"
printf '%s\n' "$netinfo_out" | grep -q "DNS"                 || fail "netinfo: missing DNS section"
echo "  OK: netinfo output has expected sections"

# ── mason-cyber-escape-root: non-root case ────────────────────────────────────
echo "Checking mason-cyber-escape-root (non-root)..."
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    escape_out=$(bash scripts/mason-cyber-escape-root)
    printf '%s\n' "$escape_out" | grep -qi "not root\|already running" \
        || fail "escape-root: unexpected output when not root"
    echo "  OK: escape-root exits cleanly when not root"
else
    echo "  SKIP: running as root, cannot test non-root path"
fi

# ── mason-cyber-colors: must be sourced, not executed ────────────────────────
echo "Checking mason-cyber-colors exec guard..."
if bash scripts/mason-cyber-colors 2>/dev/null; then
    fail "mason-cyber-colors should exit non-zero when executed (not sourced)"
fi
echo "  OK: colors exec guard works"

echo "verify_scripts.sh OK"
exit 0
