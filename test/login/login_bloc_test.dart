import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:formz/formz.dart';
import 'package:fulminant_c/blocs/auth/login/login_bloc.dart';
import 'package:fulminant_c/blocs/auth/login/login_event.dart';
import 'package:fulminant_c/blocs/auth/login/login_state.dart';
import 'package:mockito/mockito.dart';

import '../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository auth;
  late LoginBloc bloc;

  setUp(() {
    auth = MockAuthRepository();
    bloc = LoginBloc(authRepository: auth);
  });

  tearDown(() => bloc.close());

  test('initial state is LoginState', () {
    expect(bloc.state, isA<LoginState>());
  });

  blocTest<LoginBloc, LoginState>(
    'submits with valid form → inProgress → failure when signIn throws',
    build: () {
      when(auth.signIn(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(Exception('bad creds'));
      return bloc;
    },
    act: (b) {
      b
        ..add(LoginEmailChanged('ino@leaf.dev'))
        ..add(LoginPasswordChanged('Shadow123'))
        ..add(LoginSubmitted());
    },
    skip: 2,
    // skip field-update states
    expect: () => [
      isA<LoginState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
      isA<LoginState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.failure),
    ],
    verify: (_) {
      verify(auth.signIn(email: 'ino@leaf.dev', password: 'Shadow123'))
          .called(1);
    },
  );
}
