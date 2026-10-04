#!/data/data/com.termux/files/usr/bin/bash
set -u

REPO_URL="${TERMUX_GUARDIAN_REPO_URL:-https://github.com/King-pe/termux-guardian.git}"
TARGET_DIR="${TERMUX_GUARDIAN_DIR:-$HOME/termux-guardian}"
OFFICIAL_REPO="King-pe/termux-guardian"
BLUE='\033[1;34m'; RED='\033[1;31m'; RESET='\033[0m'

fail() {
  printf '\n%b[Termux Guardian] ERROR:%b %s\n' "$RED" "$RESET" "$1" >&2
  exit 1
}

printf '%b\n' "${BLUE}╔══════════════════════════════════════════════════════════╗${RESET}"
printf '%b\n' "${BLUE}║        TERMUX GUARDIAN · OFFICIAL INSTALLER             ║${RESET}"
printf '%b\n' "${BLUE}╚══════════════════════════════════════════════════════════╝${RESET}"
printf '%b\n' "${BLUE}[01]${RESET} Checking GitHub connectivity…"
if ! command -v git >/dev/null 2>&1; then
  fail 'git is not installed. Run: pkg install -y git bash curl iproute2'
fi

if ! git ls-remote --exit-code --heads "$REPO_URL" main >/dev/null 2>&1; then
  printf '%b\n' "${RED}GitHub is unreachable or this private repository needs authentication.${RESET}" >&2
  printf '%s\n' 'Check your internet connection, then retry. If the repository is private, authenticate with GitHub before cloning.' >&2
  printf '%s\n' 'For the current private repository, use an authorized GitHub account. Public mode will not need login.' >&2
  exit 1
fi

if [ -e "$TARGET_DIR" ]; then
  fail "destination already exists: $TARGET_DIR (choose another directory or remove it intentionally)"
fi

printf '%b\n' "${BLUE}[02]${RESET} Downloading the official repository…"
if ! git clone --depth 1 "$REPO_URL" "$TARGET_DIR"; then
  rm -rf "$TARGET_DIR"
  fail 'the download failed; no partial directory was kept'
fi

cd "$TARGET_DIR" || fail "cannot enter $TARGET_DIR"
chmod +x termuxguardian.sh
origin="$(git config --get remote.origin.url 2>/dev/null || true)"
normalized="${origin%/}"
normalized="${normalized%.git}"
normalized="${normalized#https://github.com/}"
normalized="${normalized#http://github.com/}"
normalized="${normalized#git@github.com:}"
normalized="${normalized#ssh://git@github.com/}"
if [[ "$normalized" != "$OFFICIAL_REPO" ]]; then
  rm -rf "$TARGET_DIR"
  fail "official origin check failed; expected github.com/$OFFICIAL_REPO"
fi
printf '%b\n' "${BLUE}[03]${RESET} Entering official repository"
printf '%b\n' "${BLUE}[04]${RESET} Verifying origin: ${OFFICIAL_REPO}"
printf '%b\n' "${BLUE}[05]${RESET} Starting safe numbered menu…\n"
exec ./termuxguardian.sh
