# Contributing to Termux Guardian

Termux Guardian is maintained by **MrCodex1Tz**. Contributions should improve defensive visibility, safe diagnostics, documentation, accessibility, or test coverage without weakening the credential-safety boundary.

## Workflow

1. Open an issue describing the problem and the authorized, defensive use case.
2. Fork the repository or create a branch in an authorized clone.
3. Keep changes focused and explain user impact in the pull request.
4. Run `bash tests/test_toolkit.sh` and manually review shell changes.
5. Submit a pull request. Changes to the toolkit, governance, safety policy, or release configuration require maintainer approval.

## Non-negotiables

Do not add password extraction, token scraping, key logging, stealth, persistence, bypasses, destructive cleanup, traffic interception, or unauthorized access features. Do not claim that a fork is the official Termux Guardian project. The owner may reject changes that create safety, legal, or maintenance risk.

A pull request grants the project a non-exclusive right to review and distribute the contribution under the repository license; it does not transfer ownership of the repository, brand, or official channels.
