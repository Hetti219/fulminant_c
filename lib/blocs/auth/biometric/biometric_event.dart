part of 'biometric_bloc.dart';

abstract class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object> get props => [];
}

class BiometricStatusChecked extends BiometricEvent {}

class BiometricEnabled extends BiometricEvent {
  final String userEmail;

  const BiometricEnabled(this.userEmail);

  @override
  List<Object> get props => [userEmail];
}

class BiometricDisabled extends BiometricEvent {}

class BiometricAuthenticationRequested extends BiometricEvent {
  final String userEmail;

  const BiometricAuthenticationRequested(this.userEmail);

  @override
  List<Object> get props => [userEmail];
}
