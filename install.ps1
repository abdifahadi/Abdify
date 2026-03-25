# --- Abdify Theme Ultimate [NON-STOP] Installer ---
# Version: 2.3.1 (Zero-Dependency)
param ( [string] $version )

$RepoBase = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
$SpotifyRoot = "$env:APPDATA\Spotify\Apps"
$AppPath = Join-Path $SpotifyRoot "xpui"
$SpaPath = Join-Path $SpotifyRoot "xpui.spa"

Write-Host "Initializing Abdify v2.3.1 [Standalone Patch]..." -ForegroundColor Cyan

# 1. Ensure Files are Unlocked
if (!(Test-Path $AppPath)) {
    if (Test-Path $SpaPath) {
        Write-Host "Unlocking Spotify files..." -ForegroundColor Yellow
        $tempZip = Join-Path $SpotifyRoot "xpui.zip"
        Copy-Item $SpaPath $tempZip -Force
        Expand-Archive -Path $tempZip -DestinationPath $AppPath -Force
        Remove-Item $tempZip -Force
        Move-Item $SpaPath "$SpaPath.bak" -Force
    } else {
        Write-Host "Error: Spotify not found." -ForegroundColor Red
        return
    }
}

# 2. Download Final Component
Write-Host "Downloading Abdify v2.3.1 Core..." -ForegroundColor Yellow
$targetFile = Join-Path $AppPath "abdify.js"
Invoke-WebRequest -Uri "$RepoBase/abdify.js" -OutFile $targetFile -UseBasicParsing -Headers @{"Cache-Control"="no-cache"}
Write-Host "Abdify core downloaded." -ForegroundColor Green

# 3. Ultimate Patching (index.html)
$htmlPath = Join-Path $AppPath "index.html"
$html = Get-Content $htmlPath -Raw

# Clean ALL previous script tags and engines
$html = $html -replace "<script src='abdify.js'.*?></script>", ""
$html = $html -replace "<script src='abdi_engine.js'.*?></script>", ""
$html = $html -replace "<script src='helper/.*?js'.*?></script>", ""

# Inject ONLY our Zero-Dependency abdify.js
if ($html -notmatch "abdify.js") {
    $html = $html.Replace("</body>", "<script src='abdify.js' defer></script></body>")
}

Set-Content $htmlPath $html

Write-Host "`nSUCCESS: Abdify v2.3.1 is now running Standalone!" -ForegroundColor Green
Write-Host "Please restart Spotify." -ForegroundColor White
