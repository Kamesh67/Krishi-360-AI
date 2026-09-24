import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krishi360_ai/main.dart';
import 'package:krishi360_ai/dashboard_screen.dart';

void main() {
  testWidgets('App smoke test and Dashboard render', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const Krishi360AI());
    await tester.pumpAndSettle();

    // Verify main app and dashboard components are rendered
    expect(find.byType(Krishi360AI), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Krishi360 AI'), findsWidgets);
    expect(find.text('Crops'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Seed Shop'), findsOneWidget);
    expect(find.text('Harvest'), findsOneWidget);
    expect(find.text('Crop Waste'), findsOneWidget);
    expect(find.text('Profit'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Farm Map'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
  });
}
