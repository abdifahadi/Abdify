# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE MASTER INSTALLER V10.0 (Ultimate Freeze & Clean)
# ---------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
Write-Host "      Ultimate Stable Release - Version 10.0" -ForegroundColor "White"
Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"

# 1. STOP SPOTIFY GENTLY BUT FIRMLY
Write-Host "ABDIFY SETUP: Closing Spotify and Update Services..." -ForegroundColor Cyan
Get-Process Spotify -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# 2. BLOCK SPOTIFY AUTO-UPDATES (Professional Fix)
Write-Host "ABDIFY FREEZE: Disabling Spotify auto-update engine..." -ForegroundColor Yellow
$localappdata = "$env:LOCALAPPDATA\Spotify"

# Create dummy update files to block Spotify's update downloader
$update_files = @(
    "$localappdata\Update",
    "$localappdata\Spotify_new.exe",
    "$localappdata\Spotify_new.exe.sig"
)

ForEach ($file in $update_files) {
    if (Test-Path $file) { Remove-Item $file -Recurse -Force -ErrorAction SilentlyContinue }
    # Create empty file and set to Read-Only
    New-Item -Path $file -ItemType File -Force | Out-Null
    Set-ItemProperty -Path $file -Name Attributes -Value ReadOnly
}

# 3. DEEP CACHE PURGE
Write-Host "ABDIFY CLEAN: Wiping obsolete UI cache for fresh start..." -ForegroundColor Yellow
@("Storage", "Browser", "Data", "Users") | ForEach-Object {
    $target = "$localappdata\$_"
    if (Test-Path $target) { Remove-Item $target -Recurse -Force -ErrorAction SilentlyContinue }
}

# 4. DIRECTORY & ASSET FETCH
$conf = "$env:APPDATA\Abdify_Config"
$theme = "$conf\Themes\Abdi"
if (!(Test-Path $theme)) { mkdir $theme -Force | Out-Null }

$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
Write-Host "ABDIFY THEME: Downloading latest master assets..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "$raw/Themes/Abdi/color.ini?v=$v" -OutFile "$theme\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/user.css?v=$v" -OutFile "$theme\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$raw/Themes/Abdi/theme.js?v=$v" -OutFile "$theme\theme.js" -UseBasicParsing

# 5. INJECTION ENGINE
$eng = "$env:LOCALAPPDATA\Abdify"
if (!(Test-Path $eng\spicetify.exe)) { 
    Write-Host "ABDIFY CORE: Setting up patching engine..." -ForegroundColor Yellow
    mkdir $eng -Force | Out-Null
    Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$eng\core.zip" -UseBasicParsing
    Expand-Archive -Path "$eng\core.zip" -DestinationPath $eng -Force
}

$env:SPICETIFY_CONFIG = $conf
$bin = "$eng\spicetify.exe"

# 6. MASTER PATCH (Clean Overwrite)
Write-Host "ABDIFY PATCH: Forcing clean theme injection..." -ForegroundColor Red
& $bin restore | Out-Null 2>&1
& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 | Out-Null
& $bin backup apply

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY 10.0 ACTIVATED & LOCKED!" -ForegroundColor Green
Write-Host "   Auto-updates have been disabled." -ForegroundColor White
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$env:APPDATA\Spotify\Spotify.exe"