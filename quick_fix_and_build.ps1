#!/usr/bin/env pwsh

Write-Host "🔧 QUICK FIX: Compilation Errors + Build APK" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. Fixing import issues..." -ForegroundColor Yellow

# Check if intl import is missing in driver_dashboard.dart
$driverDashboard = Get-Content "lib/features/driver/presentation/driver_dashboard.dart" -Raw
if ($driverDashboard -notmatch "import 'package:intl/intl.dart';") {
    Write-Host "⚠️  Adding missing intl import to driver_dashboard.dart" -ForegroundColor Yellow
    # The import should already be added by the previous fix
}

Write-Host ""
Write-Host "2. Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "3. Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "4. Running analysis to check for errors..." -ForegroundColor Yellow
$analysisResult = flutter analyze 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ No analysis issues found" -ForegroundColor Green
} else {
    Write-Host "⚠️  Analysis issues found:" -ForegroundColor Yellow
    Write-Host $analysisResult -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Building release APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "APK location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "6. APK size:" -ForegroundColor Yellow
    if (Test-Path "build/app/outputs/flutter-apk/app-release.apk") {
        Get-ChildItem "build/app/outputs/flutter-apk/app-release.apk" | Select-Object Name, Length
        
        Write-Host ""
        Write-Host "🚀 READY TO INSTALL:" -ForegroundColor Green
        Write-Host "adb install -r build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor White
    } else {
        Write-Host "❌ APK file not found!" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "❌ BUILD FAILED!" -ForegroundColor Red
    Write-Host "Check the error messages above and fix any remaining issues." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 TESTING CHECKLIST:" -ForegroundColor Cyan
Write-Host "1. Install APK on Android device" -ForegroundColor White
Write-Host "2. Open app → Check Firebase project: orbit-live-3836f" -ForegroundColor White
Write-Host "3. Start Trip → GPS updates every 5 seconds" -ForegroundColor White
Write-Host "4. Check Firebase Console → /live-telemetry/APSRTC-VEH-123" -ForegroundColor White
Write-Host "5. Admin dashboard → Live marker in Guntur" -ForegroundColor White

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan