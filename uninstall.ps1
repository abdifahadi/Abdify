# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE UNINSTALLER V1.0 (Professional Recovery)
# ---------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "---------------------------------------------------" -ForegroundColor "Red"
Write-Host "    A  B  D  I  F  Y    U  N  I  N  S  T  A  L  L" -ForegroundColor "Red"
Write-Host "---------------------------------------------------" -ForegroundColor "Red"

# 1. STOP SPOTIFY
Write-Host "ABDIFY SETUP: Closing Spotify..." -ForegroundColor Cyan
Get-Process Spotify -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# 2. RESTORE ORIGINAL SPOTIFY
$eng = "$env:LOCALAPPDATA\Abdify"
$conf = "$env:APPDATA\Abdify_Config"
$bin = "$eng\spicetify.exe"

if (Test-Path $bin) {
    Write-Host "ABDIFY RESTORE: Reverting custom patches..." -ForegroundColor Yellow
    $env:SPICETIFY_CONFIG = $conf
    & $bin restore | Out-Null
    Write-Host "ABDIFY RESTORE: Spotify has been returned to stock state." -ForegroundColor Green
}

# 3. CLEANUP CONFIGURATIONS
Write-Host "ABDIFY CLEAN: Removing configuration data..." -ForegroundColor Yellow
if (Test-Path $conf) { Remove-Item $conf -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY REMOVED! SPOTIFY IS NOW CLEAN." -ForegroundColor Green
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$env:APPDATA\Spotify\Spotify.exe"