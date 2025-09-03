import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;

  const LoginEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class LoginSubmitted extends LoginEvent {}

// NEW EVENTS FOR PASSWORD RESET
class PasswordResetRequested extends LoginEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

//New events for biometric authentication
class BiometricAuthenticationRequested extends LoginEvent {}

class BiometricAuthenticationCompleted extends LoginEvent {
  final bool success;
  final String? error;

  const BiometricAuthenticationCompleted({
    required this.success,
    this.error,
  });
}
