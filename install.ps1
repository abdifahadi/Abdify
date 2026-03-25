# --- Abdify Theme Official Remote Installer ---
# Version: 2.2
param ( [string] $version )

$RepoBase = "https://raw.githubusercontent.com/abdifahadi/Abdify/main"
$AppPath = "$env:APPDATA\Spotify\Apps\xpui"

Write-Host "Initializing Abdify Remote Setup..." -ForegroundColor Cyan

# 1. Validation
if (!(Test-Path $AppPath)) {
    Write-Host "Error: Spotify XPUI was not found. Please open Spotify once and close it before running this script." -ForegroundColor Red
    return
}

# 2. Downloading Core Components from GitHub
Write-Host "Fetching Abdify Core from Repository..." -ForegroundColor Yellow

$files = @("abdi_engine.js", "abdify.js", "user.css")

foreach ($file in $files) {
    $targetFile = Join-Path $AppPath $file
    $downloadUrl = "$RepoBase/$file"
    Write-Host "Downloading $file..." -NoNewline
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $targetFile -UseBasicParsing
        Write-Host " [Done]" -ForegroundColor Green
    } catch {
        Write-Host " [Failed]" -ForegroundColor Red
        Write-Host "Error details: $_"
    }
}

# 3. Patching Host Interface (index.html)
Write-Host "Patching Application Shell..." -ForegroundColor Yellow
$htmlPath = Join-Path $AppPath "index.html"
$html = Get-Content $htmlPath -Raw

# Clean old entries
$html = $html -replace "<!--.*?-->", "" # Remove comments
$html = $html -replace "<script src='abdify_engine.js'></script>", ""
$html = $html -replace "<script src='abdify.js' defer></script>", ""
$html = $html -replace "<script src='abdi_engine.js'></script>", ""
$html = $html -replace "<script src='abdi.js' defer></script>", ""

# Fresh injection before closing body
if ($html -notmatch "abdi_engine.js") {
    $html = $html.Replace("</body>", "<script src='abdi_engine.js'></script><script src='abdify.js' defer></script></body>")
}

Set-Content $htmlPath $html

Write-Host "`nAbdify has been successfully installed!" -ForegroundColor Green
Write-Host "Please restart Spotify to see the transformation." -ForegroundColor Gray
