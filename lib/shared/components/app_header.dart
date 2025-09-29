import 'package:flutter/material.dart';
import '../orbit_live_colors.dart';
import '../orbit_live_text_styles.dart';
import '../orbit_live_animations.dart';

/// A consistent header component for Orbit Live branding across authentication screens
class AppHeader extends StatelessWidget {
  /// The main title to display
  final String title;
  
  /// Optional subtitle text
  final String? subtitle;
  
  /// Whether to show a back button
  final bool showBackButton;
  
  /// Custom back button callback
  final VoidCallback? onBackPressed;
  
  /// Whether to center the content
  final bool centerContent;
  
  /// Additional padding around the header
  final EdgeInsets? padding;
  
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.centerContent = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with back button and logo
          Row(
            children: [
              // Back button
              if (showBackButton)
                _buildBackButton(context)
              else
                const SizedBox(width: 48), // Spacer for alignment
              
              // Logo and title section
              Expanded(
                child: _buildLogoSection(),
              ),
              
              // Right spacer for symmetry
              const SizedBox(width: 48),
            ],
          ),
          
          // Subtitle if provided
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            _buildSubtitle(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildBackButton(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onBackPressed ?? () => Navigator.of(context).pop(),
          child: Semantics(
            label: 'Go back',
            hint: 'Navigate to previous screen',
            button: true,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Orbit Live Logo
        _buildLogo(),
        
        const SizedBox(height: 12),
        
        // Title
        Semantics(
          header: true,
          child: Text(
            title,
            style: OrbitLiveTextStyles.headerTitle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: OrbitLiveColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/ORBIT LIVE APP ICON.jpg',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image fails to load
            return Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: OrbitLiveColors.tealGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildSubtitle() {
    return Text(
      subtitle!,
      style: OrbitLiveTextStyles.headerSubtitle,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// A simplified version of AppHeader for minimal branding
class AppHeaderMinimal extends StatelessWidget {
  /// The title to display
  final String title;
  
  /// Whether to show a back button
  final bool showBackButton;
  
  /// Custom back button callback
  final VoidCallback? onBackPressed;
  
  const AppHeaderMinimal({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          // Back button
          if (showBackButton)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 40),
          
          // Title
          Expanded(
            child: Text(
              title,
              style: OrbitLiveTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Right spacer
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// An animated version of AppHeader with entrance animations
class AppHeaderAnimated extends StatefulWidget {
  /// The main title to display
  final String title;
  
  /// Optional subtitle text
  final String? subtitle;
  
  /// Whether to show a back button
  final bool showBackButton;
  
  /// Custom back button callback
  final VoidCallback? onBackPressed;
  
  /// Animation delay before starting
  final Duration delay;
  
  const AppHeaderAnimated({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.delay = Duration.zero,
  });

  @override
  State<AppHeaderAnimated> createState() => _AppHeaderAnimatedState();
}

class _AppHeaderAnimatedState extends State<AppHeaderAnimated>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: OrbitLiveAnimations.standardDuration,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: OrbitLiveAnimations.mediumDuration,
      vsync: this,
    );
    
    _fadeAnimation = OrbitLiveAnimations.createFadeAnimation(_fadeController);
    _slideAnimation = OrbitLiveAnimations.createSlideAnimation(
      _slideController,
      begin: const Offset(0.0, -0.5),
    );
    
    // Start animations with delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AppHeader(
          title: widget.title,
          subtitle: widget.subtitle,
          showBackButton: widget.showBackButton,
          onBackPressed: widget.onBackPressed,
        ),
      ),
    );
  }
}