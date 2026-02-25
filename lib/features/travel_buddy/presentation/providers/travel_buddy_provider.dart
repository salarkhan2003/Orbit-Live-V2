import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/travel_buddy_models.dart';
import '../../data/travel_buddy_service.dart';

/// Provider for managing travel buddy state
class TravelBuddyProvider with ChangeNotifier {
  final TravelBuddyService _service = TravelBuddyService();
  
  // State variables
  List<TravelBuddyProfile> _matches = [];
  List<BuddyRequest> _pendingRequests = [];
  List<TravelBuddyConnection> _activeConnections = [];
  TravelBuddyPreferences _preferences = const TravelBuddyPreferences();
  
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String? _currentRoute;
  DateTime? _currentTravelTime;
  String? _currentUserId;
  
  // Stream subscriptions
  StreamSubscription<List<TravelBuddyProfile>>? _matchesSubscription;
  StreamSubscription<List<BuddyRequest>>? _requestsSubscription;
  StreamSubscription<List<TravelBuddyConnection>>? _connectionsSubscription;

  // Getters
  List<TravelBuddyProfile> get matches => _matches;
  List<BuddyRequest> get pendingRequests => _pendingRequests;
  List<TravelBuddyConnection> get activeConnections => _activeConnections;
  TravelBuddyPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String? get currentRoute => _currentRoute;
  DateTime? get currentTravelTime => _currentTravelTime;
  bool get hasActiveConnections => _activeConnections.isNotEmpty;
  
  /// Initialize the provider with user ID
  void initialize(String userId) {
    _currentUserId = userId;
    _setupStreamListeners();
    _loadInitialData();
  }

  /// Initialize with a default user ID for testing
  void initializeForTesting() {
    _currentUserId = 'test_user_123';
    _setupStreamListeners();
    _loadInitialData();
    
    // Trigger a search to show mock data immediately
    Future.microtask(() {
      if (_currentUserId != null) {
        searchForBuddies(
          route: 'Guntur Central to Tenali',
          travelTime: DateTime.now().add(Duration(minutes: 10)),
        );
      }
    });
  }

  /// Setup stream listeners for real-time updates
  void _setupStreamListeners() {
    _matchesSubscription = _service.matchesStream.listen((matches) {
      _matches = matches;
      notifyListeners();
    });
    
    _requestsSubscription = _service.requestsStream.listen((requests) {
      _pendingRequests = requests.where((r) => 
          r.receiverId == _currentUserId && 
          r.status == BuddyRequestStatus.pending
      ).toList();
      notifyListeners();
    });
    
    _connectionsSubscription = _service.connectionsStream.listen((connections) {
      _activeConnections = connections.where((c) => 
          (c.userId1 == _currentUserId || c.userId2 == _currentUserId) &&
          c.isActive
      ).toList();
      notifyListeners();
    });
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    if (_currentUserId == null) return;
    
    _setLoading(true);
    try {
      // Load pending requests and active connections
      final requests = await _service.getPendingRequests(_currentUserId!);
      final connections = await _service.getActiveConnections(_currentUserId!);
      
      _pendingRequests = requests;
      _activeConnections = connections;
      _clearError();
    } catch (e) {
      _setError('Failed to load travel buddy data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Search for travel buddies
  Future<void> searchForBuddies({
    required String route,
    required DateTime travelTime,
  }) async {
    if (_currentUserId == null) return;
    
    _currentRoute = route;
    _currentTravelTime = travelTime;
    _setSearching(true);
    
    try {
      final matches = await _service.findMatches(
        route: route,
        travelTime: travelTime,
        preferences: _preferences,
        currentUserId: _currentUserId!,
      );
      
      _matches = matches;
      _clearError();
    } catch (e) {
      _setError('Failed to find travel buddies: ${e.toString()}');
    } finally {
      _setSearching(false);
    }
  }

  /// Send a buddy request
  Future<bool> sendBuddyRequest({
    required String receiverId,
    String? message,
  }) async {
    if (_currentUserId == null || _currentRoute == null || _currentTravelTime == null) {
      return false;
    }
    
    _setLoading(true);
    try {
      final success = await _service.sendBuddyRequest(
        senderId: _currentUserId!,
        receiverId: receiverId,
        route: _currentRoute!,
        travelTime: _currentTravelTime!,
        message: message,
      );
      
      if (success) {
        _clearError();
      }
      return success;
    } catch (e) {
      _setError('Failed to send buddy request: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Respond to a buddy request
  Future<bool> respondToBuddyRequest({
    required String requestId,
    required bool accept,
  }) async {
    _setLoading(true);
    try {
      final success = await _service.respondToBuddyRequest(
        requestId: requestId,
        accept: accept,
      );
      
      if (success) {
        _clearError();
      }
      return success;
    } catch (e) {
      _setError('Failed to respond to buddy request: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user location
  Future<void> updateLocation(TravelBuddyLocation location) async {
    if (_currentUserId == null) return;
    
    try {
      await _service.updateLocation(
        userId: _currentUserId!,
        location: location,
      );
    } catch (e) {
      debugPrint('Failed to update location: ${e.toString()}');
    }
  }

  /// Disconnect from a travel buddy
  Future<bool> disconnectBuddy(String connectionId) async {
    _setLoading(true);
    try {
      final success = await _service.disconnectBuddy(connectionId);
      if (success) {
        _clearError();
      }
      return success;
    } catch (e) {
      _setError('Failed to disconnect buddy: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send SOS alert
  Future<bool> sendSOSAlert({
    required TravelBuddyLocation location,
    String? message,
  }) async {
    if (_currentUserId == null) return false;
    
    try {
      final success = await _service.sendSOSAlert(
        userId: _currentUserId!,
        location: location,
        message: message,
      );
      
      if (success) {
        _clearError();
      }
      return success;
    } catch (e) {
      _setError('Failed to send SOS alert: ${e.toString()}');
      return false;
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences(TravelBuddyPreferences newPreferences) async {
    if (_currentUserId == null) return false;
    
    _setLoading(true);
    try {
      final success = await _service.updatePreferences(
        userId: _currentUserId!,
        preferences: newPreferences,
      );
      
      if (success) {
        _preferences = newPreferences;
        _clearError();
      }
      return success;
    } catch (e) {
      _setError('Failed to update preferences: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get buddy profile by connection
  TravelBuddyProfile? getBuddyProfile(TravelBuddyConnection connection) {
    final buddyId = connection.userId1 == _currentUserId 
        ? connection.userId2 
        : connection.userId1;
    
    return _matches.where((profile) => profile.id == buddyId).firstOrNull;
  }

  /// Clear current search
  void clearSearch() {
    _matches = [];
    _currentRoute = null;
    _currentTravelTime = null;
    _clearError();
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await _loadInitialData();
    if (_currentRoute != null && _currentTravelTime != null) {
      await searchForBuddies(
        route: _currentRoute!,
        travelTime: _currentTravelTime!,
      );
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    _requestsSubscription?.cancel();
    _connectionsSubscription?.cancel();
    super.dispose();
  }
}