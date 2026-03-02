# ABDIFY ULTIMATE CLEANER & INSTALLER (V3.6)
$ErrorActionPreference = "Stop"

Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
Write-Host "    A  B  D  I  F  Y    W  O  R  L  D    (V3.6)" -ForegroundColor "Cyan"
Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"

# 1. KILL & WIPE CACHE
Write-Host "Cleaning Spotify workspace..." -ForegroundColor Yellow
Stop-Process -Name "Spotify" -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 2

$spotify_local = "$env:LOCALAPPDATA\Spotify"
Remove-Item "$spotify_local\Storage" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$spotify_local\Data" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$spotify_local\Browser" -Recurse -Force -ErrorAction SilentlyContinue

# 2. RESTORE ORIGINAL (Absolute Clean Start)
$sp_path = "$env:APPDATA\Spotify"
$xpui_spa = "$sp_path\Apps\xpui.spa"
$xpui_bak = "$sp_path\Apps\xpui.spa.bak"

if (Test-Path $xpui_bak) {
    Write-Host "Resetting Spotify to factory state..." -ForegroundColor Cyan
    Remove-Item $xpui_spa -Force -ErrorAction SilentlyContinue
    Copy-Item $xpui_bak $xpui_spa -Force
}

# 3. FRESH ENGINE & CONFIG
$engine_dir = "$env:LOCALAPPDATA\Abdify"
$config_dir = "$env:APPDATA\Abdify_Config"
Remove-Item $engine_dir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $config_dir -Recurse -Force -ErrorAction SilentlyContinue

mkdir $engine_dir | Out-Null
mkdir -Path "$config_dir\Themes\Abdi" -Force | Out-Null

# 4. DOWNLOAD FRESH (No Cache)
$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"

Write-Host "Fetching high-performance theme files..." -ForegroundColor Green
Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$engine_dir\core.zip" -UseBasicParsing
Expand-Archive -Path "$engine_dir\core.zip" -DestinationPath $engine_dir -Force

Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$config_dir\Themes\Abdi\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$config_dir\Themes\Abdi\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$config_dir\Themes\Abdi\theme.js" -UseBasicParsing

# 5. HARD APPLY
$env:SPICETIFY_CONFIG = $config_dir
$bin = "$engine_dir\spicetify.exe"
& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 | Out-Null
& $bin backup apply | Out-Null

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY ACTIVATED! (V3.6)   " -ForegroundColor Green
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$sp_path\Spotify.exe"
