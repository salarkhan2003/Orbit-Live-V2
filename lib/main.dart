import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/clerk_auth_service.dart';
import 'core/localization_service.dart';
import 'core/connectivity_service.dart';
import 'features/auth/domain/user_role.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/signup_page.dart';
import 'features/auth/presentation/role_selection_page.dart';
import 'features/auth/presentation/passenger/passenger_auth_screen.dart';
import 'features/auth/presentation/driver/driver_auth_screen.dart';
import 'features/auth/presentation/driver_login_screen.dart';
import 'features/auth/presentation/modern_role_selection_page.dart';
import 'features/auth/presentation/conductor_login_screen.dart';
import 'features/passenger/presentation/passenger_dashboard.dart';
import 'features/driver/presentation/driver_dashboard.dart';
import 'features/guest/presentation/guest_dashboard.dart';
import 'features/map/openstreet_map_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/splash/presentation/role_selection_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Handle Firebase initialization error gracefully
    print('Firebase initialization error: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: Consumer2<LocalizationProvider, ConnectivityService>(
        builder: (context, localizationProvider, connectivityService, child) {
          return MaterialApp(
            title: 'Orbit Live',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            locale: localizationProvider.currentLocale,
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode &&
                    supportedLocale.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
              }
              return const Locale('en', 'US');
            },
            home: AuthGate(),
            routes: {
              '/login': (context) => LoginPage(),
              '/signup': (context) => SignupPage(),
              '/role-selection': (context) => RoleSelectionPage(),
              '/role-selection-splash': (context) => RoleSelectionSplashScreen(),
              '/modern-role-selection': (context) => ModernRoleSelectionPage(),
              '/passenger-auth': (context) => PassengerAuthScreen(),
              '/driver-auth': (context) => DriverAuthScreen(),
              '/driver-login': (context) => DriverLoginScreen(),
              '/conductor-login': (context) => ConductorLoginScreen(),
              '/passenger': (context) => PassengerDashboard(),
              '/driver': (context) => DriverDashboard(),
              '/guest-dashboard': (context) => GuestDashboard(),
              '/map': (context) => OpenStreetMapScreen(userRole: Provider.of<AuthProvider>(context, listen: false).user?.role?.name ?? 'guest'),
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return SplashScreen();
        }

        // Completely remove guest mode check
        // if (authProvider.isGuestMode) {
        //   return GuestDashboard();
        // }

        if (authProvider.user == null) {
          return RoleSelectionSplashScreen();
        }

        if (authProvider.user?.role == null) {
          return RoleSelectionPage();
        }

        switch (authProvider.user?.role) {
          case UserRole.passenger:
            return PassengerDashboard();
          case UserRole.driver:
            return DriverDashboard();
          default:
            return RoleSelectionPage();
        }
      },
    );
  }
}

// Auth Provider for state management
class AuthProvider with ChangeNotifier {
  AuthUser? _user;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isGuestMode = false;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuestMode => _isGuestMode;
  UserRole? get userRole => _user?.role;

  AuthProvider() {
    checkCurrentUser();
  }
  
  // Method to set a guest user with a specific role
  void setGuestUser(UserRole role) {
    _user = AuthUser(
      id: 'guest_${role.name}_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@example.com',
      firstName: 'Guest',
      lastName: role == UserRole.passenger ? 'Passenger' : 'Driver',
      phoneNumber: '',
      role: role,
    );
    _isAuthenticated = true;
    _isLoading = false;
    _isGuestMode = false; // Not using guest mode flag anymore
    notifyListeners();
  }

  Future<void> checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.getCurrentUser();
      _isAuthenticated = _user != null;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.signIn(email, password);
      _isAuthenticated = _user != null;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.signUp(email, password);
      _isAuthenticated = _user != null;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.signInWithGoogle();
      _isAuthenticated = _user != null;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setRole(UserRole role) async {
    if (_user != null) {
      await AuthService.setRole(_user!.id, role);
      _user = _user!.copyWith(role: role);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.signOut();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void enableGuestMode() {
    _isGuestMode = true;
    _isLoading = false;
    notifyListeners();
  }

  void disableGuestMode() {
    _isGuestMode = false;
    notifyListeners();
  }
}