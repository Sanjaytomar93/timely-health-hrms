import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelay_health/features/auth/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows Timely Health branding', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump();

    expect(find.text('Timely Health'), findsOneWidget);
    expect(find.text('Your workplace, in sync.'), findsOneWidget);
    expect(find.text('Preparing your workspace'), findsOneWidget);
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
