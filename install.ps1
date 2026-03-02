# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE MASTER INSTALLER V9.0 (Professional & Deep Reset)
# ---------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
Write-Host "      Master Official Release - Version 9.0" -ForegroundColor "White"
Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"

# 1. STOP SPOTIFY
Write-Host "ABDIFY SETUP: Closing Spotify..." -ForegroundColor Cyan
Get-Process Spotify -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# 2. CACHE WIPE (Critical for Updates)
$local = "$env:LOCALAPPDATA\Spotify"
Write-Host "ABDIFY CLEAN: Wiping obsolete UI cache..." -ForegroundColor Yellow
@("Storage", "Browser", "Data", "Users") | ForEach-Object {
    $target = "$local\$_"
    if (Test-Path $target) { Remove-Item $target -Recurse -Force -ErrorAction SilentlyContinue }
}

# 3. DIRECTORY SETUP
$conf = "$env:APPDATA\Abdify_Config"
$theme = "$conf\Themes\Abdi"
if (!(Test-Path $theme)) { mkdir $theme -Force | Out-Null }

# 4. DOWNLOAD VERIFIED ASSETS
$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
Write-Host "ABDIFY THEME: Synchronizing with GitHub Master..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$theme\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$theme\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$theme\theme.js" -UseBasicParsing

# 5. INJECTION ENGINE
$eng = "$env:LOCALAPPDATA\Abdify"
if (!(Test-Path $eng\spicetify.exe)) { 
    Write-Host "ABDIFY CORE: Downloading Injection Engine..." -ForegroundColor Yellow
    mkdir $eng -Force | Out-Null
    Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$eng\core.zip" -UseBasicParsing
    Expand-Archive -Path "$eng\core.zip" -DestinationPath $eng -Force
}

$env:SPICETIFY_CONFIG = $conf
$bin = "$eng\spicetify.exe"

# 6. PROFESSIONAL DEEP RE-PATCH
Write-Host "ABDIFY PATCH: Forcing clean state restoration..." -ForegroundColor Red
& $bin restore | Out-Null 2>&1

Write-Host "ABDIFY PATCH: Injecting latest Abdify structures..." -ForegroundColor Cyan
& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 | Out-Null
& $bin backup apply

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY 9.0 SUCCESSFULLY ACTIVATED!" -ForegroundColor Green
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$env:APPDATA\Spotify\Spotify.exe"