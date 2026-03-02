# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE FINAL FIX V4.5
# ---------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
Write-Host "      Deep Analysis Fix - Version 4.5" -ForegroundColor "White"
Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"

# 1. KILL SPOTIFY
Write-Host "ABDIFY SETUP: Closing Spotify and cleaning workspace..." -ForegroundColor Cyan
Stop-Process -Name "Spotify" -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 2

# 2. DEEP CACHE PURGE
Write-Host "ABDIFY CLEAN: Wiping all UI storage and temp folders..." -ForegroundColor Yellow
$local = "$env:LOCALAPPDATA\Spotify"
$folders = @("Storage", "Data", "Browser", "Users")
foreach ($f in $folders) {
    if (Test-Path "$local\$f") {
        Remove-Item "$local\$f" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 3. REPAIR XPUI (Clean Start)
$sp_path = "$env:APPDATA\Spotify"
$xpui_spa = "$sp_path\Apps\xpui.spa"
$xpui_bak = "$sp_path\Apps\xpui.spa.bak"

if (Test-Path $xpui_bak) {
    Write-Host "ABDIFY REPAIR: Restoring original Spotify assets..." -ForegroundColor Green
    Remove-Item $xpui_spa -Force -ErrorAction SilentlyContinue
    Copy-Item $xpui_bak $xpui_spa -Force
}

# 4. DOWNLOAD FRESH (V4.5)
$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
$conf_path = "$env:APPDATA\Abdify_Config"
$theme_target = "$conf_path\Themes\Abdi"

if (Test-Path $theme_target) { Remove-Item -Recurse -Force $theme_target }
mkdir -Path $theme_target -Force | Out-Null

Write-Host "ABDIFY THEME: Downloading V4.5 assets..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$theme_target\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$theme_target\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$theme_target\theme.js" -UseBasicParsing

# 5. INJECT (Using Engine)
$engine_dir = "$env:LOCALAPPDATA\Abdify"
if (!(Test-Path $engine_dir)) { 
    mkdir $engine_dir | Out-Null
    Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$engine_dir\core.zip" -UseBasicParsing
    Expand-Archive -Path "$engine_dir\core.zip" -DestinationPath $engine_dir -Force
}

$env:SPICETIFY_CONFIG = $conf_path
$bin = "$engine_dir\spicetify.exe"

Write-Host "ABDIFY PATCH: Injecting final fix..." -ForegroundColor Yellow
# Using Start-Process to avoid terminal issues
Start-Process $bin -ArgumentList "config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1" -WindowStyle Hidden -Wait
Start-Process $bin -ArgumentList "backup apply" -WindowStyle Hidden -Wait

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY ACTIVATED! (V4.5)   " -ForegroundColor Green
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$sp_path\Spotify.exe"