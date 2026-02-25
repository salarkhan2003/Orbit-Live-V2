# PowerShell script to build the APK
Write-Host "Starting APK build process..." -ForegroundColor Green

# Navigate to the project directory
Set-Location "D:\SIH\19-9-V5 Orbit live\public_transport_tracker"

# Clean the project
Write-Host "Cleaning project..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build the APK
Write-Host "Building release APK..." -ForegroundColor Yellow
flutter build apk --release

Write-Host "APK build process completed!" -ForegroundColor Green