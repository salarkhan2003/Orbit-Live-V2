import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/ticket_models.dart';
import '../presentation/providers/ticket_provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../presentation/widgets/animated_ticket_card.dart';

class AllTicketsScreen extends StatelessWidget {
  const AllTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tickets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          // Generate mock tickets if none exist
          final tickets = ticketProvider.tickets.isEmpty 
              ? _generateMockTickets() 
              : ticketProvider.tickets;
          
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No tickets found',
                    style: OrbitLiveTextStyles.cardTitle.copyWith(
                      color: OrbitLiveColors.mediumGray,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Start booking tickets to see them here',
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
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: AnimatedTicketCard(ticket: ticket),
              );
            },
          );
        },
      ),
    );
  }
  
  List<Ticket> _generateMockTickets() {
    return [
      Ticket(
        id: 'TKT1001',
        routeId: '1',
        routeName: 'Guntur Central - Tenali',
        source: 'Guntur Central',
        destination: 'Tenali',
        type: TicketType.oneTime,
        status: TicketStatus.active,
        purchaseDate: DateTime.now().subtract(const Duration(days: 1)),
        validFrom: DateTime.now().subtract(const Duration(hours: 1)),
        validUntil: DateTime.now().add(const Duration(hours: 1)),
        fare: 25.0,
        qrCode: 'ORBIT_1001',
        seatNumber: 'A12',
        paymentMethod: PaymentMethod.upi,
      ),
      Ticket(
        id: 'TKT1002',
        routeId: '2',
        routeName: 'RTC Bus Stand - Mangalagiri',
        source: 'RTC Bus Stand',
        destination: 'Mangalagiri',
        type: TicketType.returnTrip,
        status: TicketStatus.used,
        purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().subtract(const Duration(hours: 12)),
        fare: 72.0,
        qrCode: 'ORBIT_1002',
        seatNumber: 'B05',
        paymentMethod: PaymentMethod.debitCard,
      ),
      Ticket(
        id: 'TKT1003',
        routeId: '3',
        routeName: 'Lakshmipuram - Namburu',
        source: 'Lakshmipuram',
        destination: 'Namburu',
        type: TicketType.multiRide,
        status: TicketStatus.active,
        purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        validFrom: DateTime.now().subtract(const Duration(days: 2)),
        validUntil: DateTime.now().add(const Duration(days: 28)),
        fare: 200.0,
        qrCode: 'ORBIT_1003',
        paymentMethod: PaymentMethod.wallet,
      ),
      Ticket(
        id: 'TKT1004',
        routeId: '1',
        routeName: 'Guntur Central - Tenali',
        source: 'Guntur Central',
        destination: 'Tenali',
        type: TicketType.oneTime,
        status: TicketStatus.expired,
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
        validFrom: DateTime.now().subtract(const Duration(days: 9)),
        validUntil: DateTime.now().subtract(const Duration(days: 8)),
        fare: 25.0,
        qrCode: 'ORBIT_1004',
        seatNumber: 'C08',
        paymentMethod: PaymentMethod.creditCard,
      ),
    ];
  }
}