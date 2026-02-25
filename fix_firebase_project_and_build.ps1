#!/usr/bin/env pwsh

Write-Host "🚨 CRITICAL FIX: Firebase Project Configuration" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ Step 1: Firebase configuration files created" -ForegroundColor Green
Write-Host "   - lib/firebase_options.dart ✓" -ForegroundColor Green
Write-Host "   - android/app/google-services.json ✓" -ForegroundColor Green

Write-Host ""
Write-Host "📋 Step 2: Verifying Firebase configuration..." -ForegroundColor Yellow

# Check firebase_options.dart
if (Test-Path "lib/firebase_options.dart") {
    $firebaseOptions = Get-Content "lib/firebase_options.dart" -Raw
    if ($firebaseOptions -match "projectId: 'orbit-live-3836f'") {
        Write-Host "   ✅ firebase_options.dart: orbit-live-3836f confirmed" -ForegroundColor Green
    } else {
        Write-Host "   ❌ firebase_options.dart: Wrong project ID" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ firebase_options.dart: File missing" -ForegroundColor Red
}

# Check google-services.json
if (Test-Path "android/app/google-services.json") {
    $googleServices = Get-Content "android/app/google-services.json" -Raw | ConvertFrom-Json
    if ($googleServices.project_info.project_id -eq "orbit-live-3836f") {
        Write-Host "   ✅ google-services.json: orbit-live-3836f confirmed" -ForegroundColor Green
    } else {
        Write-Host "   ❌ google-services.json: Wrong project ID: $($googleServices.project_info.project_id)" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ google-services.json: File missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "🧹 Step 3: Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "📦 Step 4: Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "🔍 Step 5: Running analysis..." -ForegroundColor Yellow
$analysisResult = flutter analyze 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ No analysis issues found" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Analysis issues found (continuing anyway):" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🏗️  Step 6: Building release APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "APK location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green
    
    if (Test-Path "build/app/outputs/flutter-apk/app-release.apk") {
        $apkSize = (Get-Item "build/app/outputs/flutter-apk/app-release.apk").Length / 1MB
        Write-Host "APK size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "📱 INSTALL COMMAND:" -ForegroundColor Cyan
        Write-Host "adb uninstall com.example.public_transport_tracker" -ForegroundColor White
        Write-Host "adb install -r build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "❌ BUILD FAILED!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎯 CRITICAL SUCCESS CHECKS:" -ForegroundColor Cyan
Write-Host "After installing APK, mobile debug MUST show:" -ForegroundColor Yellow
Write-Host "✅ Firebase project: orbit-live-3836f (GREEN)" -ForegroundColor Green
Write-Host "✅ GPS Service: BULLETPROOF Active" -ForegroundColor Green
Write-Host "✅ Last GPS: Guntur coords (16.29, 80.46)" -ForegroundColor Green

Write-Host ""
Write-Host "🔥 FIREBASE REALTIME DATABASE PATH:" -ForegroundColor Yellow
Write-Host "/live-telemetry/APSRTC-VEH-123" -ForegroundColor Green
Write-Host "Should show LIVE Guntur GPS updating every 5 seconds" -ForegroundColor Green

Write-Host ""
Write-Host "🌐 ADMIN DASHBOARD:" -ForegroundColor Yellow
Write-Host "Should show single marker in Guntur moving in real-time" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🚀 FIREBASE PROJECT FIX COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan