import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../shared/orbit_live_colors.dart';
import '../../../../shared/orbit_live_text_styles.dart';
import '../../domain/pass_models.dart';

class AnimatedPassCard extends StatefulWidget {
  final BusPass pass;

  const AnimatedPassCard({
    super.key,
    required this.pass,
  });

  @override
  State<AnimatedPassCard> createState() => _AnimatedPassCardState();
}

class _AnimatedPassCardState extends State<AnimatedPassCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _rotationController;
  late AnimationController _glowController;
  
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    // Start shimmer animation
    _shimmerController.repeat();
    
    // Start subtle rotation animation
    _rotationController.repeat(reverse: true);
    
    // Start glow animation
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerAnimation, _rotationAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            height: 240,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getPassColor().withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 25 * _glowAnimation.value,
                  spreadRadius: 8 * _glowAnimation.value,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Base gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getGradientColors(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  
                  // Topographic pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TopographicPatternPainter(),
                    ),
                  ),
                  
                  // Shimmer effect
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Transform.translate(
                        offset: Offset(_shimmerAnimation.value * 300, 0),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ORBIT LIVE',
                                  style: OrbitLiveTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                  ),
                                ),
                                Text(
                                  'TRANSPORT PASS',
                                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.pass.typeDisplayName.toUpperCase(),
                                style: OrbitLiveTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Holder name
                        Text(
                          widget.pass.holderName.toUpperCase(),
                          style: OrbitLiveTextStyles.cardTitle.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          widget.pass.categoryDisplayName.toUpperCase(),
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Bottom section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Pass details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PASS ID',
                                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  widget.pass.id.substring(0, 8).toUpperCase(),
                                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'VALID UNTIL',
                                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  '${widget.pass.validUntil.day.toString().padLeft(2, '0')}/${widget.pass.validUntil.month.toString().padLeft(2, '0')}/${widget.pass.validUntil.year}',
                                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            // QR Code
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: widget.pass.qrCode,
                                version: QrVersions.auto,
                                size: 60,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Floating elements
                  Positioned(
                    top: 20,
                    right: 20,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _glowAnimation.value),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  blurRadius: 8 * _glowAnimation.value,
                                  spreadRadius: 2 * _glowAnimation.value,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  Positioned(
                    bottom: 30,
                    left: 30,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.6 + (0.4 * _glowAnimation.value),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 6 * _glowAnimation.value,
                                  spreadRadius: 1 * _glowAnimation.value,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPassColor() {
    switch (widget.pass.category) {
      case PassCategory.general:
        return OrbitLiveColors.primaryTeal;
      case PassCategory.student:
        return Colors.blue;
      case PassCategory.senior:
        return Colors.purple;
      case PassCategory.employee:
        return Colors.orange;
    }
  }

  List<Color> _getGradientColors() {
    switch (widget.pass.category) {
      case PassCategory.general:
        return [
          OrbitLiveColors.primaryTeal,
          OrbitLiveColors.primaryTeal.withOpacity(0.8),
          OrbitLiveColors.primaryBlue,
        ];
      case PassCategory.student:
        return [
          Colors.blue,
          Colors.blue.withOpacity(0.8),
          Colors.lightBlue,
        ];
      case PassCategory.senior:
        return [
          Colors.purple,
          Colors.purple.withOpacity(0.8),
          Colors.deepPurple,
        ];
      case PassCategory.employee:
        return [
          Colors.orange,
          Colors.orange.withOpacity(0.8),
          Colors.deepOrange,
        ];
    }
  }
}

class TopographicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw topographic waves
    for (int i = 0; i < 8; i++) {
      final path = Path();
      final amplitude = 20.0 + (i * 5);
      final frequency = 0.02 + (i * 0.005);
      
      path.moveTo(0, size.height * 0.3 + (i * 15));
      
      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height * 0.3 + (i * 15) + 
                  amplitude * math.sin(frequency * x);
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, paint);
    }

    // Draw geometric patterns
    for (int i = 0; i < 5; i++) {
      final rect = Rect.fromLTWH(
        size.width * 0.7 + (i * 8),
        size.height * 0.1 + (i * 12),
        6,
        6,
      );
      canvas.drawRect(rect, paint);
    }

    // Draw circles
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.7 + (i * 20)),
        8 + (i * 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

