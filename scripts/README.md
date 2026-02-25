# Build Scripts

This directory contains build and deployment scripts for the Orbit Live application.

## 📜 Available Scripts

### Build Scripts

#### Windows (PowerShell)
- **`build_apk.ps1`** - Build debug APK
- **`build_production.ps1`** - Build production release APK with optimizations

#### Windows (Batch)
- **`build_apk.bat`** - Build debug APK (batch version)
- **`build_clean_apk.bat`** - Clean build directory and build fresh APK
- **`build_production.bat`** - Build production release APK (batch version)

#### Linux/Mac
- **`setup.sh`** - Initial project setup script

## 🚀 Usage

### Building Debug APK
```bash
# PowerShell
.\scripts\build_apk.ps1

# Batch
.\scripts\build_apk.bat
```

### Building Production APK
```bash
# PowerShell
.\scripts\build_production.ps1

# Batch
.\scripts\build_production.bat
```

### Clean Build
```bash
.\scripts\build_clean_apk.bat
```

## 📋 Prerequisites

Before running build scripts:
1. Flutter SDK installed and in PATH
2. Android SDK configured
3. Environment variables set (see `config/.env.example`)
4. Firebase configuration files in place

## 🔐 Environment Variables

For production builds with API keys, use:
```bash
flutter build apk --dart-define=TWILIO_ACCOUNT_SID=your_sid --dart-define=TWILIO_AUTH_TOKEN=your_token
```

See `docs/SECRETS_SETUP.md` for detailed configuration.

## 📝 Notes

- Debug builds are larger and include debugging symbols
- Production builds are optimized and minified
- Always test production builds before deployment
- Keep build scripts updated with project requirements
