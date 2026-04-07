# Build (and optionally push) cmi_gateway using Docker - no local Ruby required.
# Usage (from repo root cmi_gateway/):
#   scripts\gem-docker.cmd build
#   scripts\gem-docker.cmd push
# Or: powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gem-docker.ps1 push
#
# For push: set GEM_HOST_API_KEY in the environment, or in .env at repo root
# (see .env.example). Existing env vars take precedence over .env.
#
# RubyGems MFA: either
#   - run push as usual: Docker uses -it so you can type the 6-digit OTP when asked, or
#   - set GEM_HOST_OTP_CODE for this session only (from your authenticator), then push.

param(
    [Parameter(Position = 0)]
    [ValidateSet("build", "push")]
    [string]$Action = "build"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Import-DotEnvIfUnset {
    param([string]$EnvPath)
    if (-not (Test-Path $EnvPath)) { return }
    Get-Content -LiteralPath $EnvPath -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\s*#' -or $line -eq '') { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 0) { return }
        $key = $line.Substring(0, $eq).Trim()
        if ($key -eq '') { return }
        $val = $line.Substring($eq + 1).Trim()
        if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
            $val = $val.Substring(1, $val.Length - 2)
        }
        $existing = [Environment]::GetEnvironmentVariable($key, "Process")
        if ([string]::IsNullOrEmpty($existing)) {
            Set-Item -Path "env:$key" -Value $val
        }
    }
}

function Get-GemVersion {
    param([string]$RepoRoot)
    $path = Join-Path $RepoRoot "lib\cmi_gateway\version.rb"
    $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ($raw -match 'VERSION\s*=\s*"([0-9.]+)"') {
        return $Matches[1]
    }
    throw "Could not parse VERSION from $path"
}

if ($Action -eq "build") {
    docker run --rm -v "${Root}:/gem" -w /gem ruby:3.2-slim bash -c "gem build cmi_gateway.gemspec && ls -la *.gem"
    Write-Host ""
    Write-Host "Gem file is in: $Root" -ForegroundColor Green
    exit 0
}

if ($Action -eq "push") {
    Import-DotEnvIfUnset -EnvPath (Join-Path $Root ".env")
    if (-not $env:GEM_HOST_API_KEY) {
        Write-Host "Set GEM_HOST_API_KEY in .env (see .env.example) or in your shell." -ForegroundColor Red
        Write-Host '  $env:GEM_HOST_API_KEY = "rubygems_..."' -ForegroundColor Yellow
        exit 1
    }
    $Version = Get-GemVersion -RepoRoot $Root
    $GemFile = "cmi_gateway-$Version.gem"
    if (-not (Test-Path "$Root\$GemFile")) {
        Write-Host "Missing $GemFile - run: scripts\gem-docker.cmd build" -ForegroundColor Red
        exit 1
    }
    $bashCmd = "gem push $GemFile"
    $dockerArgs = @("run", "--rm")
    if ([string]::IsNullOrEmpty($env:GEM_HOST_OTP_CODE)) {
        Write-Host "MFA: when gem asks, enter the 6-digit code from your authenticator." -ForegroundColor Cyan
        Write-Host "Or set GEM_HOST_OTP_CODE for this run only (do not save OTP in .env)." -ForegroundColor DarkGray
        $dockerArgs += "-i", "-t"
    }
    $dockerArgs += "-e", "GEM_HOST_API_KEY"
    if (-not [string]::IsNullOrEmpty($env:GEM_HOST_OTP_CODE)) {
        $dockerArgs += "-e", "GEM_HOST_OTP_CODE"
    }
    $dockerArgs += "-v", "${Root}:/gem", "-w", "/gem", "ruby:3.2-slim", "bash", "-c", $bashCmd
    & docker @dockerArgs
}
