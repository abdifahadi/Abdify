# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE MASTER INSTALLER V7.5 (Super-Fast & Professional)
# ---------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
Write-Host "      Ultra-Fast Professional Fix - V7.5" -ForegroundColor "White"
Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"

# 1. OPTIMIZED PREPARATION
Write-Host "ABDIFY SETUP: Closing Spotify..." -ForegroundColor Cyan
# Silent and fast termination
Get-Process Spotify -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 500

# 2. TARGETED CACHE CLEANUP (Faster than full wipe)
$local = "$env:LOCALAPPDATA\Spotify"
Write-Host "ABDIFY CLEAN: Optimization in progress..." -ForegroundColor Yellow
@("Storage", "Browser", "Data") | ForEach-Object {
    $target = "$local\$_"
    if (Test-Path $target) { Remove-Item $target -Recurse -Force -ErrorAction SilentlyContinue }
}

# 3. DIRECTORY & ASSET FETCH
$conf = "$env:APPDATA\Abdify_Config"
$theme = "$conf\Themes\Abdi"
if (!(Test-Path $theme)) { mkdir $theme -Force | Out-Null }

$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
Write-Host "ABDIFY THEME: Fetching high-speed assets..." -ForegroundColor Cyan

# Parallel-like download using Job for speed (Optional, but keeping simple for reliability)
Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$theme\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$theme\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$theme\theme.js" -UseBasicParsing

# 4. ENGINE VERIFICATION
$eng = "$env:LOCALAPPDATA\Abdify"
if (!(Test-Path $eng\spicetify.exe)) { 
    Write-Host "ABDIFY CORE: Installing engine (One-time setup)..." -ForegroundColor Yellow
    mkdir $eng -Force | Out-Null
    Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$eng\core.zip" -UseBasicParsing
    Expand-Archive -Path "$eng\core.zip" -DestinationPath $eng -Force
}

$env:SPICETIFY_CONFIG = $conf
$bin = "$eng\spicetify.exe"

# 5. PROFESSIONAL SPEED PATCHING
Write-Host "ABDIFY PATCH: Applying theme visually..." -ForegroundColor Cyan

# Using & for direct execution to show Spicetify's own progress bars
& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 | Out-Null
& $bin backup apply

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY ACTIVATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$env:APPDATA\Spotify\Spotify.exe"