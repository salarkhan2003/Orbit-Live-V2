# Orbit Live - Project Structure

```
orbit-live/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── lib/                        # Flutter application code
│   ├── core/                   # Core services (payments, notifications, etc.)
│   ├── features/               # Feature modules
│   │   ├── auth/              # Authentication
│   │   ├── bookings/          # Booking management
│   │   ├── driver/            # Driver features
│   │   ├── guest/             # Guest user features
│   │   ├── map/               # Map integration
│   │   ├── notifications/     # Notification features
│   │   ├── passenger/         # Passenger features
│   │   ├── passes/            # Pass management
│   │   ├── payments/          # Payment features
│   │   ├── tickets/           # Ticket booking
│   │   └── travel_buddy/      # Travel companion feature
│   ├── models/                # Data models
│   ├── services/              # Business logic services
│   ├── shared/                # Shared widgets and utilities
│   └── widgets/               # Reusable widgets
├── assets/                     # Images, icons, fonts
├── config/                     # Configuration files
│   ├── .env.example           # Environment variables template
│   └── firebase_rules.txt     # Firebase security rules
├── docs/                       # Documentation
│   ├── APP_IMPROVEMENTS_SUMMARY.md
│   ├── COMPLETE_APP_REPORT.md
│   ├── DRIVER_MODULE_IMPLEMENTATION.md
│   ├── ENHANCED_NOTIFICATION_SYSTEM.md
│   ├── FIXES_SUMMARY.md
│   ├── NOTIFICATION_SYSTEM_README.md
│   ├── PASSENGER_LIVE_TRACKING_IMPLEMENTATION.md
│   ├── PROJECT_COMPLETE.md
│   └── SECRETS_SETUP.md
├── scripts/                    # Build and utility scripts
│   ├── build_apk.bat
│   ├── build_apk.ps1
│   ├── build_clean_apk.bat
│   ├── build_production.bat
│   ├── build_production.ps1
│   └── setup.sh
├── test/                       # Unit and integration tests
├── functions/                  # Firebase Cloud Functions
├── .gitignore                 # Git ignore rules
├── pubspec.yaml               # Flutter dependencies
├── README.md                  # Main project documentation
└── PROJECT_STRUCTURE.md       # This file
```

## Key Directories

### `/lib`
Main application code following feature-based architecture.

### `/config`
Configuration files and templates. Never commit actual secrets here.

### `/docs`
All project documentation, implementation guides, and reports.

### `/scripts`
Build scripts and automation tools for development and deployment.

### `/test`
Unit tests, widget tests, and integration tests.

## Development Guidelines

1. Keep secrets in `.env` files (never commit)
2. Follow the feature-based architecture in `/lib/features`
3. Place shared code in `/lib/shared`
4. Document major features in `/docs`
5. Use scripts in `/scripts` for builds
