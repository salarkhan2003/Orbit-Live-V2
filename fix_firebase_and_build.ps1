#!/usr/bin/env pwsh

Write-Host "🚨 EMERGENCY FIX: Firebase Project + GPS Streaming" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. Checking Firebase configuration..." -ForegroundColor Yellow

# Check if firebase_options.dart has correct project
$firebaseOptions = Get-Content "lib/firebase_options.dart" -Raw
if ($firebaseOptions -match "projectId: 'orbit-live-3836f'") {
    Write-Host "✅ Firebase options: orbit-live-3836f found" -ForegroundColor Green
} else {
    Write-Host "❌ Firebase options: orbit-live-3836f NOT found" -ForegroundColor Red
    Write-Host "⚠️  Running flutterfire configure..." -ForegroundColor Yellow
    flutterfire configure --project=orbit-live-3836f
}

# Check google-services.json
if (Test-Path "android/app/google-services.json") {
    $googleServices = Get-Content "android/app/google-services.json" -Raw | ConvertFrom-Json
    if ($googleServices.project_info.project_id -eq "orbit-live-3836f") {
        Write-Host "✅ google-services.json: orbit-live-3836f confirmed" -ForegroundColor Green
    } else {
        Write-Host "❌ google-services.json: Wrong project ID" -ForegroundColor Red
        Write-Host "Current: $($googleServices.project_info.project_id)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ google-services.json: File not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Cleaning and getting dependencies..." -ForegroundColor Yellow
flutter clean
flutter pub get

Write-Host ""
Write-Host "3. Running analysis..." -ForegroundColor Yellow
flutter analyze

Write-Host ""
Write-Host "4. Building release APK with Firebase debugging..." -ForegroundColor Yellow
flutter build apk --release --verbose

Write-Host ""
Write-Host "5. Build complete!" -ForegroundColor Green
Write-Host "APK location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green

Write-Host ""
Write-Host "6. APK size:" -ForegroundColor Yellow
Get-ChildItem "build/app/outputs/flutter-apk/app-release.apk" | Select-Object Name, Length

Write-Host ""
Write-Host "🎯 CRITICAL TESTING CHECKLIST:" -ForegroundColor Cyan
Write-Host "1. Install APK: adb install build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor White
Write-Host "2. Open app → Check debug section shows 'Firebase: orbit-live-3836f'" -ForegroundColor White
Write-Host "3. Start Trip → GPS should update every 5 seconds" -ForegroundColor White
Write-Host "4. Check Firebase Console → /live-telemetry/APSRTC-VEH-123" -ForegroundColor White
Write-Host "5. Admin dashboard → Should show LIVE marker in Guntur" -ForegroundColor White

Write-Host ""
Write-Host "🔥 EXPECTED FIREBASE PATH:" -ForegroundColor Yellow
Write-Host "/live-telemetry/APSRTC-VEH-123" -ForegroundColor Green
Write-Host "Should contain LIVE Guntur GPS coordinates updating every 5s" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🚀 EMERGENCY FIX COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan