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

## Publishing to RubyGems.org

1. [Create an account](https://rubygems.org/sign_up) if needed.
2. Create an **API key** with the **Gem push** scope: [RubyGems → Edit profile → API keys](https://rubygems.org/profile/edit).
3. Build and push from the repo root:

   ```bash
   gem build cmi_gateway.gemspec
   gem push cmi_gateway-0.1.0.gem
   ```

   **Windows without Ruby on PATH:** use Docker from `cmi_gateway/`:

   ```cmd
   cd cmi_gateway
   copy .env.example .env
   REM edit .env and set GEM_HOST_API_KEY
   scripts\gem-docker.cmd build
   scripts\gem-docker.cmd push
   ```

   If `*.ps1` opens in an editor instead of running, **use `scripts\gem-docker.cmd`** (or in PowerShell: `powershell -ExecutionPolicy Bypass -File .\scripts\gem-docker.ps1 push`).

   Or set the key only for the session: `$env:GEM_HOST_API_KEY = "rubygems_..."` then run the `.cmd` or `-File` line above.

   Or install [RubyInstaller](https://rubyinstaller.org/) for Windows and tick **“Add Ruby to PATH”**, then open a **new** terminal and use `gem` normally.

   First-time push: run `gem signin` (or write the key to `~/.gem/credentials` as documented on RubyGems).

4. **Non-interactive / CI:** set `GEM_HOST_API_KEY` to your key, then:

   ```bash
   gem push cmi_gateway-0.1.0.gem
   ```

   **PowerShell (same session):**

   ```powershell
   $env:GEM_HOST_API_KEY = "rubygems_xxxxxxxx"   # your key
   gem push cmi_gateway-0.1.0.gem
   ```

5. **Docker** (if Ruby is not on the host): after `gem build` via a Ruby image, push from the host with `gem push`, or:

   ```bash
   docker run --rm -e GEM_HOST_API_KEY -v "$PWD:/gem" -w /gem ruby:3.2-slim bash -c "gem push cmi_gateway-0.1.0.gem"
   ```

### RubyGems MFA (one-time password)

If your account uses MFA, `gem push` needs a 6-digit OTP. With `scripts\gem-docker.cmd push`, the script uses **interactive Docker** (`-it`) so you can **type the code when prompted**.

Alternatively, for a single run (do not commit this):

```cmd
set GEM_HOST_OTP_CODE=123456
scripts\gem-docker.cmd push
```

(`GEM_HOST_OTP_CODE` is supported by RubyGems; see [Using OTP in the command line](https://guides.rubygems.org/using-otp-mfa-in-command-line/).)

After a successful push, bump `lib/cmi_gateway/version.rb`, update `CHANGELOG.md`, tag the release (e.g. `v0.1.1`), and push the tag to GitHub.
