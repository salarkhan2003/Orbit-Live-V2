import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';
import '../domain/ticket_models.dart';
import '../domain/popular_routes.dart';
import 'widgets/animated_ticket_card.dart';
import 'widgets/payment_method_selector.dart';
import 'providers/ticket_provider.dart';
import '../../payments/presentation/payment_options_screen.dart';

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

  // Add distance calculation
  double _calculatedDistance = 0.0;

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
              style: OrbitLiveTextStyles.displaySmall.copyWith(
                color: OrbitLiveColors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Source field with enhanced styling
            _buildEnhancedLocationField(
              controller: _sourceController,
              label: 'From',
              hint: 'Enter starting point',
              icon: Icons.location_on,
            ),
            
            const SizedBox(height: 20),
            
            // Destination field with enhanced styling
            _buildEnhancedLocationField(
              controller: _destinationController,
              label: 'To',
              hint: 'Enter destination',
              icon: Icons.location_on,
            ),
            
            const SizedBox(height: 30),
            
            // Popular routes section
            Text(
              'Popular Routes',
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: OrbitLiveColors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            // Route cards with enhanced styling
            _buildRouteCards(),
            
            const SizedBox(height: 30),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _sourceController.text.isNotEmpty && 
                         _destinationController.text.isNotEmpty
                    ? () => _nextStep()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrbitLiveColors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                ),
                child: Text(
                  'Continue',
                  style: OrbitLiveTextStyles.buttonPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLocationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: OrbitLiveColors.primaryTeal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          labelStyle: TextStyle(
            color: OrbitLiveColors.black,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCards() {
    // Get popular routes with RTC provided fixed fares
    final routes = PopularRoutesData.getGunturRoutes();
    
    return Column(
      children: routes.map((route) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: OrbitLiveColors.tealGradient,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_bus, color: Colors.white),
            ),
            title: Text(
              route.name,
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: OrbitLiveColors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  '${route.source} → ${route.destination}',
                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                    color: OrbitLiveColors.darkGray,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      '${route.estimatedDuration.inMinutes} mins',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(Icons.linear_scale, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      '${route.distanceInKm.toStringAsFixed(1)} km',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(Icons.currency_rupee, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      '₹${route.fare.toStringAsFixed(0)}',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'RTC Fixed Fare',
                  style: OrbitLiveTextStyles.caption.copyWith(
                    color: OrbitLiveColors.primaryTeal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              _sourceController.text = route.source;
              _destinationController.text = route.destination;
              
              setState(() {
                _selectedRoute = BusRoute(
                  id: route.id,
                  name: route.name,
                  source: route.source,
                  destination: route.destination,
                  stops: [], // Empty for now
                  estimatedDuration: route.estimatedDuration,
                  fare: route.fare,
                  timings: route.timings,
                );
              });
              
              _nextStep();
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTicketTypeStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Ticket Type',
              style: OrbitLiveTextStyles.displaySmall.copyWith(
                color: OrbitLiveColors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Ticket type cards
            _buildTicketTypeCards(),
            
            const SizedBox(height: 30),
            
            // Selected route info
            if (_selectedRoute != null) ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Route',
                      style: OrbitLiveTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: OrbitLiveColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.route, color: OrbitLiveColors.primaryTeal),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedRoute!.source} → ${_selectedRoute!.destination}',
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: OrbitLiveColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Duration: ${_selectedRoute!.estimatedDuration.inMinutes} mins',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Fare: ₹${_selectedRoute!.fare.toStringAsFixed(2)}',
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedTicketType != null ? () => _nextStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrbitLiveColors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                ),
                child: Text(
                  'Continue',
                  style: OrbitLiveTextStyles.buttonPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTypeCards() {
    final ticketTypes = [
      {
        'type': TicketType.oneTime,
        'title': 'One-time Ticket',
        'description': 'Valid for a single journey',
        'icon': Icons.confirmation_number,
      },
      {
        'type': TicketType.returnTrip,
        'title': 'Return Ticket',
        'description': 'Valid for onward and return journey',
        'icon': Icons.swap_horiz,
      },
      {
        'type': TicketType.multiRide,
        'title': 'Multi-ride Pass',
        'description': 'Valid for 10 journeys',
        'icon': Icons.repeat,
      },
    ];
    
    return Column(
      children: ticketTypes.map((ticketType) {
        final isSelected = _selectedTicketType == ticketType['type'];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: OrbitLiveColors.tealGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isSelected
                ? Border.all(color: OrbitLiveColors.primaryTeal, width: 2)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : OrbitLiveColors.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ticketType['icon'] as IconData,
                color: isSelected ? Colors.white : OrbitLiveColors.primaryTeal,
              ),
            ),
            title: Text(
              ticketType['title'] as String,
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : OrbitLiveColors.black,
              ),
            ),
            subtitle: Text(
              ticketType['description'] as String,
              style: OrbitLiveTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white70 : OrbitLiveColors.darkGray,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.white)
                : null,
            onTap: () {
              setState(() {
                _selectedTicketType = ticketType['type'] as TicketType;
              });
              
              // Update payment amount when ticket type changes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
            },
          ),
        );
      }).toList(),
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
                  OrbitLiveColors.primaryTeal.withValues(alpha: 0.7),
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
                  color: Colors.green.withValues(alpha: 0.3),
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
                  color: Colors.black.withValues(alpha: 0.05),
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

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
        return basePrice * 2 * 0.9; // 10% discount on return trip (2 tickets)
      case TicketType.multiRide:
        return basePrice * 5 * 0.8; // 20% discount for 5 rides
    }
  }

  Future<void> _processPayment() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    // For Cashfree payment method, show the payment options screen
    if (_selectedPaymentMethod == PaymentMethod.upi) {
      // Show payment options screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentOptionsScreen(
            distanceInKm: _calculatedDistance,
            source: _sourceController.text,
            destination: _destinationController.text,
            onPaymentSuccess: () {
              // This will be called when payment is successful
            },
          ),
        ),
      );
      
      // If payment was successful, generate the ticket
      if (result == true) {
        await ticketProvider.processUpiPayment(
          route: _selectedRoute!,
          ticketType: _selectedTicketType!,
          distanceInKm: _calculatedDistance,
          source: _sourceController.text,
          destination: _destinationController.text,
        );
      }
    } else {
      // For other payment methods, use the existing process
      await ticketProvider.processPayment(
        route: _selectedRoute!,
        ticketType: _selectedTicketType!,
        paymentDetails: _paymentDetails!,
        source: _sourceController.text,
        destination: _destinationController.text,
        distanceInKm: _calculatedDistance,
      );
    }
  }

  // Add distance calculation method
  Future<double> _calculateDistance(String source, String destination) async {
    try {
      // For demo purposes, we'll use a simple approximation
      // In a real app, you would use Google Maps API or similar service
      
      // Mock distance calculation based on popular routes
      final routes = PopularRoutesData.getGunturRoutes();
      for (final route in routes) {
        if ((route.source.toLowerCase().contains(source.toLowerCase()) && 
             route.destination.toLowerCase().contains(destination.toLowerCase())) ||
            (route.source.toLowerCase().contains(destination.toLowerCase()) && 
             route.destination.toLowerCase().contains(source.toLowerCase()))) {
          return route.distanceInKm;
        }
      }
      
      // If route not found in popular routes, return a default distance
      return 10.0;
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return 10.0; // Default distance
    }
  }

  // Update the _proceedToPayment method
  Future<void> _proceedToPayment() async {
    if (_selectedRoute == null || _selectedTicketType == null) return;

    // Calculate distance for custom routes or use route distance for popular routes
    double distanceInKm;
    if (_selectedRoute!.fare > 0) {
      // Use fare from route to calculate distance (reverse calculation)
      distanceInKm = (_selectedRoute!.fare - 5.0) / 2.0;
    } else {
      // Calculate distance for custom routes
      distanceInKm = await _calculateDistance(
        _sourceController.text, 
        _destinationController.text
      );
    }

    setState(() {
      _calculatedDistance = distanceInKm;
    });

    // Show payment options screen with distance
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentOptionsScreen(
          distanceInKm: distanceInKm,
          source: _sourceController.text,
          destination: _destinationController.text,
          onPaymentSuccess: () {
            // Handle payment success
            _showBookingSuccess();
          },
        ),
      ),
    );

    if (result == true) {
      // Payment was successful, generate ticket
      await _generateTicket(distanceInKm);
    }
  }

  // Update the _generateTicket method to use distance
  Future<void> _generateTicket(double distanceInKm) async {
    if (_selectedRoute == null || _selectedTicketType == null) return;

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    try {
      if (_selectedPaymentMethod == PaymentMethod.upi) {
        await ticketProvider.processUpiPayment(
          route: _selectedRoute!,
          ticketType: _selectedTicketType!,
          distanceInKm: distanceInKm,
          source: _sourceController.text,
          destination: _destinationController.text,
        );
      } else {
        // Handle other payment methods
        final paymentDetails = PaymentDetails(
          method: _selectedPaymentMethod!,
          amount: 5.0 + (distanceInKm * 2.0),
          transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        await ticketProvider.processPayment(
          route: _selectedRoute!,
          ticketType: _selectedTicketType!,
          paymentDetails: paymentDetails,
          source: _sourceController.text,
          destination: _destinationController.text,
          distanceInKm: distanceInKm,
        );
      }
      
      // Move to confirmation step
      _pageController.animateToPage(
        3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add the missing _showBookingSuccess method
  void _showBookingSuccess() {
    // Move to confirmation step
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}