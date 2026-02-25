#!/bin/bash
# setup.sh - Quick setup script for Public Transport Tracker

echo "🚀 Setting up Public Transport Tracker Flutter App..."

echo "📦 Installing Flutter dependencies..."
flutter pub get

echo "🔍 Running Flutter analysis..."
flutter analyze

echo "🧪 Running tests..."
flutter test

echo "🏗️ Building app (debug)..."
flutter build apk --debug

echo "✅ Setup completed successfully!"
echo ""
echo "📱 To run the app:"
echo "   flutter run"
echo ""
echo "🔧 Next steps:"
echo "   1. Add your Clerk API key to lib/core/clerk_auth_service.dart"
echo "   2. Add Google Maps API key to android/app/src/main/AndroidManifest.xml"
echo "   3. Test the app on a physical device or emulator"
echo ""
echo "📚 See README.md for detailed setup instructions"
