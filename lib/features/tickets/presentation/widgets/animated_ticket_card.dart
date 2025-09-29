import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../shared/orbit_live_colors.dart';
import '../../../../shared/orbit_live_text_styles.dart';
import '../../domain/ticket_models.dart';

class AnimatedTicketCard extends StatefulWidget {
  final Ticket ticket;

  const AnimatedTicketCard({
    super.key,
    required this.ticket,
  });

  @override
  State<AnimatedTicketCard> createState() => _AnimatedTicketCardState();
}

class _AnimatedTicketCardState extends State<AnimatedTicketCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  
  late Animation<double> _flipAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _floatAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    // Start glow animation
    _glowController.repeat(reverse: true);
    
    // Start float animation
    _floatController.repeat(reverse: true);
    
    // Auto flip after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _flipCard();
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _glowAnimation, _floatAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: OrbitLiveColors.primaryTeal.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final isShowingFront = _flipAnimation.value < 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value * 3.14159),
                    child: isShowingFront ? _buildFrontCard() : _buildBackCard(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            OrbitLiveColors.primaryTeal,
            OrbitLiveColors.primaryTeal.withOpacity(0.8),
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
                    Text(
                      'ORBIT LIVE',
                      style: OrbitLiveTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.ticket.typeDisplayName.toUpperCase(),
                        style: OrbitLiveTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Route info
                Text(
                  widget.ticket.routeName,
                  style: OrbitLiveTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FROM',
                            style: OrbitLiveTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            widget.ticket.source,
                            style: OrbitLiveTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TO',
                            style: OrbitLiveTextStyles.bodySmall.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            widget.ticket.destination,
                            style: OrbitLiveTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Bottom info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TICKET ID',
                          style: OrbitLiveTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          widget.ticket.id.substring(0, 8).toUpperCase(),
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'FARE',
                          style: OrbitLiveTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '₹${widget.ticket.fare.toStringAsFixed(0)}',
                          style: OrbitLiveTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tap indicator
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TAP TO FLIP',
                style: OrbitLiveTextStyles.bodySmall.copyWith(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              OrbitLiveColors.primaryBlue,
              OrbitLiveColors.primaryBlue.withOpacity(0.8),
              OrbitLiveColors.primaryTeal,
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
                children: [
                  // QR Code section
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: OrbitLiveColors.primaryTeal.withOpacity(0.3 * _glowAnimation.value),
                                        blurRadius: 10 * _glowAnimation.value,
                                        spreadRadius: 2 * _glowAnimation.value,
                                      ),
                                    ],
                                  ),
                                  child: QrImageView(
                                    data: widget.ticket.qrCode,
                                    version: QrVersions.auto,
                                    size: 120,
                                    backgroundColor: Colors.white,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'SCAN TO VALIDATE',
                              style: OrbitLiveTextStyles.bodySmall.copyWith(
                                color: OrbitLiveColors.darkGray,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Validity info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Valid From:',
                              style: OrbitLiveTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${widget.ticket.validFrom.day}/${widget.ticket.validFrom.month}/${widget.ticket.validFrom.year}',
                              style: OrbitLiveTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Valid Until:',
                              style: OrbitLiveTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${widget.ticket.validUntil.day}/${widget.ticket.validUntil.month}/${widget.ticket.validUntil.year}',
                              style: OrbitLiveTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HologramPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw geometric pattern
    for (int i = 0; i < 10; i++) {
      final path = Path();
      final startX = (size.width / 10) * i;
      final startY = 0.0;
      
      path.moveTo(startX, startY);
      path.lineTo(startX + 20, size.height * 0.3);
      path.lineTo(startX + 40, size.height * 0.6);
      path.lineTo(startX + 60, size.height);
      
      canvas.drawPath(path, paint);
    }

    // Draw circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2 * (i + 1)),
        10 + (i * 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}