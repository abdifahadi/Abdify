# ---------------------------------------------------------------------------------
# ABDIFY RECOVERY & INSTALLER (V3.5 - Emergency Fix)
# ---------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Header {
    [Console]::Clear()
    Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
    Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
    Write-Host "      Emergency Fix Release 3.5" -ForegroundColor "White"
    Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
}

Write-Header

# INITIALIZING
Write-Host "ABDIFY SETUP: Closing Spotify and repairing core..." -ForegroundColor Cyan
Stop-Process -Name "Spotify" -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 1

$sp_path = "$env:APPDATA\Spotify"
$xpui_spa = "$sp_path\Apps\xpui.spa"
$xpui_bak = "$sp_path\Apps\xpui.spa.bak"

# 1. DEEP REPAIR (Remove corrupt patched files)
if (Test-Path $xpui_bak) {
    Write-Host "ABDIFY REPAIR: Restoring original Spotify assets..." -ForegroundColor Green
    Remove-Item $xpui_spa -Force -ErrorAction SilentlyContinue
    Copy-Item $xpui_bak $xpui_spa -Force
}

# 2. CLEAR CACHE (Crucial for UI updates)
Write-Host "ABDIFY CLEAN: Cleaning UI cache and temp files..." -ForegroundColor Cyan
Remove-Item "$env:LOCALAPPDATA\Spotify\Storage" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Spotify\Data" -Recurse -Force -ErrorAction SilentlyContinue

# 3. DEPLOY ENGINE
$engine_dir = "$env:LOCALAPPDATA\Abdify"
if (Test-Path $engine_dir) { Remove-Item -Recurse -Force $engine_dir }
mkdir $engine_dir | Out-Null
Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$engine_dir\core.zip" -UseBasicParsing
Expand-Archive -Path "$engine_dir\core.zip" -DestinationPath $engine_dir -Force

# 4. DOWNLOAD THEME (With aggressive cache busting)
$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
$theme_target = "$env:APPDATA\Abdify_Config\Themes\Abdi"
if (!(Test-Path $theme_target)) { mkdir -Path $theme_target -Force | Out-Null }

Write-Host "ABDIFY THEME: Downloading fresh assets (V3.5)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$theme_target\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$theme_target\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$theme_target\theme.js" -UseBasicParsing

# 5. APPLY SILENTLY
$env:SPICETIFY_CONFIG = "$env:APPDATA\Abdify_Config"
$bin = "$engine_dir\spicetify.exe"
& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 | Out-Null
& $bin backup | Out-Null
& $bin apply | Out-Null

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY RECOVERED & UPDATED! (V3.5)   " -ForegroundColor Green
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$sp_path\Spotify.exe"
