import 'package:flutter/material.dart';
import '../orbit_live_colors.dart';
import '../orbit_live_text_styles.dart';
import '../orbit_live_animations.dart';
import '../utils/responsive_helper.dart';

/// A card component for role selection with gradient backgrounds and 3D styling
class RoleCard extends StatefulWidget {
  /// The main title of the role
  final String title;
  
  /// Subtitle or description text
  final String subtitle;
  
  /// Gradient colors for the card background
  final List<Color> gradientColors;
  
  /// Icon or illustration widget
  final Widget illustration;
  
  /// Whether this card is currently selected
  final bool isSelected;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  /// Optional animation controller for external animations
  final AnimationController? animationController;
  
  /// Card width (defaults to responsive)
  final double? width;
  
  /// Card height
  final double height;
  
  /// Whether to show selection indicator
  final bool showSelectionIndicator;
  
  /// Custom elevation for the card
  final double elevation;
  
  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.illustration,
    required this.onTap,
    this.isSelected = false,
    this.animationController,
    this.width,
    this.height = 200,
    this.showSelectionIndicator = true,
    this.elevation = 8,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: OrbitLiveAnimations.fastDuration,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: OrbitLiveAnimations.standardDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: OrbitLiveAnimations.buttonPressCurve,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: OrbitLiveAnimations.pulseCurve,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(RoleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate glow when selection changes
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? ResponsiveHelper.getResponsiveMaxWidth(context),
            height: ResponsiveHelper.getResponsiveValue(
              context: context,
              mobile: widget.height,
              tablet: widget.height * 1.1,
              desktop: widget.height * 1.2,
            ),
            child: _buildCard(),
          ),
        );
      },
    );
  }
  
  Widget _buildCard() {
    return Semantics(
      label: '${widget.title} role',
      hint: 'Tap to select ${widget.title.toLowerCase()} role. ${widget.subtitle}',
      button: true,
      selected: widget.isSelected,
      onTap: widget.onTap,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            // Main shadow
            BoxShadow(
              color: widget.gradientColors.first.withValues(alpha: 0.3),
              blurRadius: ResponsiveHelper.getResponsiveElevation(context),
              offset: const Offset(0, 4),
            ),
            // Selection glow
            if (widget.isSelected && widget.showSelectionIndicator)
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 
                  0.4 * _glowAnimation.value,
                ),
                blurRadius: 20 + (10 * _glowAnimation.value),
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Container(
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection indicator
                  if (widget.showSelectionIndicator)
                    _buildSelectionIndicator(),
                  
                  // Illustration
                  Expanded(
                    child: Center(
                      child: widget.illustration,
                    ),
                  ),
                  
                  // Text content
                  _buildTextContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
  
  Widget _buildSelectionIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: OrbitLiveAnimations.standardDuration,
          curve: OrbitLiveAnimations.standardCurve,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isSelected 
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: widget.isSelected
              ? Semantics(
                  label: 'Selected',
                  child: const Icon(
                    Icons.check,
                    color: OrbitLiveColors.primaryTeal,
                    size: 16,
                  ),
                )
              : null,
        ),
      ],
    );
  }
  
  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: OrbitLiveTextStyles.cardTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: OrbitLiveTextStyles.cardSubtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// A specialized role card for passenger selection
class PassengerRoleCard extends StatelessWidget {
  /// Whether this card is selected
  final bool isSelected;
  
  /// Callback when tapped
  final VoidCallback onTap;
  
  /// Optional animation controller
  final AnimationController? animationController;
  
  const PassengerRoleCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      title: 'Passenger',
      subtitle: 'Book tickets and track buses',
      gradientColors: OrbitLiveColors.tealGradient,
      illustration: _buildPassengerIllustration(),
      isSelected: isSelected,
      onTap: onTap,
      animationController: animationController,
    );
  }
  
  Widget _buildPassengerIllustration() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}

/// A specialized role card for driver selection
class DriverRoleCard extends StatelessWidget {
  /// Whether this card is selected
  final bool isSelected;
  
  /// Callback when tapped
  final VoidCallback onTap;
  
  /// Optional animation controller
  final AnimationController? animationController;
  
  const DriverRoleCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return RoleCard(
      title: 'Driver',
      subtitle: 'Manage trips and routes',
      gradientColors: OrbitLiveColors.orangeGradient,
      illustration: _buildDriverIllustration(),
      isSelected: isSelected,
      onTap: onTap,
      animationController: animationController,
    );
  }
  
  Widget _buildDriverIllustration() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.directions_bus,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}

/// A container widget for organizing multiple role cards
class RoleCardGrid extends StatelessWidget {
  /// List of role cards to display
  final List<Widget> cards;
  
  /// Number of columns in the grid
  final int crossAxisCount;
  
  /// Spacing between cards
  final double spacing;
  
  /// Aspect ratio of each card
  final double childAspectRatio;
  
  const RoleCardGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: cards,
    );
  }
}

/// A horizontal layout for role cards
class RoleCardRow extends StatelessWidget {
  /// List of role cards to display
  final List<Widget> cards;
  
  /// Spacing between cards
  final double spacing;
  
  const RoleCardRow({
    super.key,
    required this.cards,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}