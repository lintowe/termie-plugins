# build every plugin in this repo, pack dist/<id>-<version>.zip (the entry binary
# plus its plugin.json), and regenerate index.json — the catalog termie's in-app
# store fetches. run from anywhere:  pwsh scripts/build-zips.ps1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$dist = Join-Path $root 'dist'
$rawBase = 'https://raw.githubusercontent.com/lintowe/termie-plugins/main/dist'

New-Item -ItemType Directory -Force $dist | Out-Null
# drop stale zips so renamed/removed versions don't linger
Get-ChildItem $dist -Filter *.zip -ErrorAction SilentlyContinue | Remove-Item -Force

$entries = @()
# any directory holding a plugin.json is a plugin
$plugins = Get-ChildItem $root -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'plugin.json') } |
    Sort-Object Name
foreach ($p in $plugins) {
    $m = Get-Content (Join-Path $p.FullName 'plugin.json') -Raw | ConvertFrom-Json
    Write-Host "==> $($m.id) $($m.version)" -ForegroundColor Cyan

    # build (rust plugins ship a Cargo.toml; add other toolchains here as needed)
    if (Test-Path (Join-Path $p.FullName 'Cargo.toml')) {
        Push-Location $p.FullName
        try { & cargo build --release } finally { Pop-Location }
        if ($LASTEXITCODE -ne 0) { throw "$($m.id): cargo build failed" }
    }
    $exe = Join-Path $p.FullName "target\release\$($m.entry.cmd)"
    if (-not (Test-Path $exe)) { throw "$($m.id): built binary not found at $exe" }

    # the installer expects plugin.json + the entry binary flat at the zip root
    $stage = Join-Path $env:TEMP "termie-plugin-$($m.id)"
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
    New-Item -ItemType Directory -Force $stage | Out-Null
    Copy-Item (Join-Path $p.FullName 'plugin.json') $stage
    Copy-Item $exe $stage
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath (Join-Path $dist "$($m.id)-$($m.version).zip") -Force
    Remove-Item $stage -Recurse -Force

    $entries += [ordered]@{
        id          = $m.id
        name        = $m.name
        version     = $m.version
        description = $m.description
        url         = "$rawBase/$($m.id)-$($m.version).zip"
        permissions = @($m.permissions)
    }
}

$index = [ordered]@{ plugins = @($entries) }
($index | ConvertTo-Json -Depth 6) | Set-Content (Join-Path $root 'index.json') -Encoding utf8
Write-Host "==> wrote index.json ($($entries.Count) plugins) + dist/*.zip" -ForegroundColor Green
