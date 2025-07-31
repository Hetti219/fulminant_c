import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../models/email.dart';
import '../../../models/password.dart';
import '../../../models/name.dart';
import '../../../repositories/auth_repository.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository _authRepository;

  SignupBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SignupState()) {
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupFullNameChanged>(_onFullNameChanged);
    on<SignupDateOfBirthChanged>(_onDateOfBirthChanged);
    on<SignupSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: _isFormValid(email, state.password, state.fullName, state.dateOfBirth),
      ),
    );
  }

  void _onPasswordChanged(SignupPasswordChanged event, Emitter<SignupState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: _isFormValid(state.email, password, state.fullName, state.dateOfBirth),
      ),
    );
  }

  void _onFullNameChanged(SignupFullNameChanged event, Emitter<SignupState> emit) {
    final fullName = Name.dirty(event.fullName);
    emit(
      state.copyWith(
        fullName: fullName,
        isValid: _isFormValid(state.email, state.password, fullName, state.dateOfBirth),
      ),
    );
  }

  void _onDateOfBirthChanged(SignupDateOfBirthChanged event, Emitter<SignupState> emit) {
    emit(
      state.copyWith(
        dateOfBirth: event.dateOfBirth,
        isValid: _isFormValid(state.email, state.password, state.fullName, event.dateOfBirth),
      ),
    );
  }

  void _onSubmitted(SignupSubmitted event, Emitter<SignupState> emit) async {
    if (state.isValid && state.dateOfBirth != null) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await _authRepository.signUp(
          email: state.email.value,
          password: state.password.value,
          fullName: state.fullName.value,
          dateOfBirth: state.dateOfBirth!,
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

  bool _isFormValid(Email email, Password password, Name fullName, DateTime? dateOfBirth) {
    return Formz.validate([email, password, fullName]) && dateOfBirth != null;
  }
}