#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="$ROOT/termuxguardian.sh"

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$1"; }

[[ -x "$TOOL" ]] || fail "toolkit is executable"
help_out="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" help)"
grep -q "Termux Guardian" <<<"$help_out" || fail "help includes product name"
grep -q "never extracts" <<<"$help_out" || fail "help includes credential boundary"
pass "help output"

check_out="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" check)"
grep -q "Environment check" <<<"$check_out" || fail "check subcommand"
pass "environment check"

network_out="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" network)"
grep -q "Network diagnostics" <<<"$network_out" || fail "network subcommand"
grep -q "never read or displayed" <<<"$network_out" || fail "network safety message"
pass "network diagnostics"

storage_out="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" storage)"
grep -q "Storage and package health" <<<"$storage_out" || fail "storage subcommand"
pass "storage health"

recovery_out="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" recovery)"
grep -q "Authorized recovery guidance" <<<"$recovery_out" || fail "recovery subcommand"
pass "recovery guidance"

quick_out="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" scan quick)"
grep -q "Quick malware-risk scan" <<<"$quick_out" || fail "quick scan subcommand"
grep -q "RESULT: SAFE" <<<"$quick_out" || fail "quick scan result"
pass "quick malware scan"

link_safe="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" link https://example.com)"
grep -q "SAFE LINK" <<<"$link_safe" || fail "safe link classification"
link_bad="$(TERMUX_GUARDIAN_TEST_MODE=1 bash "$TOOL" link https://bit.ly/login-verify)"
grep -q "DANGER / PHISHING RISK" <<<"$link_bad" || fail "danger link classification"
pass "link safety analysis"

if grep -Eiq 'cat .*wpa|grep .*psk|password[[:space:]]*=' "$TOOL"; then
  fail "toolkit contains a credential extraction pattern"
fi
pass "credential extraction guard"

printf 'All Termux Guardian smoke tests passed.\n'
