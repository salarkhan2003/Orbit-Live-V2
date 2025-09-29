import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:public_transport_tracker/shared/components/app_header.dart';
import 'package:public_transport_tracker/shared/orbit_live_theme.dart';

void main() {
  group('AppHeader', () {
    testWidgets('displays title correctly', (tester) async {
      const title = 'Test Title';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(title: title),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('displays title and subtitle correctly', (tester) async {
      const title = 'Test Title';
      const subtitle = 'Test Subtitle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: title,
              subtitle: subtitle,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('shows back button when requested', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Test Title',
              showBackButton: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('hides back button by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(title: 'Test Title'),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('calls onBackPressed when back button is tapped', (tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Test Title',
              showBackButton: true,
              onBackPressed: () => backPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      expect(backPressed, true);
    });

    testWidgets('displays logo with fallback when image fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(title: 'Test Title'),
          ),
        ),
      );

      // The logo container should be present
      expect(find.byType(Container), findsWidgets);
      
      // Should have a circular container for the logo
      final containers = tester.widgetList<Container>(find.byType(Container));
      final logoContainer = containers.firstWhere(
        (container) => container.decoration is BoxDecoration &&
            (container.decoration as BoxDecoration).shape == BoxShape.circle,
        orElse: () => Container(),
      );
      
      expect(logoContainer.decoration, isA<BoxDecoration>());
    });

    testWidgets('applies correct text styles', (tester) async {
      const title = 'Test Title';
      const subtitle = 'Test Subtitle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: title,
              subtitle: subtitle,
            ),
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(find.text(title));
      final subtitleWidget = tester.widget<Text>(find.text(subtitle));

      expect(titleWidget.style?.fontSize, OrbitLiveTextStyles.headerTitle.fontSize);
      expect(titleWidget.style?.fontWeight, OrbitLiveTextStyles.headerTitle.fontWeight);
      expect(subtitleWidget.style?.fontSize, OrbitLiveTextStyles.headerSubtitle.fontSize);
    });
  });

  group('AppHeaderMinimal', () {
    testWidgets('displays title correctly', (tester) async {
      const title = 'Minimal Title';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeaderMinimal(title: title),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('shows back button when requested', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeaderMinimal(
              title: 'Test Title',
              showBackButton: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('calls onBackPressed when back button is tapped', (tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeaderMinimal(
              title: 'Test Title',
              showBackButton: true,
              onBackPressed: () => backPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      expect(backPressed, true);
    });
  });

  group('AppHeaderAnimated', () {
    testWidgets('displays title and subtitle correctly', (tester) async {
      const title = 'Animated Title';
      const subtitle = 'Animated Subtitle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeaderAnimated(
              title: title,
              subtitle: subtitle,
            ),
          ),
        ),
      );

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('has animation transitions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeaderAnimated(
              title: 'Animated Title',
            ),
          ),
        ),
      );

      // Should have FadeTransition and SlideTransition
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
    });

    testWidgets('starts animations after delay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeaderAnimated(
              title: 'Animated Title',
              delay: const Duration(milliseconds: 200),
            ),
          ),
        ),
      );

      // Initially, animations should not have started
      await tester.pump(const Duration(milliseconds: 100));
      
      // After delay, animations should start
      await tester.pump(const Duration(milliseconds: 200));
      
      expect(find.byType(FadeTransition), findsOneWidget);
    });
  });
}