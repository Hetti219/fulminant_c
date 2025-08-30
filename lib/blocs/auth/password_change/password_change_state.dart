part of 'password_change_bloc.dart';

class PasswordChangeState extends Equatable {
  final FormzSubmissionStatus status;
  final Password currentPassword;
  final Password newPassword;
  final Password confirmPassword;
  final bool isValid;
  final String? errorMessage;

  const PasswordChangeState({
    this.status = FormzSubmissionStatus.initial,
    this.currentPassword = const Password.pure(),
    this.newPassword = const Password.pure(),
    this.confirmPassword = const Password.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  PasswordChangeState copyWith({
    FormzSubmissionStatus? status,
    Password? currentPassword,
    Password? newPassword,
    Password? confirmPassword,
    bool? isValid,
    String? errorMessage,
  }) {
    return PasswordChangeState(
      status: status ?? this.status,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }

  bool get passwordsMatch =>
      newPassword.value.isNotEmpty &&
      newPassword.value == confirmPassword.value;

  @override
  List<Object?> get props => [
        status,
        currentPassword,
        newPassword,
        confirmPassword,
        isValid,
        errorMessage,
      ];
}
