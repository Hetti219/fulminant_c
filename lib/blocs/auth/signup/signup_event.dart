import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupEmailChanged extends SignupEvent {
  final String email;

  const SignupEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class SignupPasswordChanged extends SignupEvent {
  final String password;

  const SignupPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class SignupFullNameChanged extends SignupEvent {
  final String fullName;

  const SignupFullNameChanged(this.fullName);

  @override
  List<Object> get props => [fullName];
}

class SignupDateOfBirthChanged extends SignupEvent {
  final DateTime dateOfBirth;

  const SignupDateOfBirthChanged(this.dateOfBirth);

  @override
  List<Object> get props => [dateOfBirth];
}

class SignupSubmitted extends SignupEvent {}