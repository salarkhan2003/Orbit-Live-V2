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
    
    // Remove rotation animation - keep it at 0
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    // Start shimmer animation
    _shimmerController.repeat();
    
    // Don't start rotation animation - keep it at 0
    // _rotationController.repeat(reverse: true);
    
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
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getPassColor().withValues(alpha: 0.3 * _glowAnimation.value),
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
                                Colors.white.withValues(alpha: 0.3),
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
                    padding: const EdgeInsets.all(16),
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
                                    letterSpacing: 2,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'TRANSPORT PASS',
                                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Holder name
                        Text(
                          widget.pass.holderName.toUpperCase(),
                          style: OrbitLiveTextStyles.cardTitle.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        Text(
                          widget.pass.categoryDisplayName.toUpperCase(),
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1,
                            fontSize: 12,
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
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  widget.pass.id.substring(0, 8).toUpperCase(),
                                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'VALID UNTIL',
                                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${widget.pass.validUntil.day.toString().padLeft(2, '0')}/${widget.pass.validUntil.month.toString().padLeft(2, '0')}/${widget.pass.validUntil.year}',
                                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            
                            // QR Code
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: widget.pass.qrCode,
                                version: QrVersions.auto,
                                size: 50,
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
                    top: 16,
                    right: 16,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _glowAnimation.value),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.4),
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
                    bottom: 24,
                    left: 24,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.6 + (0.4 * _glowAnimation.value),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
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

  Widget _buildFrontCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            OrbitLiveColors.primaryTeal,
            OrbitLiveColors.primaryTeal.withValues(alpha: 0.8),
            OrbitLiveColors.primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: HologramPatternPainter(),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
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
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'TRANSPORT PASS',
                          style: OrbitLiveTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                
                const SizedBox(height: 16),
                
                // Holder name
                Text(
                  widget.pass.holderName.toUpperCase(),
                  style: OrbitLiveTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  widget.pass.categoryDisplayName.toUpperCase(),
                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1,
                    fontSize: 12,
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
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          widget.pass.id.substring(0, 8).toUpperCase(),
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'VALID UNTIL',
                          style: OrbitLiveTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${widget.pass.validUntil.day.toString().padLeft(2, '0')}/${widget.pass.validUntil.month.toString().padLeft(2, '0')}/${widget.pass.validUntil.year}',
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: widget.pass.qrCode,
                        version: QrVersions.auto,
                        size: 50,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          OrbitLiveColors.primaryTeal.withValues(alpha: 0.8),
          OrbitLiveColors.primaryBlue,
        ];
      case PassCategory.student:
        return [
          Colors.blue,
          Colors.blue.withValues(alpha: 0.8),
          Colors.lightBlue,
        ];
      case PassCategory.senior:
        return [
          Colors.purple,
          Colors.purple.withValues(alpha: 0.8),
          Colors.deepPurple,
        ];
      case PassCategory.employee:
        return [
          Colors.orange,
          Colors.orange.withValues(alpha: 0.8),
          Colors.deepOrange,
        ];
    }
  }
}

class TopographicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
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

class HologramPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw diagonal lines
    for (int i = 0; i < (size.width + size.height).toInt(); i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset((i - size.height).toDouble(), size.height),
        paint,
      );
    }

    // Draw circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          size.width * 0.2 + (i * size.width * 0.15),
          size.height * 0.3 + (i * size.height * 0.1),
        ),
        15,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}