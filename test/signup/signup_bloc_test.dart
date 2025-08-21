import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:formz/formz.dart';
import 'package:fulminant_c/blocs/auth/signup/signup_bloc.dart';
import 'package:fulminant_c/blocs/auth/signup/signup_event.dart';
import 'package:fulminant_c/blocs/auth/signup/signup_state.dart';
import 'package:mockito/mockito.dart';

import '../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository auth;
  late SignupBloc bloc;

  setUp(() {
    auth = MockAuthRepository();
    bloc = SignupBloc(authRepository: auth);
  });

  tearDown(() => bloc.close());

  blocTest<SignupBloc, SignupState>(
    'signUp success path → inProgress → success',
    build: () {
      when(auth.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        fullName: anyNamed('fullName'),
        dateOfBirth: anyNamed('dateOfBirth'),
      )).thenAnswer((_) async {}); // returns Future<void>
      return bloc;
    },
    act: (b) {
      b
        ..add(SignupFullNameChanged('Sakura Haruno'))
        ..add(SignupEmailChanged('sakura@leaf.dev'))
        ..add(SignupPasswordChanged('w00db0y1'))
        ..add(SignupDateOfBirthChanged(DateTime(2002, 3, 28)))
        ..add(SignupSubmitted());
    },
    skip: 4,
    expect: () => [
      isA<SignupState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
      isA<SignupState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.success),
    ],
    verify: (_) {
      verify(auth.signUp(
        email: 'sakura@leaf.dev',
        password: 'w00db0y1',
        fullName: 'Sakura Haruno',
        dateOfBirth: DateTime(2002, 3, 28),
      )).called(1);
    },
  );
}
