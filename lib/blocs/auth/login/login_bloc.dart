import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../models/email.dart';
import '../../../models/password.dart';
import '../../../repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<PasswordResetRequested>(
        _onPasswordResetRequested); //Password reset event handler
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
        // Reset password reset states when email changes
        isPasswordResetSuccess: false,
        passwordResetError: null,
      ),
    );
  }

  void _onPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  void _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await _authRepository.signIn(
          email: state.email.value,
          password: state.password.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  void _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      isPasswordResetInProgress: true,
      isPasswordResetSuccess: false,
      passwordResetError: null,
    ));

    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(state.copyWith(
        isPasswordResetInProgress: false,
        isPasswordResetSuccess: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        isPasswordResetInProgress: false,
        isPasswordResetSuccess: false,
        passwordResetError: error.toString(),
      ));
    }
  }
}
