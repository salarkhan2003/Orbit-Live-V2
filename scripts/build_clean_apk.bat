@echo off
echo ========================================
echo    ORBIT LIVE - CLEAN BUILD SCRIPT
echo ========================================

echo Step 1: Cleaning previous builds...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Analyzing code for errors...
flutter analyze --no-fatal-infos

echo Step 4: Building APK...
flutter build apk --release

echo Step 5: Build completed!
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo ========================================
echo    BUILD COMPLETE - READY TO INSTALL
echo ========================================
pause