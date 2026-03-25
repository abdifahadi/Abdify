# --- Abdify Theme Ultimate Standalone Installer ---
# Version: 2.3 (Zero-Dependency)
param ( [string] $version )

$RepoBase = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
$SpotifyRoot = "$env:APPDATA\Spotify\Apps"
$AppPath = Join-Path $SpotifyRoot "xpui"
$SpaPath = Join-Path $SpotifyRoot "xpui.spa"

Write-Host "Initializing Abdify v2.3..." -ForegroundColor Cyan

# 1. Handle Locked Files (Extraction Logic)
if (!(Test-Path $AppPath)) {
    if (Test-Path $SpaPath) {
        Write-Host "Spotify files are locked (.spa). Unlocking now..." -ForegroundColor Yellow
        $tempZip = Join-Path $SpotifyRoot "xpui.zip"
        Copy-Item $SpaPath $tempZip -Force
        Expand-Archive -Path $tempZip -DestinationPath $AppPath -Force
        Remove-Item $tempZip -Force
        # Rename original spa to prevent Spotify from ignoring our folder
        Move-Item $SpaPath "$SpaPath.bak" -Force
        Write-Host "Successfully unlocked Spotify interface." -ForegroundColor Green
    } else {
        Write-Host "Error: Spotify installation not found." -ForegroundColor Red
        return
    }
}

# 2. Downloading Standalone Components from GitHub
Write-Host "Fetching Abdify v2.3 Core..." -ForegroundColor Yellow
$files = @("abdify.js", "user.css")

foreach ($file in $files) {
    $targetFile = Join-Path $AppPath $file
    $downloadUrl = "$RepoBase/$file"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $targetFile -UseBasicParsing
}

# 3. Patching Host Interface (index.html)
Write-Host "Patching Interface Shell..." -ForegroundColor Yellow
$htmlPath = Join-Path $AppPath "index.html"
$html = Get-Content $htmlPath -Raw

# Remove all traces of previous engines/themes
$html = $html -replace "<script src='abdify.js'.*?></script>", ""
$html = $html -replace "<script src='abdi_engine.js'.*?></script>", ""
$html = $html -replace "<script src='helper/.*?js'.*?></script>", ""

# Clean injection of the Standalone theme
if ($html -notmatch "abdify.js") {
    $html = $html.Replace("</body>", "<script src='abdify.js' defer></script></body>")
}

Set-Content $htmlPath $html

Write-Host "`nAbdify v2.3 was successfully installed!" -ForegroundColor Green
Write-Host "The theme is now 100% STANDALONE. No Spicetify required." -ForegroundColor White
Write-Host "Please restart Spotify now." -ForegroundColor Gray
