# cmi_gateway — Claude policy

Source of truth for AI assistants working in this repository.

## What this project is

- A **Ruby gem** for **CMI (Morocco) 3D Pay Hosting**: building signed checkout parameters (SHA-512 + Base64) and parsing server callbacks.
- **Runtime dependency: Ruby standard library only** (`digest`, `base64`, `bigdecimal`, etc.). No Rails, no ActiveSupport, no HTTP client in the gem itself.

## Scope

- **In scope:** `lib/cmi_gateway/**/*.rb`, `spec/`, CI workflow, docs at repo root, version in `lib/cmi_gateway/version.rb`.
- **Out of scope:** Application-specific checkout URLs, webhooks, or ActiveRecord — consumers (e.g. Rails apps) own that integration.

## Non-negotiables

1. **Do not change the hash signing algorithm** (key sort order, skipped keys `hash`/`encoding`, escape order for `|` and `\`, accent-strip behavior, append store key, SHA-512, Base64) without treating it as a **breaking change**: major version bump, **CHANGELOG** entry, and clear migration notes. Merchants depend on bit-exact compatibility with CMI’s integration guides.
2. **Do not add runtime gem dependencies** unless there is an exceptional reason; prefer stdlib.
3. **Do not remove or rename public API** (`CmiGateway::Checkout`, `Callback`, `Configuration`, `configure`, etc.) without a semver-appropriate release and CHANGELOG.
4. **Do not commit secrets** (store keys, client IDs, test cards). Use environment variables in examples only.

## Engineering rules

- Match existing code style (frozen string literal, module layout, RSpec patterns).
- Add or update **specs** for any behavior change in `lib/`.
- Keep **README** in sync with the public API when behavior or configuration changes.
- Prefer **small, focused PRs**; avoid drive-by refactors unrelated to the task.

## Definition of done (library changes)

- `bundle exec rspec` passes.
- `bundle exec rubocop` passes (or new offenses are justified and fixed).
- **CHANGELOG.md** updated for user-visible or compatibility-affecting changes.
- Version bump follows [SemVer](https://semver.org/) when releasing.

## References

- CMI integration patterns (project-specific): see link in `README.md` / historical gist referenced in consuming apps.
- **License:** MIT — see `LICENSE.txt`.
- **Contributing / security:** `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`.
