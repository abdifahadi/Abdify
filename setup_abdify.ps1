# ABDIFY REPAIR AND CLEANER V3.9 - ULTRA STABLE
# ---------------------------------------------------------
$ErrorActionPreference = 'Stop'

function Write-Header {
    [Console]::Clear()
    Write-Host '---------------------------------------------------' -ForegroundColor 'Cyan'
    Write-Host '    A  B  D  I  F  Y    W  O  R  L  D' -ForegroundColor 'Cyan'
    Write-Host '      Deep Analysis Fix - Version 3.9' -ForegroundColor 'White'
    Write-Host '---------------------------------------------------' -ForegroundColor 'Cyan'
}

Write-Header

# 1. CLOSE SPOTIFY
Write-Host 'ABDIFY SETUP: Closing Spotify and cleaning memory...' -ForegroundColor Cyan
Stop-Process -Name 'Spotify' -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 2

# 2. TOTAL CACHE PURGE
Write-Host 'ABDIFY CLEAN: Wiping all UI storage and browser cache...' -ForegroundColor Yellow
$local = "$env:LOCALAPPDATA\Spotify"
if (Test-Path "$local\Storage") { Remove-Item "$local\Storage" -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "$local\Data") { Remove-Item "$local\Data" -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "$local\Browser") { Remove-Item "$local\Browser" -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "$local\Users") { Remove-Item "$local\Users" -Recurse -Force -ErrorAction SilentlyContinue }

# 3. REPAIR XPUI
$app_path = "$env:APPDATA\Spotify"
$xpui_spa = "$app_path\Apps\xpui.spa"
$xpui_bak = "$app_path\Apps\xpui.spa.bak"

if (Test-Path $xpui_bak) {
    Write-Host 'ABDIFY REPAIR: Restoring original Spotify files...' -ForegroundColor Green
    Remove-Item $xpui_spa -Force -ErrorAction SilentlyContinue
    Copy-Item $xpui_bak $xpui_spa -Force
}

# 4. DOWNLOAD THEME
$v = Get-Random
$raw_url = 'https://raw.githubusercontent.com/abdifahadi/Abdify/main'
$conf_path = "$env:APPDATA\Abdify_Config"
$theme_path = "$conf_path\Themes\Abdi"

if (Test-Path $theme_path) { Remove-Item -Recurse -Force $theme_path }
mkdir -Path $theme_path -Force | Out-Null

Write-Host 'ABDIFY THEME: Downloading V3.9 assets...' -ForegroundColor Cyan
$themeBase = "$raw_url/Themes/Abdi"
Invoke-WebRequest -Uri "$themeBase/color.ini?v=$v" -OutFile "$theme_path\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$themeBase/user.css?v=$v" -OutFile "$theme_path\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$themeBase/theme.js?v=$v" -OutFile "$theme_path\theme.js" -UseBasicParsing

# 5. INJECT THEME
$eng_dir = "$env:LOCALAPPDATA\Abdify"
if (!(Test-Path $eng_dir)) { 
    mkdir $eng_dir | Out-Null
    Invoke-WebRequest -Uri 'https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip' -OutFile "$eng_dir\core.zip" -UseBasicParsing
    Expand-Archive -Path "$eng_dir\core.zip" -DestinationPath $eng_dir -Force
}

$env:SPICETIFY_CONFIG = $conf_path
$bin_exe = "$eng_dir\spicetify.exe"

# Use explicit Shell execution to avoid ampersand issues in loader
Write-Host 'ABDIFY PATCH: Injecting theme assets...' -ForegroundColor Yellow
Start-Process $bin_exe -ArgumentList 'config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1' -WindowStyle Hidden -Wait
Start-Process $bin_exe -ArgumentList 'backup apply' -WindowStyle Hidden -Wait

Write-Host '---------------------------------------------------' -ForegroundColor Green
Write-Host '   ABDIFY ACTIVATED SUCCESSFULLY! (V3.9) ' -ForegroundColor Green
Write-Host '---------------------------------------------------' -ForegroundColor Green

Start-Process "$app_path\Spotify.exe"
