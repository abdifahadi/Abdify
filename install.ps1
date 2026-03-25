# --- Abdify Theme Official Installer ---
# Version: 2.1
param ( [string] $version )

Write-Host "Initializing Abdify (Lightweight)..." -ForegroundColor Cyan

# Define the target OS path (Keep hidden from branding)
$Root = "$env:APPDATA\Spotify\Apps\xpui"

if (!(Test-Path $Root)) {
    Write-Host "Error: Abdify Core not found. Please install the Abdify engine first." -ForegroundColor Red
    return
}

# 1. Copy Master Theme JS
Write-Host "Deploying Abdify Core Engine..." -ForegroundColor Yellow
Copy-Item ".\abdi_engine.js" "$Root\abdi_engine.js" -Force
Copy-Item ".\abdify.js" "$Root\abdify.js" -Force
Copy-Item ".\user.css" "$Root\abdify.css" -Force

# 2. Patch index.html (Clean & Direct)
$htmlPath = "$Root\index.html"
$html = Get-Content $htmlPath -Raw

# Remove any old branding and inject Abdify
$html = $html -replace "<!--.*?-->", "" # Clean comments
$html = $html -replace "<script src='abdify_engine.js'></script>", ""
$html = $html -replace "<script src='abdify.js' defer></script>", ""
$html = $html -replace "<script src='abdi_engine.js'></script>", ""
$html = $html -replace "<script src='abdi.js' defer></script>", ""

# Fresh injection before closing body
if ($html -notmatch "abdi_engine.js") {
    $html = $html.Replace("</body>", "<script src='abdi_engine.js'></script><script src='abdify.js' defer></script></body>")
}

Set-Content $htmlPath $html

Write-Host "Abdify is now READY! Restart to see the magic." -ForegroundColor Green
Write-Host "Standalone Abdify Implementation Success." -ForegroundColor Gray
