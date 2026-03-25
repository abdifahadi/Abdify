# --- Abdify Theme Official Installer ---
param ( [string] $version )

Write-Host "Initialing Abdify (Lightweight Pack)..." -ForegroundColor Cyan

$spotifyPath = "$env:APPDATA\Spotify\Apps\xpui"
$localSpicetify = "$env:LOCALAPPDATA\spicetify"

if (!(Test-Path $spotifyPath)) {
    Write-Host "Error: Spotify XPUI not found. Please install Spicetify first to unlock Spotify files." -ForegroundColor Red
    return
}

# 1. Copy Master Theme JS
Write-Host "Deploying Core Engine..." -ForegroundColor Yellow
Copy-Item ".\theme.js" "$spotifyPath\theme.js" -Force

# 2. Patch index.html (Zero-Dependency Method)
$htmlPath = "$spotifyPath\index.html"
$html = Get-Content $htmlPath -Raw

# Ensure Spicetify Wrapper is present (required for the engine)
if ($html -notmatch "spicetifyWrapper.js") {
    # If not found, we assume user hasn't run 'spicetify backup'. 
    # But usually, they should have. We will append it before body.
    $html = $html.Replace("</body>", "<script src='helper/spicetifyWrapper.js'></script><script src='theme.js' defer></script></body>")
} elseif ($html -notmatch "theme.js") {
    $html = $html.Replace("</body>", "<script src='theme.js' defer></script></body>")
}

# Clean marketplace and heavy apps from previous patches
$html = $html -replace "<!-- spicetify helpers -->[\s\S]*?<script src='theme.js' defer></script>", "<script src='theme.js' defer></script>"

Set-Content $htmlPath $html

Write-Host "Abdify is now READY! Restart Spotify to see the magic." -ForegroundColor Green
Write-Host "Note: This is a lightweight installation. No marketplace or heavy extensions were added." -ForegroundColor Gray
