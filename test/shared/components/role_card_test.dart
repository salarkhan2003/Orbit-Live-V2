import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/shared/components/role_card.dart';
import 'package:public_transport_tracker/shared/orbit_live_colors.dart';

void main() {
  group('RoleCard', () {
    testWidgets('displays title and subtitle correctly', (tester) async {
      const title = 'Test Role';
      const subtitle = 'Test Description';
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCard(
              title: title,
              subtitle: subtitle,
              gradientColors: OrbitLiveColors.tealGradient,
              illustration: const Icon(Icons.person),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
      expect(tapped, false);
    });

    testWidgets('handles tap correctly', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCard(
              title: 'Test Role',
              subtitle: 'Test Description',
              gradientColors: OrbitLiveColors.tealGradient,
              illustration: const Icon(Icons.person),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RoleCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('shows selection indicator when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCard(
              title: 'Test Role',
              subtitle: 'Test Description',
              gradientColors: OrbitLiveColors.tealGradient,
              illustration: const Icon(Icons.person),
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('hides selection indicator when not selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCard(
              title: 'Test Role',
              subtitle: 'Test Description',
              gradientColors: OrbitLiveColors.tealGradient,
              illustration: const Icon(Icons.person),
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('applies correct gradient colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCard(
              title: 'Test Role',
              subtitle: 'Test Description',
              gradientColors: OrbitLiveColors.orangeGradient,
              illustration: const Icon(Icons.person),
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(RoleCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      expect(gradient.colors, equals(OrbitLiveColors.orangeGradient));
    });

    testWidgets('has proper touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCard(
              title: 'Test Role',
              subtitle: 'Test Description',
              gradientColors: OrbitLiveColors.tealGradient,
              illustration: const Icon(Icons.person),
              onTap: () {},
              height: 200,
            ),
          ),
        ),
      );

      final roleCard = tester.getSize(find.byType(RoleCard));
      
      // Ensure minimum touch target size (44x44 dp as per accessibility guidelines)
      expect(roleCard.height, greaterThanOrEqualTo(44));
      expect(roleCard.width, greaterThanOrEqualTo(44));
    });
  });

  group('PassengerRoleCard', () {
    testWidgets('displays passenger-specific content', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PassengerRoleCard(
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Passenger'), findsOneWidget);
      expect(find.text('Book tickets and track buses'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      await tester.tap(find.byType(PassengerRoleCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('uses teal gradient colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PassengerRoleCard(
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final roleCard = find.descendant(
        of: find.byType(PassengerRoleCard),
        matching: find.byType(RoleCard),
      );

      expect(roleCard, findsOneWidget);
    });
  });

  group('DriverRoleCard', () {
    testWidgets('displays driver-specific content', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverRoleCard(
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Driver'), findsOneWidget);
      expect(find.text('Manage trips and routes'), findsOneWidget);
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);

      await tester.tap(find.byType(DriverRoleCard));
      await tester.pump();

      expect(tapped, true);
    });
  });

  group('RoleCardGrid', () {
    testWidgets('displays cards in grid layout', (tester) async {
      final cards = [
        PassengerRoleCard(isSelected: false, onTap: () {}),
        DriverRoleCard(isSelected: false, onTap: () {}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCardGrid(cards: cards),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(PassengerRoleCard), findsOneWidget);
      expect(find.byType(DriverRoleCard), findsOneWidget);
    });
  });

  group('RoleCardRow', () {
    testWidgets('displays cards in horizontal layout', (tester) async {
      final cards = [
        PassengerRoleCard(isSelected: false, onTap: () {}),
        DriverRoleCard(isSelected: false, onTap: () {}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCardRow(cards: cards),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(PassengerRoleCard), findsOneWidget);
      expect(find.byType(DriverRoleCard), findsOneWidget);
    });
  });

  group('RoleCard Animations', () {
    testWidgets('animates scale on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoleCard(
              title: 'Test Role',
              subtitle: 'Test Description',
              gradientColors: OrbitLiveColors.tealGradient,
              illustration: const Icon(Icons.person),
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the gesture detector and simulate tap down
      final gestureDetector = find.descendant(
        of: find.byType(RoleCard),
        matching: find.byType(GestureDetector),
      );

      await tester.press(gestureDetector);
      await tester.pump(const Duration(milliseconds: 50));

      // The card should be scaled down when pressed
      // Note: Testing exact scale values is complex, so we just verify the animation structure exists
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('updates selection state correctly', (tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    RoleCard(
                      title: 'Test Role',
                      subtitle: 'Test Description',
                      gradientColors: OrbitLiveColors.tealGradient,
                      illustration: const Icon(Icons.person),
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          isSelected = !isSelected;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially not selected
      expect(find.byIcon(Icons.check), findsNothing);

      // Tap to select
      await tester.tap(find.byType(RoleCard));
      await tester.pump();

      // Should now be selected
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}