import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../../models/email.dart';
import '../../../models/password.dart';

class LoginState extends Equatable {
  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final bool isValid;
  final String? errorMessage;

  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, password, isValid, errorMessage];
}