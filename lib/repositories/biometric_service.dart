import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricHashKey = 'biometric_hash';

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  // Check if biometric authentication is available and enrolled
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      return isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types for display
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Check if biometric 2FA is enabled for this app
  Future<bool> isBiometricEnabled() async {
    try {
      final String? enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Enable biometric 2FA - this creates a unique hash for this device/app combo
  Future<BiometricEnrollmentResult> enableBiometric(String userEmail) async {
    try {
      // First check if biometrics are available
      final bool available = await isBiometricAvailable();
      if (!available) {
        return BiometricEnrollmentResult.notAvailable;
      }

      // Authenticate to confirm enrollment
      final bool authenticated = await _authenticateUser(
        reason: 'Enable biometric authentication for quick sign-in',
      );

      if (!authenticated) {
        return BiometricEnrollmentResult.authFailed;
      }

      // Create a unique hash for this user/device combination
      final String deviceHash = _createDeviceHash(userEmail);

      // Store biometric enabled flag and hash
      await _storage.write(key: _biometricEnabledKey, value: 'true');
      await _storage.write(key: _biometricHashKey, value: deviceHash);

      return BiometricEnrollmentResult.success;
    } catch (e) {
      return BiometricEnrollmentResult.error;
    }
  }

  // Disable biometric 2FA
  Future<void> disableBiometric() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
      await _storage.delete(key: _biometricHashKey);
    } catch (e) {
      // Silent fail - if we can't delete, at least the flag is gone
    }
  }

  // Perform biometric authentication for login
  Future<BiometricAuthResult> authenticateForLogin(String userEmail) async {
    try {
      // Check if biometric is enabled for this user
      final bool enabled = await isBiometricEnabled();
      if (!enabled) {
        return BiometricAuthResult.notEnabled;
      }

      // Verify the stored hash matches current user
      final String? storedHash = await _storage.read(key: _biometricHashKey);
      final String currentHash = _createDeviceHash(userEmail);

      if (storedHash != currentHash) {
        // Hash mismatch - different user or corrupted data
        await disableBiometric(); // Clean up
        return BiometricAuthResult.notEnabled;
      }

      // Perform biometric authentication
      final bool authenticated = await _authenticateUser(
        reason: 'Verify your identity to sign in',
      );

      return authenticated
          ? BiometricAuthResult.success
          : BiometricAuthResult.failed;
    } catch (e) {
      return BiometricAuthResult.error;
    }
  }

  // Private method to handle the actual biometric authentication
  Future<bool> _authenticateUser({required String reason}) async {
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN/Password fallback
          stickyAuth: true, // Keep auth dialog until success/cancel
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      // Handle specific error cases
      switch (e.code) {
        case auth_error.notAvailable:
        case auth_error.notEnrolled:
          return false;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          throw BiometricException(
              'Biometric authentication is locked. Please try again later.');
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Create a unique hash for user/device combination
  String _createDeviceHash(String userEmail) {
    final String data =
        '$userEmail-${DateTime.now().millisecondsSinceEpoch ~/ 86400000}'; // Daily salt
    final List<int> bytes = utf8.encode(data);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get user-friendly biometric type names
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }
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
