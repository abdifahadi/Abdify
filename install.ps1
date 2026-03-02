# ---------------------------------------------------------------------------------
# ABDIFY ULTIMATE MASTER INSTALLER V6.0 (Stable & Professional)
# ---------------------------------------------------------------------------------
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
Write-Host "      Official Official Release - Version 6.0" -ForegroundColor "White"
Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"

# 1. PREPARATION
Write-Host "ABDIFY SETUP: Closing Spotify and cleaning workspace..." -ForegroundColor Cyan
Stop-Process -Name "Spotify" -ErrorAction SilentlyContinue 
Start-Sleep -Seconds 2

# 2. CACHE CLEANUP
$local = "$env:LOCALAPPDATA\Spotify"
Write-Host "ABDIFY CLEAN: Clearing old UI data..." -ForegroundColor Yellow
@("Storage", "Data", "Browser", "Users") | ForEach-Object {
    if (Test-Path "$local\") { Remove-Item "$local\" -Recurse -Force -ErrorAction SilentlyContinue }
}

# 3. DIRECTORY SETUP
$conf = "$env:APPDATA\Abdify_Config"
$theme = "$conf\Themes\Abdi"
if (!(Test-Path $theme)) { mkdir $theme -Force | Out-Null }

# 4. DOWNLOAD VERIFIED ASSETS
$v = Get-Random
$raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
Write-Host "ABDIFY THEME: Downloading verified theme files..." -ForegroundColor Cyan
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

Write-Host "ABDIFY PATCH: Applying theme visually..." -ForegroundColor Yellow
Start-Process $bin -ArgumentList "config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1" -WindowStyle Hidden -Wait
Start-Process $bin -ArgumentList "backup apply" -WindowStyle Hidden -Wait

Write-Host "---------------------------------------------------" -ForegroundColor Green
Write-Host "   ABDIFY INSTALLED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "   Version: Official Release 6.0" -ForegroundColor White
Write-Host "---------------------------------------------------" -ForegroundColor Green

Start-Process "$env:APPDATA\Spotify\Spotify.exe"