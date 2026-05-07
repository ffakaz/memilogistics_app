# Enable Windows Developer Mode
# Run this script as Administrator

Write-Host "Enabling Developer Mode..." -ForegroundColor Yellow

# Set the registry key to enable Developer Mode
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

# Create the registry path if it doesn't exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Enable Developer Mode
Set-ItemProperty -Path $registryPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord

Write-Host "Developer Mode has been enabled!" -ForegroundColor Green
Write-Host "You may need to restart your computer for changes to take effect." -ForegroundColor Cyan
Write-Host ""
Write-Host "After restart, run: flutter run -d edge" -ForegroundColor Yellow
