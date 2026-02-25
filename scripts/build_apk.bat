@echo off
echo Starting APK build process...
echo.

echo Cleaning project...
flutter clean
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Building release APK...
flutter build apk --release
echo.

echo APK build process completed!
pause