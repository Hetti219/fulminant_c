part of 'biometric_bloc.dart';

abstract class BiometricState extends Equatable {
  const BiometricState();

  @override
  List<Object?> get props => [];
}

class BiometricInitial extends BiometricState {}

class BiometricLoading extends BiometricState {}

class BiometricAvailable extends BiometricState {
  final bool isEnabled;
  final bool isDeviceSupported;
  final List<BiometricType> availableTypes;
  final String biometricTypeName;

  const BiometricAvailable({
    required this.isEnabled,
    required this.isDeviceSupported,
    required this.availableTypes,
    required this.biometricTypeName,
  });

  @override
  List<Object> get props =>
      [isEnabled, isDeviceSupported, availableTypes, biometricTypeName];
}

class BiometricNotAvailable extends BiometricState {
  final String reason;

  const BiometricNotAvailable(this.reason);

  @override
  List<Object> get props => [reason];
}

class BiometricEnrollmentSuccess extends BiometricState {}

class BiometricEnrollmentFailed extends BiometricState {
  final String error;

  const BiometricEnrollmentFailed(this.error);

  @override
  List<Object> get props => [error];
}

class BiometricAuthenticationSuccess extends BiometricState {}

class BiometricAuthenticationFailed extends BiometricState {
  final String error;

  const BiometricAuthenticationFailed(this.error);

  @override
  List<Object> get props => [error];
}
