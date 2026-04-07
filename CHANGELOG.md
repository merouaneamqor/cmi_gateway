# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-07

### Added

- `CmiGateway::Configuration` and global `CmiGateway.configure` for environment and named merchant profiles.
- `CmiGateway::Checkout` — 3D Pay Hosting parameter build, SHA-512 hash (`ver3`), test/production gateway URLs.
- `CmiGateway::Callback` — parse callback params; `success?` from `ProcReturnCode` / `Response`.
- `CmiGateway::Helpers` — amount formatting, hash escaping, transliteration helpers.
- RSpec suite and GitHub Actions CI (Ruby 3.1–3.3).

[Unreleased]: https://github.com/merouaneamqor/cmi_gateway/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/merouaneamqor/cmi_gateway/releases/tag/v0.1.0
