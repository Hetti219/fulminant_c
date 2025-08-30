part of 'password_change_bloc.dart';

abstract class PasswordChangeEvent extends Equatable {
  const PasswordChangeEvent();

  @override
  List<Object> get props => [];
}

class CurrentPasswordChanged extends PasswordChangeEvent {
  final String password;

  const CurrentPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class NewPasswordChanged extends PasswordChangeEvent {
  final String password;

  const NewPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordChanged extends PasswordChangeEvent {
  final String password;

  const ConfirmPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class PasswordChangeSubmitted extends PasswordChangeEvent {}
