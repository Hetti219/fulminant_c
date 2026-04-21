import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fulminant_c/blocs/auth/biometric/biometric_bloc.dart';
import 'package:fulminant_c/repositories/biometric_service.dart';
import 'package:mockito/mockito.dart';

import '../helpers/mocks.mocks.dart';

void main() {
  late MockBiometricService bio;
  late BiometricBloc bloc;

  setUp(() {
    bio = MockBiometricService();
    bloc = BiometricBloc(biometricService: bio);
  });

  tearDown(() => bloc.close());

  test('initial state is BiometricInitial', () {
    expect(bloc.state, isA<BiometricInitial>());
  });

  // ─── BiometricStatusChecked ───

  group('BiometricStatusChecked', () {
    blocTest<BiometricBloc, BiometricState>(
      'device not supported → BiometricNotAvailable',
      build: () {
        when(bio.isDeviceSupported()).thenAnswer((_) async => false);
        return bloc;
      },
      act: (b) => b.add(BiometricStatusChecked()),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricNotAvailable>(),
      ],
    );

    blocTest<BiometricBloc, BiometricState>(
      'device supported but no biometrics enrolled → BiometricNotAvailable',
      build: () {
        when(bio.isDeviceSupported()).thenAnswer((_) async => true);
        when(bio.isBiometricAvailable()).thenAnswer((_) async => false);
        return bloc;
      },
      act: (b) => b.add(BiometricStatusChecked()),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricNotAvailable>(),
      ],
    );

    blocTest<BiometricBloc, BiometricState>(
      'supported + available + enabled → BiometricAvailable(isEnabled: true)',
      build: () {
        when(bio.isDeviceSupported()).thenAnswer((_) async => true);
        when(bio.isBiometricAvailable()).thenAnswer((_) async => true);
        when(bio.isBiometricEnabled()).thenAnswer((_) async => true);
        when(bio.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(bio.getBiometricTypeName(any)).thenReturn('Fingerprint');
        return bloc;
      },
      act: (b) => b.add(BiometricStatusChecked()),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricAvailable>()
            .having((s) => s.isEnabled, 'isEnabled', true)
            .having((s) => s.biometricTypeName, 'typeName', 'Fingerprint'),
      ],
    );

    blocTest<BiometricBloc, BiometricState>(
      'supported + available + not enabled → BiometricAvailable(isEnabled: false)',
      build: () {
        when(bio.isDeviceSupported()).thenAnswer((_) async => true);
        when(bio.isBiometricAvailable()).thenAnswer((_) async => true);
        when(bio.isBiometricEnabled()).thenAnswer((_) async => false);
        when(bio.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.face]);
        when(bio.getBiometricTypeName(any)).thenReturn('Face ID');
        return bloc;
      },
      act: (b) => b.add(BiometricStatusChecked()),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricAvailable>()
            .having((s) => s.isEnabled, 'isEnabled', false)
            .having((s) => s.biometricTypeName, 'typeName', 'Face ID'),
      ],
    );

    blocTest<BiometricBloc, BiometricState>(
      'exception during status check → BiometricNotAvailable',
      build: () {
        when(bio.isDeviceSupported()).thenThrow(Exception('hardware error'));
        return bloc;
      },
      act: (b) => b.add(BiometricStatusChecked()),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricNotAvailable>(),
      ],
    );
  });

  // ─── BiometricEnabled ───

  group('BiometricEnabled', () {
    blocTest<BiometricBloc, BiometricState>(
      'enrollment success → BiometricEnrollmentSuccess then re-checks status',
      build: () {
        when(bio.enableBiometric(any))
            .thenAnswer((_) async => BiometricEnrollmentResult.success);
        // For the auto-triggered BiometricStatusChecked after success
        when(bio.isDeviceSupported()).thenAnswer((_) async => true);
        when(bio.isBiometricAvailable()).thenAnswer((_) async => true);
        when(bio.isBiometricEnabled()).thenAnswer((_) async => true);
        when(bio.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(bio.getBiometricTypeName(any)).thenReturn('Fingerprint');
        return bloc;
      },
      act: (b) => b.add(const BiometricEnabled('user@test.com')),
      expect: () => [
        isA<BiometricLoading>(), // from _onEnabled
        isA<BiometricEnrollmentSuccess>(),
        isA<BiometricLoading>(), // from re-triggered status check
        isA<BiometricAvailable>(),
      ],
      verify: (_) =>
          verify(bio.enableBiometric('user@test.com')).called(1),
    );

    blocTest<BiometricBloc, BiometricState>(
      'enrollment authFailed → BiometricEnrollmentFailed',
      build: () {
        when(bio.enableBiometric(any))
            .thenAnswer((_) async => BiometricEnrollmentResult.authFailed);
        return bloc;
      },
      act: (b) => b.add(const BiometricEnabled('user@test.com')),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricEnrollmentFailed>(),
      ],
    );

    blocTest<BiometricBloc, BiometricState>(
      'enrollment notAvailable → BiometricEnrollmentFailed',
      build: () {
        when(bio.enableBiometric(any))
            .thenAnswer((_) async => BiometricEnrollmentResult.notAvailable);
        return bloc;
      },
      act: (b) => b.add(const BiometricEnabled('user@test.com')),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricEnrollmentFailed>(),
      ],
    );

    blocTest<BiometricBloc, BiometricState>(
      'enrollment error → BiometricEnrollmentFailed',
      build: () {
        when(bio.enableBiometric(any))
            .thenAnswer((_) async => BiometricEnrollmentResult.error);
        return bloc;
      },
      act: (b) => b.add(const BiometricEnabled('user@test.com')),
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricEnrollmentFailed>(),
      ],
    );
  });

  // ─── BiometricDisabled ───

  group('BiometricDisabled', () {
    blocTest<BiometricBloc, BiometricState>(
      'disable → calls disableBiometric then re-checks status',
      build: () {
        when(bio.disableBiometric()).thenAnswer((_) async {});
        when(bio.isDeviceSupported()).thenAnswer((_) async => true);
        when(bio.isBiometricAvailable()).thenAnswer((_) async => true);
        when(bio.isBiometricEnabled()).thenAnswer((_) async => false);
        when(bio.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(bio.getBiometricTypeName(any)).thenReturn('Fingerprint');
        return bloc;
      },
      act: (b) => b.add(BiometricDisabled()),
      // Note: two consecutive BiometricLoading() states are deduplicated
      // by Equatable since they are equal, so only one appears
      expect: () => [
        isA<BiometricLoading>(),
        isA<BiometricAvailable>()
            .having((s) => s.isEnabled, 'isEnabled', false),
      ],
      verify: (_) => verify(bio.disableBiometric()).called(1),
    );
  });

  // ─── BiometricAuthenticationRequested ───

  group('BiometricAuthenticationRequested', () {
    blocTest<BiometricBloc, BiometricState>(
      'auth success → BiometricAuthenticationSuccess',
      build: () {
        when(bio.authenticateForLogin(any))
            .thenAnswer((_) async => BiometricAuthResult.success);
        return bloc;
      },
      act: (b) =>
          b.add(const BiometricAuthenticationRequested('user@test.com')),
      expect: () => [isA<BiometricAuthenticationSuccess>()],
    );

    blocTest<BiometricBloc, BiometricState>(
      'auth failed → BiometricAuthenticationFailed',
      build: () {
        when(bio.authenticateForLogin(any))
            .thenAnswer((_) async => BiometricAuthResult.failed);
        return bloc;
      },
      act: (b) =>
          b.add(const BiometricAuthenticationRequested('user@test.com')),
      expect: () => [isA<BiometricAuthenticationFailed>()],
    );

    blocTest<BiometricBloc, BiometricState>(
      'auth notEnabled → BiometricAuthenticationFailed',
      build: () {
        when(bio.authenticateForLogin(any))
            .thenAnswer((_) async => BiometricAuthResult.notEnabled);
        return bloc;
      },
      act: (b) =>
          b.add(const BiometricAuthenticationRequested('user@test.com')),
      expect: () => [isA<BiometricAuthenticationFailed>()],
    );

    blocTest<BiometricBloc, BiometricState>(
      'auth error → BiometricAuthenticationFailed',
      build: () {
        when(bio.authenticateForLogin(any))
            .thenAnswer((_) async => BiometricAuthResult.error);
        return bloc;
      },
      act: (b) =>
          b.add(const BiometricAuthenticationRequested('user@test.com')),
      expect: () => [isA<BiometricAuthenticationFailed>()],
    );

    blocTest<BiometricBloc, BiometricState>(
      'BiometricException → BiometricAuthenticationFailed with message',
      build: () {
        when(bio.authenticateForLogin(any))
            .thenThrow(BiometricException('locked out'));
        return bloc;
      },
      act: (b) =>
          b.add(const BiometricAuthenticationRequested('user@test.com')),
      expect: () => [
        isA<BiometricAuthenticationFailed>()
            .having((s) => s.error, 'error', 'locked out'),
      ],
    );
  });
}
