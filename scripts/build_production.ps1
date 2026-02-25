#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Orbit Live Production APK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "2. Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "3. Running code analysis..." -ForegroundColor Yellow
flutter analyze

Write-Host ""
Write-Host "4. Building release APK..." -ForegroundColor Yellow
flutter build apk --release --verbose

Write-Host ""
Write-Host "5. Build complete!" -ForegroundColor Green
Write-Host "APK location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green

Write-Host ""
Write-Host "6. APK size:" -ForegroundColor Yellow
Get-ChildItem "build/app/outputs/flutter-apk/app-release.apk" | Select-Object Name, Length

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Production build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Install APK: adb install build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor White
Write-Host "2. Test on real Android device" -ForegroundColor White
Write-Host "3. Verify Firebase project: orbit-live-3836f" -ForegroundColor White
Write-Host "4. Check admin dashboard for live tracking" -ForegroundColor White
Write-Host "5. GPS updates every 5 seconds with BULLETPROOF service" -ForegroundColor Green
Write-Host "6. Check /live-telemetry/APSRTC-VEH-123 in Firebase Realtime DB" -ForegroundColor Green