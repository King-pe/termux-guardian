# Termux Guardian

> A safer command center for Android defenders who work in Termux.

**Owner:** MrCodex1Tz  ·  **Version:** 0.1.0  ·  **Mode:** defensive and non-destructive

Termux Guardian is an English-language toolkit for visibility, safe environment checks, network diagnostics, storage health, update guidance, and authorized recovery guidance. It is designed to help people understand their own devices without crossing into credential access or destructive behavior.

## Safety comes first

Termux Guardian **never extracts, reveals, stores, or displays Wi-Fi passwords, tokens, keys, cookies, or any other credentials**. Network diagnostics inspect connectivity, DNS, interface names, and Android metadata only. If you forgot a password, use Android Settings, the router or ISP's official recovery flow, or the account provider's official recovery page.

Use this project only on devices, networks, and accounts you own or are explicitly authorized to administer. Do not use it to bypass access controls, intercept traffic, evade detection, or access someone else's data.

## Install in Termux

The normal public flow does **not** require `gh auth login`. It clones only the official origin, verifies the origin, and then starts the numbered menu. The repository is currently **private**, however, so anonymous cloning cannot work until the owner makes it public or grants your GitHub account access.

When the repository is public, use this numbered flow:

```bash
pkg update
1. pkg update
2. pkg install -y git bash curl iproute2
3. curl -fsSL https://raw.githubusercontent.com/King-pe/termux-guardian/main/install.sh | bash
```

For the current private repository, an authorized owner or collaborator must authenticate before cloning:

```bash
pkg update
pkg install -y git bash curl iproute2 gh
gh auth login
gh repo clone King-pe/termux-guardian "$HOME/termux-guardian"
cd "$HOME/termux-guardian"
bash termuxguardian.sh
```

The installer prints blue numbered steps, red failure messages, checks GitHub before cloning, verifies that `origin` is exactly `King-pe/termux-guardian`, and stops with one clear message. It never continues to `cd`, `chmod`, or run a missing file after a failed clone. Review every command before running it.

### Troubleshooting a GitHub timeout

Run this check first:

```bash
curl -I --connect-timeout 10 https://github.com
```

If it times out, switch networks or retry later; Termux mirrors working does not prove that GitHub is reachable from the current network. If GitHub responds but cloning says access is denied, authenticate with `gh auth login` or ask the repository owner for access. The follow-up errors `cd: termux-guardian: No such file or directory`, `chmod: cannot access`, and `./termuxguardian.sh: No such file` are only consequences of the clone failing.

## Command reference

| Command | What it does | Changes files? |
| --- | --- | --- |
| `./termuxguardian.sh` | Opens the navigable menu | No |
| `./termuxguardian.sh check` | Prints safe environment metadata and storage summary | No |
| `./termuxguardian.sh network` | Checks connectivity, DNS, and interface names | No |
| `./termuxguardian.sh storage` | Checks home usage and package index readability | No |
| `./termuxguardian.sh updates` | Prints reviewed, manual update steps | No |
| `./termuxguardian.sh recovery` | Prints official recovery paths for forgotten access | No |
| `./termuxguardian.sh help` | Prints CLI help and safety policy | No |

## Repository activity

The companion dashboard can show public GitHub metadata such as forks, stars, watchers, and the last update when the repository API permits it. GitHub does **not** expose a public visitor count for most repositories: traffic views require repository-owner access. The dashboard therefore shows `Unavailable` rather than inventing a number. If you have owner access, use **GitHub → Insights → Traffic** for views and unique visitors.

| Metric | Source | Status |
| --- | --- | --- |
| Forks | GitHub repository API | Loaded on the dashboard when available |
| Stars | GitHub repository API | Loaded on the dashboard when available |
| Visitors | GitHub Insights → Traffic | Owner-only; not faked |

## Ownership and forks

MrCodex1Tz is the project owner and maintainer. `.github/CODEOWNERS` requests owner review for changes to the toolkit, safety policy, documentation, and governance files. The CLI also refuses to run when `origin` is not exactly `github.com/King-pe/termux-guardian`.

A GitHub fork is a separate repository controlled by its fork owner. No upstream project can technically prevent a fork owner from changing their own fork, changing its organization, or transferring it. What this project enforces is that the official executable runs only from the official origin; forks can still be inspected or developed separately, but they are not treated as the official runtime source.

## Development

Run the local dashboard without installing dependencies:

```bash
python3 server.py
# open http://127.0.0.1:3000
```

Run the shell smoke tests:

```bash
bash tests/test_toolkit.sh
```

## License and contributions

Contributions are welcome through pull requests that preserve the safety boundary. Read [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing. A contribution does not transfer ownership of the project, its name, or its official infrastructure.
