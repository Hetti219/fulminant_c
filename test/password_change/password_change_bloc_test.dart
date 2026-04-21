import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:formz/formz.dart';
import 'package:fulminant_c/blocs/auth/password_change/password_change_bloc.dart';
import 'package:mockito/mockito.dart';

import '../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository auth;
  late PasswordChangeBloc bloc;

  setUp(() {
    auth = MockAuthRepository();
    bloc = PasswordChangeBloc(authRepository: auth);
  });

  tearDown(() => bloc.close());

  test('initial state has all fields pure and invalid', () {
    expect(bloc.state.status, FormzSubmissionStatus.initial);
    expect(bloc.state.isValid, false);
    expect(bloc.state.errorMessage, isNull);
  });

  blocTest<PasswordChangeBloc, PasswordChangeState>(
    'CurrentPasswordChanged updates currentPassword field',
    build: () => bloc,
    act: (b) => b.add(const CurrentPasswordChanged('OldPass1')),
    expect: () => [
      isA<PasswordChangeState>().having(
        (s) => s.currentPassword.value,
        'currentPassword.value',
        'OldPass1',
      ),
    ],
  );

  blocTest<PasswordChangeBloc, PasswordChangeState>(
    'NewPasswordChanged updates newPassword field',
    build: () => bloc,
    act: (b) => b.add(const NewPasswordChanged('NewPass1')),
    expect: () => [
      isA<PasswordChangeState>().having(
        (s) => s.newPassword.value,
        'newPassword.value',
        'NewPass1',
      ),
    ],
  );

  blocTest<PasswordChangeBloc, PasswordChangeState>(
    'ConfirmPasswordChanged updates confirmPassword field',
    build: () => bloc,
    act: (b) => b.add(const ConfirmPasswordChanged('NewPass1')),
    expect: () => [
      isA<PasswordChangeState>().having(
        (s) => s.confirmPassword.value,
        'confirmPassword.value',
        'NewPass1',
      ),
    ],
  );

  blocTest<PasswordChangeBloc, PasswordChangeState>(
    'isValid becomes true when all fields valid and passwords match',
    build: () => bloc,
    act: (b) {
      b
        ..add(const CurrentPasswordChanged('OldPass1'))
        ..add(const NewPasswordChanged('NewPass1'))
        ..add(const ConfirmPasswordChanged('NewPass1'));
    },
    skip: 2,
    expect: () => [
      isA<PasswordChangeState>().having((s) => s.isValid, 'isValid', true),
    ],
  );

  blocTest<PasswordChangeBloc, PasswordChangeState>(
    'submit with valid form → inProgress → success',
    build: () {
      when(auth.changePassword(
        currentPassword: anyNamed('currentPassword'),
        newPassword: anyNamed('newPassword'),
      )).thenAnswer((_) async {});
      return bloc;
    },
    act: (b) {
      b
        ..add(const CurrentPasswordChanged('OldPass1'))
        ..add(const NewPasswordChanged('NewPass1'))
        ..add(const ConfirmPasswordChanged('NewPass1'))
        ..add(PasswordChangeSubmitted());
    },
    skip: 3, // skip the three field-update states
    expect: () => [
      isA<PasswordChangeState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
      isA<PasswordChangeState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.success),
    ],
    verify: (_) {
      verify(auth.changePassword(
        currentPassword: 'OldPass1',
        newPassword: 'NewPass1',
      )).called(1);
    },
  );

  blocTest<PasswordChangeBloc, PasswordChangeState>(
    'submit when changePassword throws → inProgress → failure with error',
    build: () {
      when(auth.changePassword(
        currentPassword: anyNamed('currentPassword'),
        newPassword: anyNamed('newPassword'),
      )).thenThrow(Exception('wrong password'));
      return bloc;
    },
    act: (b) {
      b
        ..add(const CurrentPasswordChanged('OldPass1'))
        ..add(const NewPasswordChanged('NewPass1'))
        ..add(const ConfirmPasswordChanged('NewPass1'))
        ..add(PasswordChangeSubmitted());
    },
    skip: 3,
    expect: () => [
      isA<PasswordChangeState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
      isA<PasswordChangeState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.failure)
          .having(
              (s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );

  blocTest<PasswordChangeBloc, PasswordChangeState>(
    'submit with mismatched passwords does nothing',
    build: () => bloc,
    act: (b) {
      b
        ..add(const CurrentPasswordChanged('OldPass1'))
        ..add(const NewPasswordChanged('NewPass1'))
        ..add(const ConfirmPasswordChanged('DifferentPass1'))
        ..add(PasswordChangeSubmitted());
    },
    skip: 3,
    // No state change should happen because passwordsMatch is false
    expect: () => [],
    verify: (_) {
      verifyNever(auth.changePassword(
        currentPassword: anyNamed('currentPassword'),
        newPassword: anyNamed('newPassword'),
      ));
    },
  );
}
