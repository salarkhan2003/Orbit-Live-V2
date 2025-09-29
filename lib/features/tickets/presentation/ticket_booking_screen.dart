import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../domain/ticket_models.dart';
import 'widgets/animated_ticket_card.dart';
import 'widgets/payment_method_selector.dart';
import 'providers/ticket_provider.dart';

class TicketBookingScreen extends StatefulWidget {
  const TicketBookingScreen({super.key});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form controllers
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  
  // Selected values
  BusRoute? _selectedRoute;
  TicketType? _selectedTicketType;
  PaymentMethod? _selectedPaymentMethod;
  PaymentDetails? _paymentDetails;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildJourneySelectionStep(),
                    _buildTicketTypeStep(),
                    _buildPaymentStep(),
                    _buildConfirmationStep(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: const AppHeader(
        title: 'Book Ticket',
        subtitle: 'Quick and easy bus booking',
        showBackButton: true,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? OrbitLiveColors.primaryTeal : Colors.grey.shade300,
                    border: Border.all(
                      color: isActive ? OrbitLiveColors.primaryTeal : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? OrbitLiveColors.primaryTeal : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildJourneySelectionStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Journey',
              style: OrbitLiveTextStyles.cardTitle.copyWith(
                fontSize: 24,
                color: OrbitLiveColors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Source field
            _buildLocationField(
              controller: _sourceController,
              label: 'From',
              hint: 'Enter starting point',
              icon: Icons.location_on,
            ),
            
            const SizedBox(height: 16),
            
            // Swap button
            Center(
              child: IconButton(
                onPressed: _swapLocations,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: OrbitLiveColors.primaryTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: OrbitLiveColors.primaryTeal,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Destination field
            _buildLocationField(
              controller: _destinationController,
              label: 'To',
              hint: 'Enter destination',
              icon: Icons.location_on,
            ),
            
            const SizedBox(height: 24),
            
            // Available routes
            if (_sourceController.text.isNotEmpty && _destinationController.text.isNotEmpty)
              _buildAvailableRoutes(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: OrbitLiveColors.primaryTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAvailableRoutes() {
    // Mock routes data
    final routes = [
      BusRoute(
        id: '1',
        name: 'Route 101',
        source: _sourceController.text,
        destination: _destinationController.text,
        stops: ['Stop A', 'Stop B', 'Stop C'],
        estimatedDuration: const Duration(minutes: 45),
        fare: 25.0,
        timings: ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'],
      ),
      BusRoute(
        id: '2',
        name: 'Express 202',
        source: _sourceController.text,
        destination: _destinationController.text,
        stops: ['Stop A', 'Stop C'],
        estimatedDuration: const Duration(minutes: 30),
        fare: 35.0,
        timings: ['09:00', '11:00', '13:00', '15:00', '17:00'],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Routes',
          style: OrbitLiveTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: OrbitLiveColors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...routes.map((route) => _buildRouteCard(route)),
      ],
    );
  }

  Widget _buildRouteCard(BusRoute route) {
    final isSelected = _selectedRoute?.id == route.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? OrbitLiveColors.primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRoute = route;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    route.name,
                    style: OrbitLiveTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${route.fare.toStringAsFixed(0)}',
                    style: OrbitLiveTextStyles.bodyLarge.copyWith(
                      color: OrbitLiveColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${route.estimatedDuration.inMinutes} min journey',
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: OrbitLiveColors.mediumGray,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: route.timings.take(4).map((time) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: OrbitLiveColors.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      time,
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: OrbitLiveColors.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Ticket Type',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 24,
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildTicketTypeCard(
            type: TicketType.oneTime,
            title: 'One-time Ticket',
            description: 'Single journey ticket',
            price: _selectedRoute?.fare ?? 0,
            icon: Icons.confirmation_number,
          ),
          
          _buildTicketTypeCard(
            type: TicketType.returnTrip,
            title: 'Return Ticket',
            description: 'Round trip with 10% discount',
            price: (_selectedRoute?.fare ?? 0) * 1.8,
            icon: Icons.repeat,
          ),
          
          _buildTicketTypeCard(
            type: TicketType.multiRide,
            title: 'Multi-ride Ticket',
            description: '5 journeys with 20% discount',
            price: (_selectedRoute?.fare ?? 0) * 4,
            icon: Icons.card_membership,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTypeCard({
    required TicketType type,
    required String title,
    required String description,
    required double price,
    required IconData icon,
  }) {
    final isSelected = _selectedTicketType == type;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? OrbitLiveColors.primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTicketType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OrbitLiveColors.primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: OrbitLiveColors.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: OrbitLiveTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: OrbitLiveTextStyles.bodyMedium.copyWith(
                        color: OrbitLiveColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: OrbitLiveTextStyles.bodyLarge.copyWith(
                  color: OrbitLiveColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 24,
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          PaymentMethodSelector(
            selectedMethod: _selectedPaymentMethod,
            onMethodSelected: (method) {
              setState(() {
                _selectedPaymentMethod = method;
              });
            },
            onPaymentDetailsChanged: (details) {
              setState(() {
                _paymentDetails = details;
              });
            },
            amount: _calculateTotalAmount(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        if (ticketProvider.isProcessingPayment) {
          return _buildPaymentProcessing();
        }
        
        if (ticketProvider.generatedTicket != null) {
          return _buildTicketGenerated(ticketProvider.generatedTicket!);
        }
        
        return _buildOrderSummary();
      },
    );
  }

  Widget _buildPaymentProcessing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  OrbitLiveColors.primaryTeal,
                  OrbitLiveColors.primaryTeal.withOpacity(0.7),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Payment...',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we confirm your payment',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketGenerated(Ticket ticket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Success animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Ticket Generated!',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 28,
              color: OrbitLiveColors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Your digital ticket is ready',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.mediumGray,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Animated ticket card
          AnimatedTicketCard(ticket: ticket),
          
          const SizedBox(height: 40),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share ticket
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                    foregroundColor: OrbitLiveColors.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: OrbitLiveColors.primaryTeal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 24,
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Route', _selectedRoute?.name ?? ''),
                _buildSummaryRow('From', _sourceController.text),
                _buildSummaryRow('To', _destinationController.text),
                _buildSummaryRow('Ticket Type', _selectedTicketType?.name ?? ''),
                _buildSummaryRow('Payment Method', _selectedPaymentMethod?.name ?? ''),
                const Divider(height: 32),
                _buildSummaryRow(
                  'Total Amount',
                  '₹${_calculateTotalAmount().toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: isTotal ? OrbitLiveColors.black : OrbitLiveColors.mediumGray,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: isTotal ? OrbitLiveColors.primaryTeal : OrbitLiveColors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                  foregroundColor: OrbitLiveColors.primaryTeal,
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _goToNextStep : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: OrbitLiveColors.primaryTeal,
                foregroundColor: Colors.white,
              ),
              child: Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  void _swapLocations() {
    final temp = _sourceController.text;
    _sourceController.text = _destinationController.text;
    _destinationController.text = temp;
    setState(() {});
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedRoute != null;
      case 1:
        return _selectedTicketType != null;
      case 2:
        return _selectedPaymentMethod != null && _paymentDetails != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Select Route';
      case 1:
        return 'Choose Payment';
      case 2:
        return 'Confirm & Pay';
      case 3:
        return 'Generate Ticket';
      default:
        return 'Next';
    }
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _processPayment();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double _calculateTotalAmount() {
    if (_selectedRoute == null || _selectedTicketType == null) return 0.0;
    
    double basePrice = _selectedRoute!.fare;
    switch (_selectedTicketType!) {
      case TicketType.oneTime:
        return basePrice;
      case TicketType.returnTrip:
        return basePrice * 1.8; // 10% discount
      case TicketType.multiRide:
        return basePrice * 4; // 20% discount for 5 rides
    }
  }

  Future<void> _processPayment() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    await ticketProvider.processPayment(
      route: _selectedRoute!,
      ticketType: _selectedTicketType!,
      paymentDetails: _paymentDetails!,
      source: _sourceController.text,
      destination: _destinationController.text,
    );
  }
}