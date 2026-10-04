#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

VERSION="0.2.0"
APP_NAME="Termux Guardian"
OFFICIAL_REPO="King-pe/termux-guardian"
QUARANTINE_DIR="${HOME:-.}/.termux-guardian/quarantine"

blue='\033[1;34m'; cyan='\033[38;5;51m'; green='\033[38;5;82m'; amber='\033[38;5;214m'; red='\033[1;31m'; dim='\033[2m'; reset='\033[0m'

has_cmd() { command -v "$1" >/dev/null 2>&1; }
line() { printf '%b\n' "${dim}────────────────────────────────────────────────────────────${reset}"; }
normalize_repo() {
  local value="${1%/}"
  value="${value%.git}"
  value="${value#https://github.com/}"
  value="${value#http://github.com/}"
  value="${value#git@github.com:}"
  value="${value#ssh://git@github.com/}"
  printf '%s' "$value"
}
official_repository_guard() {
  [[ "${TERMUX_GUARDIAN_TEST_MODE:-0}" == "1" ]] && return 0
  local root origin normalized
  root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$root" ]] || { printf '%b\n' "${red}STOP: run this tool from the official Git repository.${reset}" >&2; return 1; }
  origin="$(git -C "$root" config --get remote.origin.url 2>/dev/null || true)"
  normalized="$(normalize_repo "$origin")"
  if [[ "$normalized" != "$OFFICIAL_REPO" ]]; then
    printf '%b\n' "${red}STOP: unofficial repository detected.${reset}" >&2
    printf '%b\n' "${red}Expected: github.com/${OFFICIAL_REPO}${reset}" >&2
    printf '%b\n' "${dim}Forks may change their own code, but this executable only runs from the official origin.${reset}" >&2
    return 1
  fi
}
banner() {
  printf '%b\n' "${blue} ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗ ██╗ █████╗ ███╗   ██╗${reset}"
  printf '%b\n' "${blue}██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗██║██╔══██╗████╗  ██║${reset}"
  printf '%b\n' "${blue}██║  ███╗██║   ██║███████║██████╔╝██║  ██║██║███████║██╔██╗ ██║${reset}"
  printf '%b\n' "${blue}██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║██║██╔══██║██║╚██╗██║${reset}"
  printf '%b\n' "${blue}╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝██║██║  ██║██║ ╚████║${reset}"
  printf '%b\n' "${blue} ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝${reset}"
}
header() {
  clear 2>/dev/null || true
  banner
  printf '%b\n' "${red}OFFICIAL ORIGIN ONLY · MrCodex1Tz${reset}"
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
  ./termuxguardian.sh dns             Diagnose DNS with system and fallback resolvers
  ./termuxguardian.sh location        Show location and optionally open OpenStreetMap
  ./termuxguardian.sh scan quick      Run a fast malware-risk scan
  ./termuxguardian.sh scan full       Run a deeper malware-risk scan
  ./termuxguardian.sh quarantine      Review and quarantine scan findings
  ./termuxguardian.sh link <URL>      Analyze a link without opening it
  ./termuxguardian.sh help            Show this help

Safety boundary:
  This tool never extracts, reveals, stores, or displays Wi-Fi passwords,
  tokens, keys, or other credentials. It only reads safe system metadata.

Repository policy:
  This executable runs only when git origin is github.com/King-pe/termux-guardian.

Malware policy:
  Scans are defensive and local. Findings are quarantined only after confirmation;
  files are never silently deleted. Link analysis never opens or downloads a URL.
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
  dns_diagnostics
  if has_cmd ip; then
    printf '\nInterfaces (names and state only):\n'
    ip -brief link 2>/dev/null | sed -n '1,12p'
  fi
  printf '\n%bCredential policy:%b Wi-Fi passwords and other secrets are never read or displayed.\n' "$red" "$reset"
}

dns_diagnostics() {
  local dns1="${dns1:-}" resolver_ok=0
  if has_cmd getprop; then dns1="$(getprop net.dns1 2>/dev/null || true)"; fi
  printf 'DNS resolver:    '
  if has_cmd getent && getent hosts example.com >/dev/null 2>&1; then
    resolver_ok=1; printf '%bworking (system resolver)%b\n' "$green" "$reset"
  elif has_cmd nslookup && nslookup -timeout=3 example.com 1.1.1.1 >/dev/null 2>&1; then
    resolver_ok=1; printf '%bworking (fallback 1.1.1.1)%b\n' "$green" "$reset"
  elif has_cmd dig && dig +time=3 +tries=1 @1.1.1.1 example.com >/dev/null 2>&1; then
    resolver_ok=1; printf '%bworking (fallback 1.1.1.1)%b\n' "$green" "$reset"
  else
    printf '%bnot confirmed%b\n' "$amber" "$reset"
  fi
  [[ -n "$dns1" ]] && printf 'Android DNS:     %s\n' "$dns1"
  if [[ "$resolver_ok" == "0" ]]; then
    printf '%bDNS repair:%b pkg install -y dnsutils; then retry ./termuxguardian.sh dns\n' "$amber" "$reset"
    printf '%bIf fallback works but system fails, check Android Private DNS or change network.%b\n' "$dim" "$reset"
  fi
}

my_location() {
  local payload lat lon map_url answer
  printf '%bMy Location Maps%b\n' "$green" "$reset"; line
  printf '%bLocation is read only from Termux:API and is not stored by this tool.%b\n' "$dim" "$reset"
  if ! has_cmd termux-location; then
    printf '%btermux-location is not installed.%b\n' "$amber" "$reset"
    printf 'Install the Termux:API app from the same trusted source as Termux, then run: pkg install -y termux-api\n'
    return 1
  fi
  payload="$(termux-location -p network -r once 2>/dev/null || true)"
  lat="$(printf '%s' "$payload" | sed -n 's/.*"latitude"[[:space:]]*:[[:space:]]*\([-0-9.]*\).*/\1/p')"
  lon="$(printf '%s' "$payload" | sed -n 's/.*"longitude"[[:space:]]*:[[:space:]]*\([-0-9.]*\).*/\1/p')"
  [[ -n "$lat" && -n "$lon" ]] || { printf '%bLocation unavailable. Grant permission and enable device location.%b\n' "$amber" "$reset"; return 1; }
  printf 'Coordinates:     %s, %s\n' "$lat" "$lon"
  map_url="https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}#map=16/${lat}/${lon}"
  printf 'Map:             %s\n' "$map_url"
  read -r -p 'Type OPEN to launch the map in your browser: ' answer
  [[ "$answer" == "OPEN" ]] || { printf 'Map was not opened.\n'; return 0; }
  if has_cmd termux-open-url; then termux-open-url "$map_url"; elif has_cmd am; then am start -a android.intent.action.VIEW -d "$map_url" >/dev/null; else printf 'Open the Map URL above manually.\n'; fi
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

scan_file_risk() {
  local path="$1" lower
  lower="${path,,}"
  case "$lower" in
    *.apk|*.dex|*.jar|*.so|*.sh|*.py|*.js|*.php|*.elf)
      if grep -aEiq 'base64[[:space:]]+-d|curl[[:space:]].*\|[[:space:]]*(sh|bash)|wget[[:space:]].*\|[[:space:]]*(sh|bash)|rm[[:space:]]+-rf[[:space:]]+/' "$path" 2>/dev/null; then
        printf '%s\t%s\n' "$path" 'suspicious executable pattern'
      fi
      ;;
  esac
}

malware_scan() {
  local mode="${1:-quick}" roots=() report count=0 file root limit
  [[ "$mode" == "full" || "$mode" == "quick" ]] || { printf '%bUnknown scan mode. Use quick or full.%b\n' "$amber" "$reset"; return 2; }
  report="${HOME:-.}/.termux-guardian/scan-findings.tsv"
  mkdir -p "$(dirname "$report")"
  : > "$report"
  printf '%b\n' "${green}${mode^} malware-risk scan${reset}"
  line
  printf '%bThis scan reads local files only; it does not delete or execute anything.%b\n' "$dim" "$reset"
  if has_cmd clamscan; then printf 'Engine:          ClamAV detected\n'; else printf 'Engine:          heuristic checks (ClamAV not installed)\n'; fi
  if [[ "$mode" == "full" ]]; then roots=("${HOME:-.}"); limit=20000; else roots=("${HOME:-.}/downloads" "${HOME:-.}/storage/downloads" "${HOME:-.}"); limit=3000; fi
  for root in "${roots[@]}"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r -d '' file; do
      [[ "$file" == "$report" ]] && continue
      if has_cmd clamscan && clamscan --no-summary --infected "$file" 2>/dev/null | grep -q 'FOUND$'; then
        printf '%s\t%s\n' "$file" 'ClamAV detection' >> "$report"
      else
        scan_file_risk "$file" >> "$report" || true
      fi
    done < <(find "$root" -type f -size -25M -print0 2>/dev/null | head -z -n "$limit")
  done
  count="$(wc -l < "$report" | tr -d ' ')"
  if [[ "$count" == "0" ]]; then
    printf '%bRESULT: SAFE — no suspicious findings in the scanned files.%b\n' "$green" "$reset"
  else
    printf '%bRESULT: DANGER REVIEW — %s finding(s) saved to:%b %s\n' "$red" "$count" "$reset" "$report"
    sed -n '1,20p' "$report"
    printf '%bRun ./termuxguardian.sh quarantine to review before moving files.%b\n' "$amber" "$reset"
  fi
}

quarantine_findings() {
  local report="${HOME:-.}/.termux-guardian/scan-findings.tsv" answer path reason target
  [[ -s "$report" ]] || { printf '%bNo scan findings are waiting for review.%b\n' "$green" "$reset"; return 0; }
  printf '%bPending findings:%b\n' "$red" "$reset"; cat "$report"
  printf '\nThis moves files into a private quarantine folder; it does not delete them.\n'
  read -r -p 'Type QUARANTINE to continue: ' answer
  [[ "$answer" == "QUARANTINE" ]] || { printf 'No files were moved.\n'; return 0; }
  mkdir -p "$QUARANTINE_DIR"; chmod 700 "$QUARANTINE_DIR"
  while IFS=$'\t' read -r path reason; do
    [[ -f "$path" ]] || continue
    target="$QUARANTINE_DIR/$(basename "$path").$(date +%s).quarantined"
    mv -- "$path" "$target"
    printf '%bQUARANTINED%b %s → %s (%s)\n' "$red" "$reset" "$path" "$target" "$reason"
  done < "$report"
  : > "$report"
}

link_scan() {
  local url="${1:-}" host="" risk=0 reasons=()
  [[ -n "$url" ]] || { printf 'Usage: ./termuxguardian.sh link <URL>\n'; return 2; }
  printf '%bLink safety analysis%b\n' "$green" "$reset"; line
  printf '%bThis check does not open, resolve, download, or submit the link.%b\n' "$dim" "$reset"
  [[ "$url" =~ ^https?:// ]] || { risk=1; reasons+=("missing HTTP/HTTPS scheme"); }
  host="${url#*://}"; host="${host%%/*}"; host="${host%%\?*}"; host="${host%%#*}"
  [[ "$host" == *"@"* ]] && { risk=1; reasons+=("embedded username or redirect pattern"); }
  [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]] && { risk=1; reasons+=("raw IP address host"); }
  [[ "$host" == xn--* || "$host" == *".xn--"* ]] && { risk=1; reasons+=("punycode domain"); }
  [[ "$host" =~ (bit\.ly|tinyurl\.com|t\.co|goo\.gl|is\.gd|cutt\.ly)$ ]] && { risk=1; reasons+=("URL shortener hides destination"); }
  [[ "$url" =~ (login|verify|wallet|reset|security|password|account) ]] && { risk=1; reasons+=("credential-themed wording"); }
  if [[ "$risk" == "0" ]]; then
    printf '%bSAFE LINK%b — no obvious local warning pattern detected. Still verify the domain before opening.\n' "$green" "$reset"
  else
    printf '%bDANGER / PHISHING RISK%b — do not open this link.\n' "$red" "$reset"
    printf 'Reasons: %s\n' "${reasons[*]}"
  fi
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
    check) check_environment ;; network) network_diagnostics ;; dns) dns_diagnostics ;; storage) storage_health ;;
    updates) updates_guidance ;; recovery) recovery_guidance ;; location) my_location ;; scan) malware_scan "${2:-quick}" ;;
    quarantine) quarantine_findings ;; link) link_scan "${2:-}" ;; help|-h|--help) usage ;;
    *) printf '%bUnknown command:%b %s\n\n' "$amber" "$reset" "$1"; usage; return 2 ;;
  esac
}

menu() {
  while true; do
    header
    printf '%b\n' "${dim}NUMBERED STEPS · SAFE MODE · READ-ONLY FIRST${reset}\n"
    printf '%b\n' "  ${blue}[01]${reset}  Environment check"
    printf '%b\n' "  ${blue}[02]${reset}  Network diagnostics"
    printf '%b\n' "  ${blue}[03]${reset}  Storage & package health"
    printf '%b\n' "  ${blue}[04]${reset}  Non-destructive update guidance"
    printf '%b\n' "  ${blue}[05]${reset}  Account / network recovery guidance"
    printf '%b\n' "  ${blue}[06]${reset}  DNS resolver check / repair guidance"
    printf '%b\n' "  ${blue}[07]${reset}  Quick malware-risk scan"
    printf '%b\n' "  ${blue}[08]${reset}  Full malware-risk scan"
    printf '%b\n' "  ${blue}[09]${reset}  Review / quarantine findings"
    printf '%b\n' "  ${blue}[10]${reset}  Scan a link (never opens it)"
    printf '%b\n' "  ${blue}[11]${reset}  My Location Maps"
    printf '%b\n' "  ${blue}[H ]${reset}  Command help"
    printf '%b\n' "  ${red}[Q ]${reset}  Exit"
    line
    read -r -p '  Select an action: ' choice || exit 0
    printf '\n'
    case "$choice" in
      1|01) check_environment ;; 2|02) network_diagnostics ;; 3|03) storage_health ;;
      4|04) updates_guidance ;; 5|05) recovery_guidance ;; 6|06) dns_diagnostics ;;
      7|07) malware_scan quick ;; 8|08) malware_scan full ;; 9|09) quarantine_findings ;; 10)
        read -r -p '  Paste URL to analyze: ' url; link_scan "$url" ;;
      11) my_location ;;
      h|H) usage ;;
      q|Q) printf 'Stay authorized. Stay safe.\n'; exit 0 ;;
      *) printf '%bPlease choose 01–11, H, or Q.%b\n' "$amber" "$reset" ;;
    esac
    printf '\n'; read -r -p '  Press Enter to return to the menu...' _ || exit 0
  done
}

official_repository_guard || exit 1
if [[ $# -eq 0 ]]; then menu; else run_command "$@"; fi
