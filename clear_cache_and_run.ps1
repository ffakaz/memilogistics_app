# Clear Flutter cache and rebuild script
Write-Host "Clearing Flutter cache..." -ForegroundColor Yellow

# Remove cache directories
if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool"
    Write-Host "Removed .dart_tool" -ForegroundColor Green
}

if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
    Write-Host "Removed build" -ForegroundColor Green
}

if (Test-Path ".flutter-plugins") {
    Remove-Item -Force ".flutter-plugins"
    Write-Host "Removed .flutter-plugins" -ForegroundColor Green
}

if (Test-Path ".flutter-plugins-dependencies") {
    Remove-Item -Force ".flutter-plugins-dependencies"
    Write-Host "Removed .flutter-plugins-dependencies" -ForegroundColor Green
}

Write-Host "`nRunning flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "`nFetching packages..." -ForegroundColor Yellow
flutter pub get

Write-Host "`nRunning app on Edge..." -ForegroundColor Yellow
flutter run -d edge

Write-Host "`nDone!" -ForegroundColor Green
