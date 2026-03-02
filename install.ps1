# ---------------------------------------------------------------------------------
# ABDIFY WORLD (Official Safe Injector)
# ---------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Part ([string] $Text) { Write-Host $Text -NoNewline }
function Write-Emphasized ([string] $Text) { Write-Host $Text -NoNewLine -ForegroundColor "Cyan" }
function Write-Done { Write-Host " > " -NoNewline; Write-Host "DONE" -ForegroundColor "Green" }

function Write-Header {
    [Console]::Clear()
    # Simple ASCII that works everywhere
    Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
    Write-Host "    A  B  D  I  F  Y    W  O  R  L  D" -ForegroundColor "Cyan"
    Write-Host "      Premium Lightweight Spotify" -ForegroundColor "White"
    Write-Host "---------------------------------------------------" -ForegroundColor "Cyan"
}

Write-Header

# INITIALIZING
Write-Part "ABDIFY SETUP:  "; Write-Emphasized "Closing Spotify and repairing core..."
Stop-Process -Name "Spotify" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

$sp_path = "$env:APPDATA\Spotify"
$xpui_spa = "$sp_path\Apps\xpui.spa"
$xpui_bak = "$sp_path\Apps\xpui.spa.bak"

# Fix "Something went wrong" if it happened before
if (Test-Path $xpui_bak) {
    Remove-Item $xpui_spa -Force -ErrorAction SilentlyContinue
    Copy-Item $xpui_bak $xpui_spa -Force
}
Write-Done

# DEPLOY ENGINE (Silent)
Write-Part "ABDIFY ENGINE: "; Write-Emphasized "Initializing optimization engine..."
$engine_dir = "$env:LOCALAPPDATA\Abdify"
if (Test-Path $engine_dir) { Remove-Item -Recurse -Force $engine_dir }
mkdir $engine_dir | Out-Null

Invoke-WebRequest -Uri "https://github.com/spicetify/cli/releases/download/v2.42.13/spicetify-2.42.13-windows-x64.zip" -OutFile "$engine_dir\core.zip" -UseBasicParsing
Expand-Archive -Path "$engine_dir\core.zip" -DestinationPath $engine_dir -Force
Remove-Item "$engine_dir\core.zip"
Write-Done

# THEME DATA
Write-Part "ABDIFY THEME:  "; Write-Emphasized "Downloading Abdi design components..."
$config_path = "$env:APPDATA\Abdify_Config"
if (!(Test-Path $config_path)) { mkdir $config_path | Out-Null }
$theme_target = "$config_path\Themes\Abdi"
if (Test-Path $theme_target) { Remove-Item -Recurse -Force $theme_target }
mkdir -Path $theme_target -Force | Out-Null

$git_raw = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
Invoke-WebRequest -Uri "$git_raw/Themes/Abdi/color.ini" -OutFile "$theme_target\color.ini" -UseBasicParsing
Invoke-WebRequest -Uri "$git_raw/Themes/Abdi/user.css" -OutFile "$theme_target\user.css" -UseBasicParsing
Invoke-WebRequest -Uri "$git_raw/Themes/Abdi/theme.js" -OutFile "$theme_target\theme.js" -UseBasicParsing
Write-Done

# SILENT APPLY
Write-Part "ABDIFY PATCH:  "; Write-Emphasized "Applying custom theme silently..."
$env:SPICETIFY_CONFIG = $config_path
$bin = "$engine_dir\spicetify.exe"

& $bin config current_theme Abdi inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 custom_apps "" extensions "" | Out-Null
& $bin backup | Out-Null
& $bin apply | Out-Null
Write-Done

Write-Host "---------------------------------------------------" -ForegroundColor "Green"
Write-Host "   ABDIFY INSTALLED SUCCESSFULLY!   " -ForegroundColor "Green"
Write-Host "   Developer: Abdi Fahadi          " -ForegroundColor "Cyan"
Write-Host "---------------------------------------------------" -ForegroundColor "Green"

Start-Process "$sp_path\Spotify.exe"
