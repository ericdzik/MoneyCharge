import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locacharge/core/widgets/status_badge.dart';
import 'package:locacharge/core/constants/app_colors.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('renders correctly for available status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: StatusType.available),
          ),
        ),
      );

      final textFinder = find.text('Disponible');
      final containerFinder = find.byType(Container);

      expect(textFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.success.withAlpha((255 * 0.15).round()));
    });

    testWidgets('renders correctly for lowStock status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: StatusType.lowStock),
          ),
        ),
      );

      final textFinder = find.text('Stock faible');
      final containerFinder = find.byType(Container);

      expect(textFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.warning.withAlpha((255 * 0.15).round()));
    });

    testWidgets('renders correctly for outOfStock status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: StatusType.outOfStock),
          ),
        ),
      );

      final textFinder = find.text('Épuisé');
      final containerFinder = find.byType(Container);

      expect(textFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.error.withAlpha((255 * 0.15).round()));
    });

    testWidgets('renders correctly for pending status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: StatusType.pending),
          ),
        ),
      );

      final textFinder = find.text('En attente');
      final containerFinder = find.byType(Container);

      expect(textFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.secondary.withAlpha((255 * 0.15).round()));
    });

    testWidgets('renders custom text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: StatusType.available, customText: 'Custom'),
          ),
        ),
      );

      final textFinder = find.text('Custom');
      expect(textFinder, findsOneWidget);
    });
  });
}
