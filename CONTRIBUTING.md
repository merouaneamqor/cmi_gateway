# Contributing

Thank you for helping improve **cmi_gateway**.

## Getting started

```bash
git clone https://github.com/merouaneamqor/cmi_gateway.git
cd cmi_gateway
bundle install
bundle exec rspec
bundle exec rubocop
```

Ruby **3.1+** is required (see `cmi_gateway.gemspec`).

## Pull requests

1. Fork the repository and create a branch from `master`.
2. Make focused changes; include **tests** for new or fixed behavior in `lib/`.
3. Run `bundle exec rspec` and `bundle exec rubocop` before opening a PR.
4. Update **CHANGELOG.md** under `[Unreleased]` (or the maintainer will) for anything that affects users or integrators.
5. Describe **what** changed and **why** in the PR description.

## Commit messages

Clear, imperative messages are welcome (e.g. `fix(checkout): handle empty extra_params`). [Conventional Commits](https://www.conventionalcommits.org/) are optional but appreciated.

## Hash / CMI compatibility

Changes that alter how the **checkout hash** is computed are **breaking** for live integrations. They need a **major version** bump and explicit **CHANGELOG** and README notes.

## Code of conduct

All participants are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Please report security issues privately — see [SECURITY.md](SECURITY.md).
