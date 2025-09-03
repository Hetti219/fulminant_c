import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';

import '../../../repositories/biometric_service.dart';

part 'biometric_event.dart';

part 'biometric_state.dart';

class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  final BiometricService _biometricService;

  BiometricBloc({required BiometricService biometricService})
      : _biometricService = biometricService,
        super(BiometricInitial()) {
    on<BiometricStatusChecked>(_onStatusChecked);
    on<BiometricEnabled>(_onEnabled);
    on<BiometricDisabled>(_onDisabled);
    on<BiometricAuthenticationRequested>(_onAuthenticationRequested);
  }

  void _onStatusChecked(
      BiometricStatusChecked event, Emitter<BiometricState> emit) async {
    emit(BiometricLoading());

    try {
      final bool isDeviceSupported =
          await _biometricService.isDeviceSupported();

      if (!isDeviceSupported) {
        emit(const BiometricNotAvailable(
            'Device does not support biometric authentication'));
        return;
      }

      final bool isBiometricAvailable =
          await _biometricService.isBiometricAvailable();

      if (!isBiometricAvailable) {
        emit(const BiometricNotAvailable(
            'No biometric methods enrolled on device'));
        return;
      }

      final bool isEnabled = await _biometricService.isBiometricEnabled();
      final List<BiometricType> availableTypes =
          await _biometricService.getAvailableBiometrics();
      final String typeName =
          _biometricService.getBiometricTypeName(availableTypes);

      emit(BiometricAvailable(
        isEnabled: isEnabled,
        isDeviceSupported: isDeviceSupported,
        availableTypes: availableTypes,
        biometricTypeName: typeName,
      ));
    } catch (e) {
      emit(BiometricNotAvailable(
          'Error checking biometric status: ${e.toString()}'));
    }
  }

  void _onEnabled(BiometricEnabled event, Emitter<BiometricState> emit) async {
    emit(BiometricLoading());

    try {
      final BiometricEnrollmentResult result =
          await _biometricService.enableBiometric(event.userEmail);

      switch (result) {
        case BiometricEnrollmentResult.success:
          emit(BiometricEnrollmentSuccess());
          // Refresh status
          add(BiometricStatusChecked());
          break;
        case BiometricEnrollmentResult.notAvailable:
          emit(const BiometricEnrollmentFailed(
              'Biometric authentication not available'));
          break;
        case BiometricEnrollmentResult.authFailed:
          emit(const BiometricEnrollmentFailed(
              'Biometric authentication failed'));
          break;
        case BiometricEnrollmentResult.error:
          emit(const BiometricEnrollmentFailed(
              'Error enabling biometric authentication'));
          break;
      }
    } catch (e) {
      emit(BiometricEnrollmentFailed('Unexpected error: ${e.toString()}'));
    }
  }

  void _onDisabled(
      BiometricDisabled event, Emitter<BiometricState> emit) async {
    emit(BiometricLoading());

    try {
      await _biometricService.disableBiometric();
      // Refresh status
      add(BiometricStatusChecked());
    } catch (e) {
      // Even if there's an error, refresh status to see current state
      add(BiometricStatusChecked());
    }
  }

  void _onAuthenticationRequested(BiometricAuthenticationRequested event,
      Emitter<BiometricState> emit) async {
    try {
      final BiometricAuthResult result =
          await _biometricService.authenticateForLogin(event.userEmail);

      switch (result) {
        case BiometricAuthResult.success:
          emit(BiometricAuthenticationSuccess());
          break;
        case BiometricAuthResult.failed:
          emit(const BiometricAuthenticationFailed(
              'Biometric authentication failed'));
          break;
        case BiometricAuthResult.notEnabled:
          emit(const BiometricAuthenticationFailed(
              'Biometric authentication not enabled'));
          break;
        case BiometricAuthResult.error:
          emit(const BiometricAuthenticationFailed(
              'Error during biometric authentication'));
          break;
      }
    } catch (e) {
      if (e is BiometricException) {
        emit(BiometricAuthenticationFailed(e.message));
      } else {
        emit(
            BiometricAuthenticationFailed('Unexpected error: ${e.toString()}'));
      }
    }
  }
}
