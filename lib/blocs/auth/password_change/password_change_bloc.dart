import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../models/password.dart';
import '../../../repositories/auth_repository.dart';

part 'password_change_event.dart';

part 'password_change_state.dart';

class PasswordChangeBloc
    extends Bloc<PasswordChangeEvent, PasswordChangeState> {
  final AuthRepository _authRepository;

  PasswordChangeBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const PasswordChangeState()) {
    on<CurrentPasswordChanged>(_onCurrentPasswordChanged);
    on<NewPasswordChanged>(_onNewPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<PasswordChangeSubmitted>(_onSubmitted);
  }

  void _onCurrentPasswordChanged(
    CurrentPasswordChanged event,
    Emitter<PasswordChangeState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
      currentPassword: password,
      isValid: _isValid(password, state.newPassword, state.confirmPassword),
      errorMessage: null,
    ));
  }

  void _onNewPasswordChanged(
    NewPasswordChanged event,
    Emitter<PasswordChangeState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
      newPassword: password,
      isValid: _isValid(state.currentPassword, password, state.confirmPassword),
      errorMessage: null,
    ));
  }

  void _onConfirmPasswordChanged(
    ConfirmPasswordChanged event,
    Emitter<PasswordChangeState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
      confirmPassword: password,
      isValid: _isValid(state.currentPassword, state.newPassword, password),
      errorMessage: null,
    ));
  }

  void _onSubmitted(
    PasswordChangeSubmitted event,
    Emitter<PasswordChangeState> emit,
  ) async {
    if (state.isValid && state.passwordsMatch) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        await _authRepository.changePassword(
          currentPassword: state.currentPassword.value,
          newPassword: state.newPassword.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (error) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: error.toString(),
        ));
      }
    }
  }

  bool _isValid(Password current, Password newPass, Password confirm) {
    return Formz.validate([current, newPass, confirm]) &&
        newPass.value.isNotEmpty &&
        newPass.value == confirm.value;
  }
}
