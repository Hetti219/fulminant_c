import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:fulminant_c/screens/auth/login_screen.dart';
import 'package:fulminant_c/repositories/auth_repository.dart';

import '../helpers/pump_app.dart';
import '../helpers/mocks.mocks.dart';

void main() {
  group('LoginScreen', () {
    late MockAuthRepository auth;

    setUp(() {
      auth = MockAuthRepository();
// If your LoginBloc uses auth.signIn in the listener path, stub it:
      when(auth.signIn(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => true);
    });

    testWidgets('button is disabled until valid email & password entered',
        (tester) async {
      await pumpApp(
        tester,
        repositories: [RepositoryProvider<AuthRepository>.value(value: auth)],
        child: const LoginScreen(),
      );

      final emailField =
          find.byKey(const Key('loginForm_emailInput_textField'));
      final passwordField =
          find.byKey(const Key('loginForm_passwordInput_textField'));
      final loginButtonFinder =
          find.byKey(const Key('loginForm_continue_raisedButton'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButtonFinder, findsOneWidget);

// Initially disabled
      final initialButton = tester.widget<ElevatedButton>(loginButtonFinder);
      expect(initialButton.onPressed, isNull);

// Enter valid-ish email & password
      await tester.enterText(emailField, 'ino@leaf.dev');
      await tester.enterText(passwordField, 'Shadow123');
      await tester.pump();

      final enabledButton = tester.widget<ElevatedButton>(loginButtonFinder);
      expect(enabledButton.onPressed, isNotNull);
    });
  });
}
