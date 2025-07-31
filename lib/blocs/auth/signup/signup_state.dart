import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../../models/email.dart';
import '../../../models/password.dart';
import '../../../models/name.dart';

class SignupState extends Equatable {
  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final Name fullName;
  final DateTime? dateOfBirth;
  final bool isValid;
  final String? errorMessage;

  const SignupState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.fullName = const Name.pure(),
    this.dateOfBirth,
    this.isValid = false,
    this.errorMessage,
  });

  SignupState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    Name? fullName,
    DateTime? dateOfBirth,
    bool? isValid,
    String? errorMessage,
  }) {
    return SignupState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, password, fullName, dateOfBirth, isValid, errorMessage];
}