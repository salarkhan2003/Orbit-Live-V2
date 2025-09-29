import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/orbit_live_colors.dart';
import '../../../../shared/orbit_live_text_styles.dart';
import '../../../../shared/orbit_live_animations.dart';

/// One-time onboarding popup for TravelBuddy feature
class TravelBuddyOnboardingPopup extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onGetStarted;

  const TravelBuddyOnboardingPopup({
    super.key,
    required this.onClose,
    this.onGetStarted,
  });

  /// Show the onboarding popup if it hasn't been shown before
  static Future<void> showIfNeeded(
    BuildContext context, {
    VoidCallback? onGetStarted,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('travel_buddy_onboarding_shown') ?? false;
    
    if (!hasShown && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TravelBuddyOnboardingPopup(
          onClose: () {
            Navigator.of(context).pop();
            _markAsShown();
          },
          onGetStarted: onGetStarted,
        ),
      );
    }
  }

  static Future<void> _markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('travel_buddy_onboarding_shown', true);
  }

  @override
  State<TravelBuddyOnboardingPopup> createState() => _TravelBuddyOnboardingPopupState();
}

class _TravelBuddyOnboardingPopupState extends State<TravelBuddyOnboardingPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: OrbitLiveAnimations.mediumDuration,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: OrbitLiveAnimations.standardDuration,
      vsync: this,
    );
    
    _scaleAnimation = OrbitLiveAnimations.createScaleAnimation(
      _scaleController,
      begin: 0.8,
      end: 1.0,
    );
    
    _fadeAnimation = OrbitLiveAnimations.createFadeAnimation(_fadeController);
  }
  
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scaleController.forward();
        _fadeController.forward();
      }
    });
  }

  void _handleClose() {
    _scaleController.reverse().then((_) {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  void _handleGetStarted() {
    _scaleController.reverse().then((_) {
      if (mounted) {
        widget.onClose();
        widget.onGetStarted?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildContent(),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: OrbitLiveColors.tealGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24), // Balance the close button
              Text(
                '🚌 TravelBuddy',
                style: OrbitLiveTextStyles.headerTitle.copyWith(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _handleClose,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Find Your Perfect Travel Companion',
            style: OrbitLiveTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.people_outline,
            title: 'Connect with Fellow Travelers',
            description: 'Match with people traveling similar routes and times',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            icon: Icons.security,
            title: 'Safe & Secure',
            description: 'Mutual consent connections with privacy protection',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            icon: Icons.chat_bubble_outline,
            title: 'In-App Communication',
            description: 'Encrypted chat and voice calls with your travel buddy',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            icon: Icons.emergency,
            title: 'Emergency SOS',
            description: 'One-tap emergency alert shared with your buddy',
          ),
        ],
      ),
    );
  } 
 Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: OrbitLiveColors.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: OrbitLiveColors.primaryTeal,
            size: 20,
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
                  color: OrbitLiveColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: OrbitLiveColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: OrbitLiveColors.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Get Started',
                style: OrbitLiveTextStyles.buttonLarge,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _handleClose,
            style: TextButton.styleFrom(
              foregroundColor: OrbitLiveColors.darkGray,
            ),
            child: Text(
              'Maybe Later',
              style: OrbitLiveTextStyles.bodyMedium.copyWith(
                color: OrbitLiveColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}