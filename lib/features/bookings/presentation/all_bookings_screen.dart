import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/booking_card.dart';
import 'providers/booking_provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AllBookingsScreen extends StatefulWidget {
  const AllBookingsScreen({super.key});

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load bookings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.subscribeToBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              // Header
              const AppHeader(
                title: 'My Bookings',
                subtitle: 'View your tickets and passes',
                showBackButton: true,
              ),
              
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: OrbitLiveColors.primaryTeal,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: OrbitLiveColors.darkGray,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
              
              // Bookings list
              Expanded(
                child: Consumer<BookingProvider>(
                  builder: (context, bookingProvider, child) {
                    if (bookingProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: OrbitLiveColors.primaryTeal,
                        ),
                      );
                    }
                    
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // Active bookings
                        _buildBookingList(
                          bookingProvider.getActiveBookings(),
                          'No active bookings',
                          'Your active tickets and passes will appear here',
                        ),
                        
                        // Booking history
                        _buildBookingList(
                          bookingProvider.getBookingHistory(),
                          'No booking history',
                          'Your past bookings will appear here',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<dynamic> bookings,
    String emptyTitle,
    String emptyMessage,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: OrbitLiveTextStyles.cardTitle,
            ),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              style: OrbitLiveTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(
          booking: bookings[index],
          onTap: () {
            // Handle booking tap
            _showBookingDetails(bookings[index]);
          },
        );
      },
    );
  }

  void _showBookingDetails(dynamic booking) {
    // Show booking details in a dialog or new screen
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${booking.type.name.toUpperCase()} Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${booking.id}'),
              Text('From: ${booking.source}'),
              Text('To: ${booking.destination}'),
              Text('Date: ${booking.travelDate}'),
              Text('Fare: ₹${booking.fare.toStringAsFixed(2)}'),
              Text('Status: ${booking.status.name}'),
              if (booking.qrCode != null) ...[
                const SizedBox(height: 16),
                Text('QR Code:'),
                QrImageView(
                  data: booking.qrCode!,
                  version: QrVersions.auto,
                  size: 100,
                  gapless: false,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}