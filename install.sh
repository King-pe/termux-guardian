#!/data/data/com.termux/files/usr/bin/bash
set -u

REPO_URL="${TERMUX_GUARDIAN_REPO_URL:-https://github.com/King-pe/termux-guardian.git}"
TARGET_DIR="${TERMUX_GUARDIAN_DIR:-$HOME/termux-guardian}"

fail() {
  printf '\n[Termux Guardian] ERROR: %s\n' "$1" >&2
  exit 1
}

printf '%s\n' '[Termux Guardian] Checking GitHub connectivity…'
if ! command -v git >/dev/null 2>&1; then
  fail 'git is not installed. Run: pkg install -y git bash curl iproute2'
fi

if ! git ls-remote --exit-code --heads "$REPO_URL" main >/dev/null 2>&1; then
  printf '%s\n' '[Termux Guardian] GitHub is unreachable or this private repository needs authentication.' >&2
  printf '%s\n' 'Check your internet connection, then retry. If the repository is private, authenticate with GitHub before cloning.' >&2
  printf '%s\n' 'Example: pkg install -y gh && gh auth login && gh repo clone King-pe/termux-guardian' >&2
  exit 1
fi

if [ -e "$TARGET_DIR" ]; then
  fail "destination already exists: $TARGET_DIR (choose another directory or remove it intentionally)"
fi

printf '%s\n' '[Termux Guardian] Downloading the official repository…'
if ! git clone --depth 1 "$REPO_URL" "$TARGET_DIR"; then
  rm -rf "$TARGET_DIR"
  fail 'the download failed; no partial directory was kept'
fi

cd "$TARGET_DIR" || fail "cannot enter $TARGET_DIR"
chmod +x termuxguardian.sh
printf '\n[Termux Guardian] Installed successfully. Starting the menu…\n\n'
exec ./termuxguardian.sh
