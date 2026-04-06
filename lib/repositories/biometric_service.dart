import 'package:local_auth/local_auth.dart';

abstract class BiometricService {
  Future<bool> isDeviceSupported();

  Future<bool> isBiometricAvailable();

  Future<List<BiometricType>> getAvailableBiometrics();

  Future<bool> isBiometricEnabled();

  Future<BiometricEnrollmentResult> enableBiometric(String userEmail);

  Future<void> disableBiometric();

  Future<BiometricAuthResult> authenticateForLogin(String userEmail);

  String getBiometricTypeName(List<BiometricType> types);
}

// Result enums for better error handling
enum BiometricEnrollmentResult {
  success,
  notAvailable,
  authFailed,
  error,
}

enum BiometricAuthResult {
  success,
  failed,
  notEnabled,
  error,
}

class BiometricException implements Exception {
  final String message;

  BiometricException(this.message);

  @override
  String toString() => message;
}
