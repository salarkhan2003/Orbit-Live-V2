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

  /// Show the onboarding popup every time the user visits the TravelBuddy screen
  static Future<void> showIfNeeded(
    BuildContext context, {
    VoidCallback? onGetStarted,
  }) async {
    // Always show the popup when this method is called
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TravelBuddyOnboardingPopup(
          onClose: () {
            Navigator.of(context).pop();
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
    // Ensure the animation completes before closing
    _scaleController.reverse().whenComplete(() {
      if (mounted) {
        widget.onClose();
      }
    }).catchError((_) {
      // Fallback in case animation fails
      if (mounted) {
        widget.onClose();
      }
    });
  }

  void _handleGetStarted() {
    // Ensure the animation completes before closing
    _scaleController.reverse().whenComplete(() {
      if (mounted) {
        widget.onClose();
        widget.onGetStarted?.call();
      }
    }).catchError((_) {
      // Fallback in case animation fails
      if (mounted) {
        widget.onClose();
        widget.onGetStarted?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenSize.width * 0.9,
              maxHeight: screenSize.height * 0.7,
            ),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildContent(),
                  ),
                ),
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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: OrbitLiveColors.tealGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: _handleClose,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Find Your Perfect Travel Companion',
            style: OrbitLiveTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.people_outline,
            title: 'Connect with Fellow Travelers',
            description: 'Match with people traveling similar routes and times',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.security,
            title: 'Safe & Secure',
            description: 'Mutual consent connections with privacy protection',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.chat_bubble_outline,
            title: 'In-App Communication',
            description: 'Encrypted chat and voice calls with your travel buddy',
          ),
          const SizedBox(height: 16),
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
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: OrbitLiveColors.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: OrbitLiveColors.primaryTeal,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: OrbitLiveTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: OrbitLiveColors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: OrbitLiveTextStyles.bodyMedium.copyWith(
                  color: OrbitLiveColors.darkGray,
                  fontSize: 13,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: _handleGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: OrbitLiveColors.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Get Started',
                style: OrbitLiveTextStyles.buttonLarge.copyWith(
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleClose,
            style: TextButton.styleFrom(
              foregroundColor: OrbitLiveColors.darkGray,
            ),
            child: Text(
              'Maybe Later',
              style: OrbitLiveTextStyles.bodyMedium.copyWith(
                color: OrbitLiveColors.darkGray,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}