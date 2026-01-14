# Public Transport Tracker - Android App

A comprehensive Flutter application for public transport tracking and booking with role-based authentication using Clerk. The app supports two user roles: **Passenger** and **Driver/Conductor**, each with their own specialized dashboard and features.

## 🚀 Features

### Authentication (Clerk Integration)
- ✅ Email/Password login and signup
- ✅ Phone number with OTP support (placeholder)
- ✅ Google login integration (placeholder)
- ✅ Role selection after signup (Passenger/Driver-Conductor)
- ✅ Secure JWT session management
- ✅ User metadata storage for role-based access

### Passenger Features
- 🚌 Live bus tracking on Google Maps (placeholder)
- 🎫 Digital ticket booking with QR code generation
- 🎟️ Monthly/Annual pass management
- 📍 AI-powered ETA predictions (API placeholder)
- 🆘 SOS button with live location sharing
- 📱 Multilingual support (English, Hindi, Telugu)
- 📲 Push notifications for bus arrivals

### Driver/Conductor Features
- ▶️ One-tap Start/Stop trip with GPS tracking
- 🛣️ Route selection from assigned routes
- 👥 Passenger count management (manual/auto-detection)
- 📊 Daily trip logs and analytics
- 📢 SOS alert broadcasting
- 📍 Real-time location tracking

### Common Features
- 🌍 Multilingual UI (English, Hindi, Telugu)
- 📱 Offline-first design with data caching
- 🔔 Local and push notifications
- 🎨 Material Design UI with role-based navigation
- 📊 Analytics and reporting

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Authentication**: Clerk Flutter SDK
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Local Storage**: Hive + SharedPreferences
- **HTTP Client**: http package
- **Real-time**: WebSocket Channel
- **QR Code**: qr_flutter + qr_code_scanner
- **Localization**: Flutter i18n

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point with providers
├── core/                              # Core services and utilities
│   ├── clerk_auth_service.dart        # Clerk authentication service
│   └── localization_service.dart      # Multi-language support
├── features/                          # Feature-based modules
│   ├── auth/                         # Authentication module
│   │   ├── domain/
│   │   │   └── user_role.dart        # User role enum and extensions
│   │   ├── presentation/
│   │   │   ├── login_page.dart       # Login screen
│   │   │   ├── signup_page.dart      # Registration screen
│   │   │   └── role_selection_page.dart # Role selection screen
│   ├── passenger/                    # Passenger-specific features
│   │   └── presentation/
│   │       ├── passenger_dashboard.dart # Passenger main screen
│   │       └── passenger_widgets.dart   # Passenger UI components
│   └── driver/                       # Driver/conductor features
│       └── presentation/
│           ├── driver_dashboard.dart     # Driver main screen
│           └── driver_widgets.dart       # Driver UI components
└── shared/                           # Shared components
    └── navigation_drawer.dart        # Role-based navigation drawer
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.1.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device/emulator or iOS simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd public_transport_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Clerk Authentication**
   - Sign up at [Clerk.com](https://clerk.com)
   - Create a new application
   - Get your publishable API key
   - Update `lib/core/clerk_auth_service.dart`:
   ```dart
   static const String _clerkApiKey = 'pk_test_your_actual_clerk_key_here';
   ```

4. **Configure Google Maps (Optional)**
   - Get Google Maps API key from [Google Cloud Console](https://console.cloud.google.com)
   - Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_ACTUAL_GOOGLE_MAPS_API_KEY"/>
   ```

5. **Run the application**
   ```bash
   # For Android
   flutter run

   # For iOS (on macOS only)
   flutter run -d ios
   ```

## 📱 App Flow

### Authentication Flow
1. **Login/Signup**: Users can login with email/password or sign up for new account
2. **Role Selection**: After signup, users select their role (Passenger or Driver/Conductor)
3. **Dashboard**: Users are redirected to role-specific dashboard

### Passenger Flow
1. **Dashboard**: Overview with quick actions and recent activity
2. **Live Tracking**: Real-time bus locations on map
3. **Ticket Booking**: Search routes, select buses, generate QR tickets
4. **Pass Management**: Buy and manage monthly/annual passes
5. **SOS**: Emergency feature with location sharing

### Driver Flow
1. **Dashboard**: Trip controls and current status
2. **Trip Management**: Start/stop trips with GPS tracking
3. **Route Selection**: Choose from assigned routes
4. **Passenger Counting**: Track passenger numbers
5. **Logs**: View daily trip history and analytics

## 🔧 Configuration

### Environment Setup
The app includes development-friendly mock implementations that work without external services:

- **Clerk Auth**: Falls back to local storage for development
- **Google Maps**: Shows placeholder for map integration
- **APIs**: Placeholder implementations for all external services

### Production Setup
For production deployment:

1. **Clerk Configuration**: Add real Clerk API keys
2. **Google Maps**: Configure with actual API key
3. **Backend APIs**: Replace placeholder services with real implementations
4. **Push Notifications**: Configure Firebase Cloud Messaging
5. **Database**: Set up backend with PostgreSQL/MongoDB

## 🌍 Localization

The app supports three languages:
- **English** (default)
- **Hindi** (हिंदी)
- **Telugu** (తెలుగు)

Language can be changed from:
- Login screen (language picker)
- Navigation drawer → Language option
- Settings page

## 📋 Permissions

### Android Permissions
- `INTERNET` - API calls and data sync
- `ACCESS_FINE_LOCATION` - GPS tracking
- `ACCESS_COARSE_LOCATION` - Network-based location
- `ACCESS_BACKGROUND_LOCATION` - Background location tracking
- `CAMERA` - QR code scanning
- `READ_PHONE_STATE` - Phone number verification
- `VIBRATE` - Notification vibrations
- `WAKE_LOCK` - Keep screen on during trips

### iOS Permissions (Info.plist)
Similar permissions need to be configured in `ios/Runner/Info.plist`

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Manual Testing
1. **Authentication Flow**: Test login, signup, and role selection
2. **Role-based Navigation**: Verify different dashboards for roles
3. **Offline Functionality**: Test app behavior without internet
4. **Localization**: Test all supported languages
5. **Permissions**: Test location, camera, and other permissions

## 🚀 Deployment

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔮 Future Enhancements

### Planned Features
- [ ] Real-time WebSocket integration for live tracking
- [ ] AI/ML integration for ETA predictions
- [ ] Payment gateway integration
- [ ] Offline map caching
- [ ] Advanced analytics dashboard
- [ ] Multi-city support
- [ ] Voice commands and accessibility
- [ ] Wearable device support

### Backend Integration
- [ ] Node.js + Express.js API server
- [ ] PostgreSQL database with proper schema
- [ ] Real-time WebSocket server for bus tracking
- [ ] SMS gateway for offline ETA alerts
- [ ] Push notification service

## 🐛 Troubleshooting

### Common Issues

1. **Clerk Authentication Errors**
   - Ensure API key is correct
   - Check internet connectivity
   - Verify Clerk app configuration

2. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Ensure all dependencies are compatible

3. **Permission Issues**
   - Check AndroidManifest.xml permissions
   - Test on physical device for location features
   - Ensure runtime permissions are requested

4. **Map Integration Issues**
   - Verify Google Maps API key
   - Enable required APIs in Google Cloud Console
   - Check billing account setup

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Email: support@publictransporttracker.com
- Documentation: [Link to detailed docs]

---

**Built with ❤️ using Flutter for the SIH 2025 hackathon**
