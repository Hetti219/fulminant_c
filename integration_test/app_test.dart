import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

// Integration test scaffold (TEST-03)
// Full E2E flows with Firebase require the Firebase emulator suite.
// This smoke test validates that the integration_test infrastructure works.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test — MaterialApp renders', (tester) async {
    // Pump a minimal MaterialApp to verify integration test setup works.
    // We don't launch the full app here because it requires Firebase
    // initialization, which needs emulators in CI.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Integration test scaffold'),
          ),
        ),
      ),
    );

    expect(find.text('Integration test scaffold'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
