# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE MASTER INSTALLER V7.0 (Professional & Deep Cleanup)
# ---------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
Write-Host "      Professional Fix Release - Version 7.0" -ForegroundColor "White"
Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"

# 1. PREPARATION
Write-Host "ABDIFY SETUP: Closing Spotify and cleaning workspace..." -ForegroundColor Cyan
Stop-Process -Name "Spotify" -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 2

# 2. DEEP DIVE CLEANUP (Fixing the caching issue)
$local = "$env:LOCALAPPDATA\Spotify"
Write-Host "ABDIFY CLEAN: Wiping old UI data and background cache..." -ForegroundColor Yellow
@("Storage", "Data", "Browser", "Users") | ForEach-Object {
    $target = "$local\$_"
    if (Test-Path $target) { Remove-Item $target -Recurse -Force -ErrorAction SilentlyContinue }
}

# Also clear Spicetify's internal extraction cache
$sp_extracted = "$env:APPDATA\spicetify\Extracted"
if (Test-Path $sp_extracted) { Remove-Item $sp_extracted -Recurse -Force -ErrorAction SilentlyContinue }

# 3. DIRECTORY SETUP
$conf = "$env:APPDATA\Abdify_Config"
$theme = "$conf\Themes\Abdi"
if (!(Test-Path $theme)) { mkdir $theme -Force | Out-Null }

# 4. DOWNLOAD VERIFIED ASSETS
$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
Write-Host "ABDIFY THEME: Downloading latest master files..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$theme\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$theme\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$theme\theme.js" -UseBasicParsing

# 5. INJECTION ENGINE
$eng = "$env:LOCALAPPDATA\Abdify"
if (!(Test-Path $eng\spicetify.exe)) { 
    mkdir $eng -Force | Out-Null
    Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$eng\core.zip" -UseBasicParsing
    Expand-Archive -Path "$eng\core.zip" -DestinationPath $eng -Force
}

$env:SPICETIFY_CONFIG = $conf
$bin = "$eng\spicetify.exe"

# 6. PROFESSIONAL PATCHING (Showing real progress)
Write-Host "ABDIFY PATCH: Initializing injection engine..." -ForegroundColor Yellow
# First, restore to a clean Spotify state to kill any old theme remnants
& $bin restore | Out-Null 2>&1

Write-Host "ABDIFY PATCH: Applying theme with real-time feedback..." -ForegroundColor Cyan
# Configure and Apply (Visible progress)
& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1
& $bin backup apply

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY INSTALLED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "   Version: Professional Release 7.0" -ForegroundColor White
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$env:APPDATA\Spotify\Spotify.exe"