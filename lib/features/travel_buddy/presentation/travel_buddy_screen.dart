import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';
import '../domain/travel_buddy_models.dart';
import 'providers/travel_buddy_provider.dart';
import 'widgets/travel_buddy_onboarding_popup.dart';

/// Main TravelBuddy feature screen
class TravelBuddyScreen extends StatefulWidget {
  final Map<String, String>? arguments;

  const TravelBuddyScreen({super.key, this.arguments});

  @override
  State<TravelBuddyScreen> createState() => _TravelBuddyScreenState();
}

class _TravelBuddyScreenState extends State<TravelBuddyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _selectedTravelTime;
  bool _hasSearched = false; // Track if user has performed a search

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Pre-fill with sample route for Guntur or use passed arguments
    if (widget.arguments != null) {
      _sourceController.text = widget.arguments!['source'] ?? 'Guntur Central';
      _destinationController.text = widget.arguments!['destination'] ?? 'Tenali';
    } else {
      _sourceController.text = 'Guntur Central';
      _destinationController.text = 'Tenali';
    }
    
    // Show onboarding popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TravelBuddyOnboardingPopup.showIfNeeded(
        context,
        onGetStarted: () {
          // Focus on the route input when user gets started
          FocusScope.of(context).requestFocus(FocusNode());
        },
      );
      
      // Initialize with mock data for testing
      _initializeWithMockData();
    });
  }

  void _initializeWithMockData() {
    final provider = Provider.of<TravelBuddyProvider>(context, listen: false);
    
    // Always show mock data - initialize with default user and search
    provider.initializeForTesting();
    
    // Set flag to indicate we've shown default buddies
    setState(() {
      _hasSearched = true;
    });
  }

  void _searchForBuddies(TravelBuddyProvider provider) {
    // Always allow search, even with empty fields - show default buddies
    final route = _sourceController.text.isEmpty || _destinationController.text.isEmpty
        ? 'Guntur Central to Tenali' // Default route if fields are empty
        : '${_sourceController.text} to ${_destinationController.text}';
    
    final travelTime = _selectedTravelTime ?? DateTime.now().add(const Duration(minutes: 10));

    provider.searchForBuddies(
      route: route,
      travelTime: travelTime,
    );

    // Mark that a search has been performed
    setState(() {
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: OrbitLiveColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFindBuddiesTab(),
                    _buildRequestsTab(),
                    _buildActiveConnectionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSOSButton(),
    );
  }

  Widget _buildHeader() {
    return const AppHeader(
      title: 'TravelBuddy',
      subtitle: 'Find your perfect travel companion',
      showBackButton: true,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: OrbitLiveColors.tealGradient,
          ),
        ),
        labelColor: Colors.white, // Keep white for contrast on teal gradient
        unselectedLabelColor: OrbitLiveColors.darkGray,
        labelStyle: OrbitLiveTextStyles.buttonMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: OrbitLiveTextStyles.buttonMedium,
        tabs: const [
          Tab(text: 'Find Buddies'),
          Tab(text: 'Requests'),
          Tab(text: 'Active'),
        ],
      ),
    );
  }

  Widget _buildFindBuddiesTab() {
    return Consumer<TravelBuddyProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchForm(provider),
              const SizedBox(height: 24),
              if (provider.isSearching)
                _buildLoadingIndicator()
              else if (provider.matches.isNotEmpty)
                _buildMatchesList(provider)
              else if (_hasSearched && provider.currentRoute != null)
                _buildNoMatchesFound()
              else
                _buildDefaultMatches(provider), // Show default mock buddies
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultMatches(TravelBuddyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Travel Buddies',
          style: OrbitLiveTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: OrbitLiveColors.black,
          ),
        ),
        const SizedBox(height: 16),
        // Show a message that these are default suggestions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'These are sample travel buddies. Use the search above to find buddies for your specific route.',
            style: OrbitLiveTextStyles.bodySmall.copyWith(
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Show default mock buddies
        _buildDefaultBuddyList(),
      ],
    );
  }

  Widget _buildDefaultBuddyList() {
    // Create some default mock buddies to show
    final defaultBuddies = [
      TravelBuddyProfile(
        id: 'default_1',
        name: 'Raj Kumar',
        route: 'Guntur Central to Tenali',
        travelTime: DateTime.now().add(const Duration(minutes: 15)),
        genderPreference: GenderPreference.male,
        languages: ['Telugu', 'English'],
        rating: 4.7,
        completedTrips: 18,
        isOnline: true,
        bio: 'Daily commuter from Guntur to Tenali',
      ),
      TravelBuddyProfile(
        id: 'default_2',
        name: 'Priya Reddy',
        route: 'Guntur to Mangalagiri',
        travelTime: DateTime.now().add(const Duration(minutes: 20)),
        genderPreference: GenderPreference.female,
        languages: ['Telugu', 'English'],
        rating: 4.5,
        completedTrips: 25,
        isOnline: true,
        bio: 'Software engineer traveling to Mangalagiri tech park',
      ),
      TravelBuddyProfile(
        id: 'default_3',
        name: 'Arun Patel',
        route: 'RTC Bus Stand to Namburu',
        travelTime: DateTime.now().add(const Duration(minutes: 10)),
        genderPreference: GenderPreference.male,
        languages: ['Hindi', 'English'],
        rating: 4.3,
        completedTrips: 12,
        isOnline: true,
        bio: 'College student looking for travel buddies',
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: defaultBuddies.length,
      itemBuilder: (context, index) {
        return _buildDefaultBuddyCard(defaultBuddies[index]);
      },
    );
  }

  Widget _buildDefaultBuddyCard(TravelBuddyProfile buddy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: OrbitLiveColors.primaryTeal.withValues(alpha: 0.1),
                child: Text(
                  buddy.name.substring(0, 1).toUpperCase(),
                  style: OrbitLiveTextStyles.bodyLarge.copyWith(
                    color: OrbitLiveColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          buddy.name,
                          style: OrbitLiveTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: OrbitLiveColors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (buddy.isOnline)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    // Add gender information
                    if (buddy.genderPreference != GenderPreference.any)
                      Text(
                        _getGenderText(buddy.genderPreference),
                        style: OrbitLiveTextStyles.bodySmall.copyWith(
                          color: _getGenderColor(buddy.genderPreference),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Text(
                      '⭐ ${buddy.rating.toStringAsFixed(1)} • ${buddy.completedTrips} trips',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: OrbitLiveColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Route: ${buddy.route}',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.black,
            ),
          ),
          Text(
            'Travel Time: ${_formatTime(buddy.travelTime)}',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.black,
            ),
          ),
          if (buddy.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              buddy.bio!,
              style: OrbitLiveTextStyles.bodySmall.copyWith(
                color: OrbitLiveColors.darkGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('In a real app, this would send a request to ${buddy.name}'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OrbitLiveColors.primaryTeal,
                    side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send Request'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing ${buddy.name}\'s profile')),
                  );
                },
                icon: const Icon(Icons.info_outline),
                color: OrbitLiveColors.darkGray,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm(TravelBuddyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Travel Buddies',
            style: OrbitLiveTextStyles.displaySmall.copyWith(
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 16),
          
          // Source field
          TextField(
            controller: _sourceController,
            decoration: InputDecoration(
              labelText: 'Source',
              hintText: 'Enter starting point',
              prefixIcon: const Icon(Icons.location_on, color: OrbitLiveColors.primaryTeal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: OrbitLiveColors.primaryTeal,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Destination field
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(
              labelText: 'Destination',
              hintText: 'Enter destination',
              prefixIcon: const Icon(Icons.location_on, color: OrbitLiveColors.primaryTeal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: OrbitLiveColors.primaryTeal,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          InkWell(
            onTap: () => _selectTravelTime(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: OrbitLiveColors.primaryTeal),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTravelTime != null
                        ? 'Travel Time: ${_formatTime(_selectedTravelTime!)}'
                        : 'Select Travel Time',
                    style: OrbitLiveTextStyles.bodyMedium.copyWith(
                      color: OrbitLiveColors.black,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: OrbitLiveColors.primaryTeal),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _searchForBuddies(provider), // Always allow search
              style: ElevatedButton.styleFrom(
                backgroundColor: OrbitLiveColors.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
              ),
              child: Text(
                'Search for Buddies',
                style: OrbitLiveTextStyles.buttonPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(TravelBuddyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Found ${provider.matches.length} potential buddies',
          style: OrbitLiveTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: OrbitLiveColors.black,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.matches.length,
          itemBuilder: (context, index) {
            final buddy = provider.matches[index];
            return _buildBuddyCard(buddy, provider);
          },
        ),
      ],
    );
  }

  Widget _buildBuddyCard(TravelBuddyProfile buddy, TravelBuddyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: OrbitLiveColors.primaryTeal.withValues(alpha: 0.1),
                child: Text(
                  buddy.name.substring(0, 1).toUpperCase(),
                  style: OrbitLiveTextStyles.bodyLarge.copyWith(
                    color: OrbitLiveColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          buddy.name,
                          style: OrbitLiveTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: OrbitLiveColors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (buddy.isOnline)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    // Add gender information
                    if (buddy.genderPreference != GenderPreference.any)
                      Text(
                        _getGenderText(buddy.genderPreference),
                        style: OrbitLiveTextStyles.bodySmall.copyWith(
                          color: _getGenderColor(buddy.genderPreference),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Text(
                      '⭐ ${buddy.rating.toStringAsFixed(1)} • ${buddy.completedTrips} trips',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: OrbitLiveColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Route: ${buddy.route}',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.black,
            ),
          ),
          Text(
            'Travel Time: ${_formatTime(buddy.travelTime)}',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.black,
            ),
          ),
          if (buddy.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              buddy.bio!,
              style: OrbitLiveTextStyles.bodySmall.copyWith(
                color: OrbitLiveColors.darkGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _sendBuddyRequest(buddy, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OrbitLiveColors.primaryTeal,
                    side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send Request'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _viewBuddyProfile(buddy),
                icon: const Icon(Icons.info_outline),
                color: OrbitLiveColors.darkGray,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return Consumer<TravelBuddyProvider>(
      builder: (context, provider, child) {
        if (provider.pendingRequests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No Pending Requests',
            subtitle: 'Buddy requests will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.pendingRequests.length,
          itemBuilder: (context, index) {
            final request = provider.pendingRequests[index];
            return _buildRequestCard(request, provider);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuddyRequest request, TravelBuddyProvider provider) {
    // We need to get the sender's profile to display gender information
    // For now, we'll just display basic request info
    // In a real implementation, you would fetch the sender's profile
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buddy Request',
            style: OrbitLiveTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Route: ${request.route}',
            style: OrbitLiveTextStyles.bodyMedium,
          ),
          Text(
            'Travel Time: ${_formatTime(request.travelTime)}',
            style: OrbitLiveTextStyles.bodyMedium,
          ),
          if (request.message != null) ...[
            const SizedBox(height: 8),
            Text(
              'Message: ${request.message}',
              style: OrbitLiveTextStyles.bodySmall.copyWith(
                color: OrbitLiveColors.darkGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _respondToRequest(request, true, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _respondToRequest(request, false, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveConnectionsTab() {
    return Consumer<TravelBuddyProvider>(
      builder: (context, provider, child) {
        if (provider.activeConnections.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No Active Connections',
            subtitle: 'Connected travel buddies will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.activeConnections.length,
          itemBuilder: (context, index) {
            final connection = provider.activeConnections[index];
            return _buildConnectionCard(connection, provider);
          },
        );
      },
    );
  }

  Widget _buildConnectionCard(TravelBuddyConnection connection, TravelBuddyProvider provider) {
    final buddy = provider.getBuddyProfile(connection);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                child: Text(
                  buddy?.name.substring(0, 1).toUpperCase() ?? '?',
                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buddy?.name ?? 'Unknown Buddy',
                      style: OrbitLiveTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Add gender information if available
                    if (buddy != null && buddy.genderPreference != GenderPreference.any)
                      Text(
                        _getGenderText(buddy.genderPreference),
                        style: OrbitLiveTextStyles.bodySmall.copyWith(
                          color: _getGenderColor(buddy.genderPreference),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Text(
                      'Connected • ${connection.route}',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIVE',
                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openChat(connection),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrbitLiveColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewLocation(connection),
                  icon: const Icon(Icons.location_on_outlined, size: 18),
                  label: const Text('Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OrbitLiveColors.primaryTeal,
                    side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _disconnectBuddy(connection, provider),
                icon: const Icon(Icons.close),
                color: Colors.red,
                tooltip: 'Disconnect',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: OrbitLiveColors.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: OrbitLiveColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: OrbitLiveTextStyles.bodyMedium.copyWith(
                color: OrbitLiveColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for travel buddies...'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatchesFound() {
    return _buildEmptyState(
      icon: Icons.search_off,
      title: 'No Matches Found',
      subtitle: 'Try adjusting your route or travel time',
    );
  }

  Widget _buildSearchPrompt() {
    return _buildEmptyState(
      icon: Icons.search,
      title: 'Find Your Travel Buddy',
      subtitle: 'Enter your route (e.g., Guntur Central to Tenali) and travel time to find companions',
    );
  }

  Widget _buildSOSButton() {
    return Consumer<TravelBuddyProvider>(
      builder: (context, provider, child) {
        if (!provider.hasActiveConnections) return const SizedBox.shrink();
        
        return FloatingActionButton(
          onPressed: _sendSOSAlert,
          backgroundColor: Colors.red,
          child: const Icon(
            Icons.emergency,
            color: Colors.white,
          ),
        );
      },
    );
  }

  // Helper methods
  bool _canSearch() {
    return _sourceController.text.isNotEmpty && 
           _destinationController.text.isNotEmpty && 
           _selectedTravelTime != null;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTravelTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        final now = DateTime.now();
        _selectedTravelTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _sendBuddyRequest(TravelBuddyProfile buddy, TravelBuddyProvider provider) async {
    final success = await provider.sendBuddyRequest(receiverId: buddy.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buddy request sent to ${buddy.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _respondToRequest(BuddyRequest request, bool accept, TravelBuddyProvider provider) async {
    final success = await provider.respondToBuddyRequest(
      requestId: request.id,
      accept: accept,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Request accepted!' : 'Request declined'),
          backgroundColor: accept ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _viewBuddyProfile(TravelBuddyProfile buddy) {
    // TODO: Navigate to buddy profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${buddy.name}\'s profile')),
    );
  }

  void _openChat(TravelBuddyConnection connection) {
    // TODO: Navigate to chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening chat...')),
    );
  }

  void _viewLocation(TravelBuddyConnection connection) {
    // TODO: Navigate to location sharing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing buddy location...')),
    );
  }

  Future<void> _disconnectBuddy(TravelBuddyConnection connection, TravelBuddyProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Buddy'),
        content: const Text('Are you sure you want to disconnect from this travel buddy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await provider.disconnectBuddy(connection.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disconnected from travel buddy'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _sendSOSAlert() async {
    // TODO: Get current location
    final location = TravelBuddyLocation(
      latitude: 0.0, // Replace with actual location
      longitude: 0.0, // Replace with actual location
      timestamp: DateTime.now(),
    );
    
    final provider = Provider.of<TravelBuddyProvider>(context, listen: false);
    final success = await provider.sendSOSAlert(location: location);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS alert sent to your travel buddy!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper methods to display gender information
  String _getGenderText(GenderPreference gender) {
    switch (gender) {
      case GenderPreference.male:
        return 'Male';
      case GenderPreference.female:
        return 'Female';
      case GenderPreference.any:
        return '';
    }
  }

  Color _getGenderColor(GenderPreference gender) {
    switch (gender) {
      case GenderPreference.male:
        return Colors.blue;
      case GenderPreference.female:
        return Colors.pink;
      case GenderPreference.any:
        return Colors.transparent;
    }
  }
}