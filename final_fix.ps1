# ---------------------------------------------------------
# ABDIFY ULTIMATE MASTER INSTALLER V5.0
# ---------------------------------------------------------
$ErrorActionPreference = 'Stop'

function Write-Header {
    [Console]::Clear()
    Write-Host '---------------------------------------------------' -ForegroundColor 'Cyan'
    Write-Host '    A  B  D  I  F  Y    W  O  R  L  D' -ForegroundColor 'Cyan'
    Write-Host '      Master Analysis Release - Version 5.0' -ForegroundColor 'White'
    Write-Host '---------------------------------------------------' -ForegroundColor 'Cyan'
}

Write-Header

# 1. KILL SPOTIFY
Write-Host 'ABDIFY SETUP: Terminating Spotify and clearing background tasks...' -ForegroundColor Cyan
Stop-Process -Name 'Spotify' -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 2

# 2. TOTAL WIPEOUT (Delete ALL existing Abdify/Spicetify remnants)
Write-Host 'ABDIFY CLEAN: Wiping ALL old configurations and cache...' -ForegroundColor Yellow
$targets = @(
    "$env:APPDATA\spicetify",
    "$env:LOCALAPPDATA\spicetify",
    "$env:APPDATA\Abdify_Config",
    "$env:LOCALAPPDATA\Abdify",
    "$env:LOCALAPPDATA\Spotify\Storage",
    "$env:LOCALAPPDATA\Spotify\Data",
    "$env:LOCALAPPDATA\Spotify\Browser",
    "$env:LOCALAPPDATA\Spotify\Users"
)

foreach ($t in $targets) {
    if (Test-Path $t) {
        Remove-Item $t -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 3. REPAIR SPOTIFY CORE
$sp_path = "$env:APPDATA\Spotify"
$xpui_spa = "$sp_path\Apps\xpui.spa"
$xpui_bak = "$sp_path\Apps\xpui.spa.bak"

if (Test-Path $xpui_bak) {
    Write-Host 'ABDIFY REPAIR: Restoring original Spotify files...' -ForegroundColor Green
    Remove-Item $xpui_spa -Force -ErrorAction SilentlyContinue
    Copy-Item $xpui_bak $xpui_spa -Force
}

# 4. DOWNLOAD MASTER ASSETS (V5.0)
$v = Get-Random
$raw = 'https://raw.githubusercontent.com/abdifahadi/Abdify/main'
$conf = "$env:APPDATA\Abdify_Config"
$theme = "$conf\Themes\Abdi"
mkdir -Path $theme -Force | Out-Null

Write-Host 'ABDIFY THEME: Catching Master Version 5.0...' -ForegroundColor Cyan
Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$theme\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$theme\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$theme\theme.js" -UseBasicParsing

# 5. FRESH INJECT
$eng = "$env:LOCALAPPDATA\Abdify"
mkdir $eng | Out-Null
Invoke-WebRequest -Uri 'https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip' -OutFile "$eng\core.zip" -UseBasicParsing
Expand-Archive -Path "$eng\core.zip" -DestinationPath $eng -Force

$env:SPICETIFY_CONFIG = $conf
$bin = "$eng\spicetify.exe"

Write-Host 'ABDIFY PATCH: Injecting Master Fixes...' -ForegroundColor Yellow
Start-Process $bin -ArgumentList 'config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 custom_apps "" extensions ""' -WindowStyle Hidden -Wait
Start-Process $bin -ArgumentList 'backup apply' -WindowStyle Hidden -Wait

Write-Host '---------------------------------------------------' -ForegroundColor Green
Write-Host '   ABDIFY MASTER 5.0 ACTIVATED!   ' -ForegroundColor Green
Write-Host '---------------------------------------------------' -ForegroundColor Green

Start-Process "$sp_path\Spotify.exe"