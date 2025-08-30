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

  // NEW PASSWORD RESET FIELDS
  final bool isPasswordResetInProgress;
  final bool isPasswordResetSuccess;
  final String? passwordResetError;

  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.errorMessage,
    //Password reset fields
    this.isPasswordResetInProgress = false,
    this.isPasswordResetSuccess = false,
    this.passwordResetError,
  });

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    bool? isValid,
    String? errorMessage,
    //password reset fields
    bool? isPasswordResetInProgress,
    bool? isPasswordResetSuccess,
    String? passwordResetError,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      //password reset fields
      isPasswordResetInProgress:
          isPasswordResetInProgress ?? this.isPasswordResetInProgress,
      isPasswordResetSuccess:
          isPasswordResetSuccess ?? this.isPasswordResetSuccess,
      passwordResetError: passwordResetError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        isValid,
        errorMessage,
        //password reset fields
        isPasswordResetInProgress,
        isPasswordResetSuccess,
        passwordResetError,
      ];
}
