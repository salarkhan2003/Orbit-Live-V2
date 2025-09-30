import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/pass_models.dart';
import '../presentation/providers/pass_provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../presentation/widgets/animated_pass_card.dart';

class AllPassesScreen extends StatelessWidget {
  const AllPassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Passes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
      ),
      body: Consumer<PassProvider>(
        builder: (context, passProvider, child) {
          // Generate mock passes if none exist
          final passes = passProvider.passes.isEmpty 
              ? _generateMockPasses() 
              : passProvider.passes;
          
          if (passes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_membership_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No passes found',
                    style: OrbitLiveTextStyles.cardTitle.copyWith(
                      color: OrbitLiveColors.mediumGray,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Apply for passes to see them here',
                    style: OrbitLiveTextStyles.bodyMedium.copyWith(
                      color: OrbitLiveColors.darkGray,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: passes.length,
            itemBuilder: (context, index) {
              final pass = passes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: AnimatedPassCard(pass: pass),
              );
            },
          );
        },
      ),
    );
  }
  
  List<BusPass> _generateMockPasses() {
    return [
      BusPass(
        id: 'PASS1001',
        holderName: 'John Doe',
        holderPhoto: '',
        type: PassType.monthly,
        category: PassCategory.general,
        status: PassStatus.active,
        applicationDate: DateTime.now().subtract(const Duration(days: 30)),
        validFrom: DateTime.now().subtract(const Duration(days: 25)),
        validUntil: DateTime.now().add(const Duration(days: 5)),
        fare: 300.0,
        qrCode: 'QR1001',
        validRoutes: ['Route 101', 'Route 202'],
      ),
      BusPass(
        id: 'PASS1002',
        holderName: 'Jane Smith',
        holderPhoto: '',
        type: PassType.quarterly,
        category: PassCategory.student,
        status: PassStatus.expired,
        applicationDate: DateTime.now().subtract(const Duration(days: 90)),
        validFrom: DateTime.now().subtract(const Duration(days: 80)),
        validUntil: DateTime.now().subtract(const Duration(days: 10)),
        fare: 637.5,
        qrCode: 'QR1002',
        validRoutes: ['Route 303', 'Route 404'],
      ),
      BusPass(
        id: 'PASS1003',
        holderName: 'Robert Johnson',
        holderPhoto: '',
        type: PassType.annual,
        category: PassCategory.employee,
        status: PassStatus.active,
        applicationDate: DateTime.now().subtract(const Duration(days: 5)),
        validFrom: DateTime.now().subtract(const Duration(days: 2)),
        validUntil: DateTime.now().add(const Duration(days: 363)),
        fare: 3600.0,
        qrCode: 'QR1003',
        validRoutes: ['All Routes'],
      ),
    ];
  }
}