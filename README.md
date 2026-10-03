# Termux Guardian

> A safer command center for Android defenders who work in Termux.

**Owner:** MrCodex1Tz  ·  **Version:** 0.1.0  ·  **Mode:** defensive and non-destructive

Termux Guardian is an English-language toolkit for visibility, safe environment checks, network diagnostics, storage health, update guidance, and authorized recovery guidance. It is designed to help people understand their own devices without crossing into credential access or destructive behavior.

## Safety comes first

Termux Guardian **never extracts, reveals, stores, or displays Wi-Fi passwords, tokens, keys, cookies, or any other credentials**. Network diagnostics inspect connectivity, DNS, interface names, and Android metadata only. If you forgot a password, use Android Settings, the router or ISP's official recovery flow, or the account provider's official recovery page.

Use this project only on devices, networks, and accounts you own or are explicitly authorized to administer. Do not use it to bypass access controls, intercept traffic, evade detection, or access someone else's data.

## Install in Termux

```bash
pkg update
pkg install -y git bash curl iproute2
cd "$HOME"
git clone https://github.com/King-pe/termux-guardian.git
cd termux-guardian
chmod +x termuxguardian.sh
./termuxguardian.sh
```

If the repository owner changes the GitHub path, replace the clone URL with the official URL shown on the companion site. Review every command before running it.

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

MrCodex1Tz is the project owner and maintainer. `.github/CODEOWNERS` requests owner review for changes to the toolkit, safety policy, documentation, and governance files. The default branch should also be protected in GitHub repository settings with required pull requests and owner approval.

A GitHub fork is a separate repository controlled by its fork owner. No upstream project can technically prevent a fork owner from changing their own fork or transferring ownership of it. What this repository can enforce is upstream review, attribution, licensing, and clear provenance.

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
