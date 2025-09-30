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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: OrbitLiveColors.primaryTeal.withValues(alpha: 0.3 * _glowAnimation.value),
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
                    child: isShowingFront 
                        ? _buildFrontCard() 
                        : Transform(
                            transform: Matrix4.rotationY(3.14159), // Flip the back content to make it readable
                            alignment: Alignment.center,
                            child: _buildBackCard(),
                          ),
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
                        color: Colors.white.withValues(alpha: 0.2),
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
                
                const SizedBox(height: 16),
                
                // Route info
                Text(
                  '${widget.ticket.source} → ${widget.ticket.destination}',
                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Date and time
                Text(
                  '${widget.ticket.validFrom.day.toString().padLeft(2, '0')}/${widget.ticket.validFrom.month.toString().padLeft(2, '0')}/${widget.ticket.validFrom.year} • ${widget.ticket.validFrom.hour.toString().padLeft(2, '0')}:${widget.ticket.validFrom.minute.toString().padLeft(2, '0')}',
                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                
                const Spacer(),
                
                // Bus info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route',
                          style: OrbitLiveTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          widget.ticket.routeName,
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seat',
                          style: OrbitLiveTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          widget.ticket.seatNumber ?? 'N/A',
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fare',
                          style: OrbitLiveTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '₹${widget.ticket.fare.toStringAsFixed(2)}',
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
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
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade100,
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
                        color: OrbitLiveColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: OrbitLiveColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.ticket.typeDisplayName.toUpperCase(),
                        style: OrbitLiveTextStyles.bodySmall.copyWith(
                          color: OrbitLiveColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // QR Code
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: widget.ticket.qrCode,
                      version: QrVersions.auto,
                      size: 120,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Validation text
                Text(
                  'Show this QR code to the conductor for validation',
                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                    color: OrbitLiveColors.darkGray,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Ticket ID
                Text(
                  'Ticket ID: ${widget.ticket.id.substring(0, 8).toUpperCase()}',
                  style: OrbitLiveTextStyles.bodySmall.copyWith(
                    color: OrbitLiveColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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