@echo off
echo ========================================
echo Building Orbit Live Production APK
echo ========================================

echo.
echo 1. Cleaning previous builds...
flutter clean

echo.
echo 2. Getting dependencies...
flutter pub get

echo.
echo 3. Running code analysis...
flutter analyze

echo.
echo 4. Building release APK...
flutter build apk --release --verbose

echo.
echo 5. Build complete!
echo APK location: build\app\outputs\flutter-apk\app-release.apk

echo.
echo 6. APK size:
dir build\app\outputs\flutter-apk\app-release.apk

echo.
echo ========================================
echo Production build completed successfully!
echo ========================================
pause