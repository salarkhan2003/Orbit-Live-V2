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

import 'features/auth/presentation/passenger/passenger_auth_screen.dart';
import 'features/auth/presentation/driver/driver_auth_screen.dart';
import 'features/auth/presentation/enhanced_role_selection_screen.dart';
import 'features/auth/presentation/improved_role_selection_screen.dart';
import 'features/auth/presentation/enhanced_conductor_login_screen.dart';
import 'features/auth/presentation/providers/role_selection_provider.dart';
import 'features/travel_buddy/presentation/providers/travel_buddy_provider.dart';
import 'features/travel_buddy/presentation/travel_buddy_screen.dart';
import 'features/tickets/presentation/providers/ticket_provider.dart';
import 'features/tickets/presentation/ticket_booking_screen.dart';
import 'features/tickets/presentation/all_tickets_screen.dart';
import 'features/passes/presentation/providers/pass_provider.dart';
import 'features/passes/presentation/pass_application_screen.dart';
import 'features/passes/presentation/all_passes_screen.dart';
import 'features/passenger/presentation/passenger_dashboard.dart';
import 'features/driver/presentation/driver_dashboard.dart';
import 'features/guest/presentation/guest_dashboard.dart';
import 'features/map/enhanced_map_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'shared/utils/performance_optimizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Removed role_selection_splash_screen - replaced with OrbitLiveRoleSelectionPage

// Add navigator key for accessing context globally
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize performance optimizations
  await PerformanceOptimizer.initialize();
  
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
        ChangeNotifierProvider(create: (_) => RoleSelectionProvider()),
        ChangeNotifierProvider(create: (_) => TravelBuddyProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => PassProvider()),
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
              '/onboarding': (context) => OnboardingScreen(),
              '/login': (context) => LoginPage(),
              '/signup': (context) => SignupPage(),
              '/role-selection': (context) => ImprovedRoleSelectionScreen(),
              '/passenger-auth': (context) => PassengerAuthScreen(),
              '/driver-auth': (context) => DriverAuthScreen(),
              '/enhanced-conductor-login': (context) => EnhancedConductorLoginScreen(),
              '/ticket-booking': (context) => TicketBookingScreen(),
              '/pass-application': (context) => PassApplicationScreen(),
              '/all-tickets': (context) => AllTicketsScreen(),
              '/all-passes': (context) => AllPassesScreen(),
              '/passenger': (context) => PassengerDashboard(),
              '/driver': (context) => DriverDashboard(),
              '/guest-dashboard': (context) => GuestDashboard(),
              '/map': (context) => EnhancedMapScreen(userRole: Provider.of<AuthProvider>(context, listen: false).user?.role?.name ?? 'guest'),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/travel-buddy') {
                final args = settings.arguments as Map<String, String>?;
                return MaterialPageRoute(
                  builder: (context) => TravelBuddyScreen(arguments: args),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasSeenOnboarding = false;
  bool _isCheckingOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      if (mounted) {
        setState(() {
          _hasSeenOnboarding = hasSeenOnboarding;
          _isCheckingOnboarding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasSeenOnboarding = false;
          _isCheckingOnboarding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingOnboarding) {
      return SplashScreen();
    }

    // Show onboarding if user hasn't seen it
    if (!_hasSeenOnboarding) {
      return OnboardingScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return SplashScreen();
        }

        // Initialize travel buddy provider with user ID
        if (authProvider.user != null) {
          final travelBuddyProvider = Provider.of<TravelBuddyProvider>(context, listen: false);
          travelBuddyProvider.initialize(authProvider.user!.id);
        }

        if (authProvider.user == null) {
          return ImprovedRoleSelectionScreen();
        }

        if (authProvider.user?.role == null) {
          return EnhancedRoleSelectionScreen();
        }

        switch (authProvider.user?.role) {
          case UserRole.passenger:
            return PassengerDashboard();
          case UserRole.driver:
            return DriverDashboard();
          default:
            return ImprovedRoleSelectionScreen();
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
      // Add timeout for faster loading
      _user = await AuthService.getCurrentUser().timeout(
        Duration(seconds: 3),
        onTimeout: () => null,
      );
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
      
      // Initialize travel buddy provider with user ID if login successful
      if (_user != null) {
        final travelBuddyProvider = Provider.of<TravelBuddyProvider>(navigatorKey.currentContext!, listen: false);
        travelBuddyProvider.initialize(_user!.id);
      }
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
      
      // Initialize travel buddy provider with user ID if signup successful
      if (_user != null) {
        final travelBuddyProvider = Provider.of<TravelBuddyProvider>(navigatorKey.currentContext!, listen: false);
        travelBuddyProvider.initialize(_user!.id);
      }
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

  void setAuthenticatedUser({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required UserRole role,
  }) {
    _user = AuthUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      role: role,
    );
    _isAuthenticated = true;
    _isLoading = false;
    _isGuestMode = false;
    notifyListeners();
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