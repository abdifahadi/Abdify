# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE REPAIR AND CLEANER V3.7
# ---------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Header {
    [Console]::Clear()
    Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
    Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
    Write-Host "      Deep Analysis Fix - Version 3.7" -ForegroundColor "White"
    Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
}

Write-Header

# 1. KILL SPOTIFY
Write-Host "ABDIFY SETUP: Closing Spotify and cleaning memory..." -ForegroundColor Cyan
Stop-Process -Name "Spotify" -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 2

# 2. TOTAL CACHE PURGE
Write-Host "ABDIFY CLEAN: Wiping all UI storage and browser cache..." -ForegroundColor Yellow
$local = "$env:LOCALAPPDATA\Spotify"
$folders = @("Storage", "Data", "Browser", "Users")
foreach ($f in $folders) {
    if (Test-Path "$local\$f") {
        Remove-Item "$local\$f" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 3. REPAIR XPUI
$sp_path = "$env:APPDATA\Spotify"
$xpui_spa = "$sp_path\Apps\xpui.spa"
$xpui_bak = "$sp_path\Apps\xpui.spa.bak"

if (Test-Path $xpui_bak) {
    Write-Host "ABDIFY REPAIR: Restoring original Spotify files..." -ForegroundColor Green
    Remove-Item $xpui_spa -Force -ErrorAction SilentlyContinue
    Copy-Item $xpui_bak $xpui_spa -Force
}

# 4. DOWNLOAD FRESH (V3.7)
$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
$config_dir = "$env:APPDATA\Abdify_Config"
$theme_target = "$config_dir\Themes\Abdi"

if (Test-Path $theme_target) { Remove-Item -Recurse -Force $theme_target }
mkdir -Path $theme_target -Force | Out-Null

Write-Host "ABDIFY THEME: Downloading V3.7 assets..." -ForegroundColor Cyan
$themeBase = "$raw/Themes/Abdi"
Invoke-WebRequest -Uri "$themeBase/color.ini?v=$v" -OutFile "$theme_target\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$themeBase/user.css?v=$v" -OutFile "$theme_target\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$themeBase/theme.js?v=$v" -OutFile "$theme_target\theme.js" -UseBasicParsing

# 5. INJECT (V3.7)
$engine_dir = "$env:LOCALAPPDATA\Abdify"
if (!(Test-Path $engine_dir)) { 
    mkdir $engine_dir | Out-Null
    Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$engine_dir\core.zip" -UseBasicParsing
    Expand-Archive -Path "$engine_dir\core.zip" -DestinationPath $engine_dir -Force
}

$env:SPICETIFY_CONFIG = $config_dir
$bin = "$engine_dir\spicetify.exe"
& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 | Out-Null
& $bin backup apply | Out-Null

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY V3.7 INSTALLED SUCCESSFULLY!   " -ForegroundColor Green
Write-Host "   Developer: Abdi Fahadi               " -ForegroundColor "Cyan"
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$sp_path\Spotify.exe"
