# Termux Guardian — implementation plan

## Product direction
Termux Guardian is an English-language, defensive mobile-security toolkit for Termux with a companion dashboard. It is branded and maintained by **MrCodex1Tz**. The toolkit focuses on visibility, safe checks, recovery guidance, and non-destructive maintenance.

## Safety boundary
The toolkit must not extract, reveal, store, or display Wi-Fi passwords, tokens, keys, or other credentials. Network features inspect connectivity and configuration only, then point users to authorized router, ISP, device, or platform recovery flows.

## Design system
- **Design movement:** Terminal brutalism refined into a premium operations console.
- **Core principles:** high signal, transparent status, calm safety cues, and copy-first usability.
- **Color philosophy:** near-black graphite for focus, electric cyan for verified telemetry, amber for review-needed states, and coral only for explicit danger notices.
- **Layout paradigm:** asymmetric command-center layout with a left rail, a wide hero command surface, and stacked evidence panels rather than a centered marketing grid.
- **Signature elements:** scanline texture, cyan status rail, and monospace command chips with copy affordances.
- **Interaction philosophy:** every action explains what it checks, what it changes, and what it intentionally refuses to do.
- **Animation:** restrained 160–240ms transitions, pulsing status dots only for live checks, no decorative motion during command reading.
- **Typography:** Space Grotesk for interface hierarchy and IBM Plex Mono for commands, labels, and telemetry.
- **Brand essence:** “A safer command center for Android defenders who work in Termux.” Personality: precise, protective, uncompromising.
- **Brand voice:** direct, technical, respectful. Example lines: “See the signal before you touch the system.” / “Credential secrecy is a feature, not a limitation.”
- **Wordmark:** a split-shield glyph formed from `>` and `_`, paired with the Termux Guardian wordmark.
- **Signature brand color:** electric cyan `#52f2e0`.

## Structure
- `termuxguardian.sh`: executable Termux CLI with menu and safe subcommands.
- `tests/test_toolkit.sh`: shell smoke tests for command behavior and safety assertions.
- `README.md`, `CONTRIBUTING.md`, `SECURITY.md`: setup, governance, and responsible-use documentation.
- `.github/`: CODEOWNERS and CI workflow for owner review and regression checks.
- `index.html`, `styles.css`, `app.js`: static dashboard companion site.
- `server.py`: dependency-free local preview server.
- `public/manus-routes.json`: Webdev route manifest.

## Delivery assumptions
The GitHub repository is created private by default under the authenticated GitHub account. Fork owners can always modify their own forks; repository rules can protect the upstream default branch, not rewrite fork ownership. Live visitor counts are only available when a public API or configured analytics source provides them, so the dashboard displays transparent unavailable states rather than inventing numbers.
