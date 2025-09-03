import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../models/email.dart';
import '../../../models/password.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/biometric_service.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final BiometricService _biometricService;

  LoginBloc({
    required AuthRepository authRepository,
    required BiometricService biometricService,
  })  : _authRepository = authRepository,
        _biometricService = biometricService,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<PasswordResetRequested>(
        _onPasswordResetRequested); //Password reset event handler
    //Biometric event handlers
    on<BiometricAuthenticationRequested>(_onBiometricAuthenticationRequested);
    on<BiometricAuthenticationCompleted>(_onBiometricAuthenticationCompleted);
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
        requiresBiometricAuth: false,
        // Reset biometric state on email change
        biometricAuthError: null,
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

        final bool biometricEnabled =
            await _biometricService.isBiometricEnabled();

        if (biometricEnabled) {
          // Biometric 2FA is enabled - require biometric authentication
          emit(state.copyWith(
            status: FormzSubmissionStatus.initial,
            requiresBiometricAuth: true,
            biometricAuthError: null,
          ));

          // Automatically trigger biometric authentication
          add(BiometricAuthenticationRequested());
        } else {
          // No biometric 2FA - login complete
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        }
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

  void _onBiometricAuthenticationRequested(
    BiometricAuthenticationRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      isBiometricAuthInProgress: true,
      biometricAuthError: null,
    ));

    try {
      final BiometricAuthResult result =
          await _biometricService.authenticateForLogin(
        state.email.value,
      );

      switch (result) {
        case BiometricAuthResult.success:
          add(const BiometricAuthenticationCompleted(success: true));
          break;
        case BiometricAuthResult.failed:
          add(const BiometricAuthenticationCompleted(
            success: false,
            error: 'Biometric authentication failed. Please try again.',
          ));
          break;
        case BiometricAuthResult.notEnabled:
          add(const BiometricAuthenticationCompleted(
            success: false,
            error: 'Biometric authentication is no longer enabled.',
          ));
          break;
        case BiometricAuthResult.error:
          add(const BiometricAuthenticationCompleted(
            success: false,
            error: 'Error during biometric authentication.',
          ));
          break;
      }
    } catch (e) {
      add(BiometricAuthenticationCompleted(
        success: false,
        error:
            e is BiometricException ? e.message : 'Unexpected biometric error.',
      ));
    }
  }

  void _onBiometricAuthenticationCompleted(
    BiometricAuthenticationCompleted event,
    Emitter<LoginState> emit,
  ) {
    if (event.success) {
      // Biometric authentication successful - complete login
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        isBiometricAuthInProgress: false,
        requiresBiometricAuth: false,
        biometricAuthError: null,
      ));
    } else {
      // Biometric authentication failed - but user is still logged into Firebase
      // Show error and allow retry or logout
      emit(state.copyWith(
        isBiometricAuthInProgress: false,
        biometricAuthError: event.error,
      ));
    }
  }
}
