#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

VERSION="0.1.0"
APP_NAME="Termux Guardian"

cyan='\033[38;5;51m'; green='\033[38;5;82m'; amber='\033[38;5;214m'; red='\033[38;5;203m'; dim='\033[2m'; reset='\033[0m'

has_cmd() { command -v "$1" >/dev/null 2>&1; }
line() { printf '%b\n' "${dim}────────────────────────────────────────────────────────────${reset}"; }
header() {
  clear 2>/dev/null || true
  printf '%b\n' "${cyan}╭────────────────────────────────────────────────────────────╮${reset}"
  printf '%b\n' "${cyan}│${reset}  ${green}▸_${reset} ${APP_NAME} ${dim}v${VERSION}${reset}                         ${cyan}│${reset}"
  printf '%b\n' "${cyan}│${reset}  ${dim}See the signal before you touch the system.${reset}          ${cyan}│${reset}"
  printf '%b\n' "${cyan}╰────────────────────────────────────────────────────────────╯${reset}"
}

usage() {
  cat <<'EOF'
Termux Guardian — defensive mobile-security toolkit

Usage:
  ./termuxguardian.sh                 Open the interactive menu
  ./termuxguardian.sh check           Run a safe environment check
  ./termuxguardian.sh network         Run non-destructive network diagnostics
  ./termuxguardian.sh storage         Inspect storage and package health
  ./termuxguardian.sh updates         Show non-destructive update guidance
  ./termuxguardian.sh recovery        Show authorized account/network recovery guidance
  ./termuxguardian.sh help            Show this help

Safety boundary:
  This tool never extracts, reveals, stores, or displays Wi-Fi passwords,
  tokens, keys, or other credentials. It only reads safe system metadata.
EOF
}

check_environment() {
  printf '%b\n' "${green}Environment check${reset}"
  line
  printf 'OS:           '; uname -a 2>/dev/null || printf 'unavailable\n'
  printf 'Shell:        %s\n' "${BASH_VERSION:-unknown}"
  printf 'Termux path:  %s\n' "${PREFIX:-not detected}"
  printf 'Architecture:  %s\n' "$(uname -m 2>/dev/null || printf 'unknown')"
  printf 'Storage:       %s\n' "$(df -h "${PREFIX:-$HOME}" 2>/dev/null | awk 'NR==2 {print $4 " free of " $2}' || printf 'unavailable')"
  if has_cmd pkg; then
    printf 'Package mgr:   %b ready%b\n' "$green" "$reset"
  else
    printf 'Package mgr:   %bnot detected%b\n' "$amber" "$reset"
  fi
  printf '\n%bNo files were changed by this check.%b\n' "$dim" "$reset"
}

network_diagnostics() {
  printf '%b\n' "${green}Network diagnostics${reset}"
  line
  if has_cmd getprop; then
    printf 'Android release: %s\n' "$(getprop ro.build.version.release 2>/dev/null || printf 'unavailable')"
    printf 'Device model:    %s\n' "$(getprop ro.product.model 2>/dev/null || printf 'unavailable')"
  fi
  printf 'Internet probe:  '
  if has_cmd curl && curl -fsS --max-time 4 https://connectivitycheck.gstatic.com/generate_204 -o /dev/null 2>/dev/null; then
    printf '%breachable%b\n' "$green" "$reset"
  else
    printf '%bnot confirmed%b\n' "$amber" "$reset"
  fi
  printf 'DNS resolver:    '
  if has_cmd getent && getent hosts example.com >/dev/null 2>&1; then
    printf '%bworking%b\n' "$green" "$reset"
  else
    printf '%bnot confirmed%b\n' "$amber" "$reset"
  fi
  if has_cmd ip; then
    printf '\nInterfaces (names and state only):\n'
    ip -brief link 2>/dev/null | sed -n '1,12p'
  fi
  printf '\n%bCredential policy:%b Wi-Fi passwords and other secrets are never read or displayed.\n' "$red" "$reset"
}

storage_health() {
  printf '%b\n' "${green}Storage and package health${reset}"
  line
  printf 'Home:          %s\n' "$HOME"
  printf 'Home usage:    %s\n' "$(du -sh "$HOME" 2>/dev/null | awk '{print $1}' || printf 'unavailable')"
  if has_cmd pkg; then
    printf 'Package index:  '
    if pkg list-installed >/dev/null 2>&1; then printf '%breadable%b\n' "$green" "$reset"; else printf '%bnot confirmed%b\n' "$amber" "$reset"; fi
    printf 'Installed pkgs: %s\n' "$(pkg list-installed 2>/dev/null | awk 'END {print NR-1}' || printf 'unavailable')"
  else
    printf 'Package index:  %bnot detected%b\n' "$amber" "$reset"
  fi
  printf '\n%bRead-only inspection complete. No package upgrades were started.%b\n' "$dim" "$reset"
}

updates_guidance() {
  printf '%b\n' "${green}Non-destructive update guidance${reset}"
  line
  cat <<'EOF'
1. Confirm you installed Termux from a trusted source (F-Droid or the official project).
2. Back up important files before changing packages.
3. Review changes first:   pkg update
4. Apply updates only when ready:   pkg upgrade
5. Keep Termux and its plugins from the same trusted source.
6. Never paste commands from strangers that request tokens, passwords, or remote access.

Termux Guardian does not run upgrades automatically.
EOF
}

recovery_guidance() {
  printf '%b\n' "${green}Authorized recovery guidance${reset}"
  line
  cat <<'EOF'
Forgot a Wi-Fi password?
  • Use the Android Settings sharing/QR flow on a device you own or administer.
  • Check the router label, router admin panel, or your ISP's official recovery flow.
  • Ask the network owner to reset or share access.

Forgot an account password?
  • Use the provider's official account-recovery page.
  • Verify the recovery email or phone you control.
  • Never send passwords or recovery codes to a helper or script.

This toolkit intentionally does not expose stored secrets.
EOF
}

run_command() {
  case "${1:-help}" in
    check) check_environment ;; network) network_diagnostics ;; storage) storage_health ;;
    updates) updates_guidance ;; recovery) recovery_guidance ;; help|-h|--help) usage ;;
    *) printf '%bUnknown command:%b %s\n\n' "$amber" "$reset" "$1"; usage; return 2 ;;
  esac
}

menu() {
  while true; do
    header
    printf '%b\n' "${dim}SAFE MODE · READ-ONLY FIRST · OWNER: MrCodex1Tz${reset}\n"
    printf '%b\n' "  ${cyan}1${reset}  Environment check"
    printf '%b\n' "  ${cyan}2${reset}  Network diagnostics"
    printf '%b\n' "  ${cyan}3${reset}  Storage & package health"
    printf '%b\n' "  ${cyan}4${reset}  Non-destructive update guidance"
    printf '%b\n' "  ${cyan}5${reset}  Account / network recovery guidance"
    printf '%b\n' "  ${cyan}h${reset}  Command help"
    printf '%b\n' "  ${cyan}q${reset}  Exit"
    line
    read -r -p '  Select an action: ' choice || exit 0
    printf '\n'
    case "$choice" in
      1) check_environment ;; 2) network_diagnostics ;; 3) storage_health ;;
      4) updates_guidance ;; 5) recovery_guidance ;; h|H) usage ;;
      q|Q) printf 'Stay authorized. Stay safe.\n'; exit 0 ;;
      *) printf '%bPlease choose 1–5, h, or q.%b\n' "$amber" "$reset" ;;
    esac
    printf '\n'; read -r -p '  Press Enter to return to the menu...' _ || exit 0
  done
}

if [[ $# -eq 0 ]]; then menu; else run_command "$1"; fi
