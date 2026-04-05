import 'package:formz/formz.dart';

enum PasswordValidationError {
  invalid,
  tooShort,
  noUppercase,
  noLowercase,
  noDigit,
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');

  @override
  PasswordValidationError? validator(String value) {
    // Minimum 8 characters
    if (value.length < 8) {
      return PasswordValidationError.tooShort;
    }

    // Require at least one uppercase letter
    if (!_uppercaseRegex.hasMatch(value)) {
      return PasswordValidationError.noUppercase;
    }

    // Require at least one lowercase letter
    if (!_lowercaseRegex.hasMatch(value)) {
      return PasswordValidationError.noLowercase;
    }

    // Require at least one digit
    if (!_digitRegex.hasMatch(value)) {
      return PasswordValidationError.noDigit;
    }

    return null;
  }

  String? get errorMessage {
    if (isPure) return null;

    switch (error) {
      case PasswordValidationError.tooShort:
        return 'Password must be at least 8 characters';
      case PasswordValidationError.noUppercase:
        return 'Password must contain at least one uppercase letter';
      case PasswordValidationError.noLowercase:
        return 'Password must contain at least one lowercase letter';
      case PasswordValidationError.noDigit:
        return 'Password must contain at least one number';
      case PasswordValidationError.invalid:
      case null:
        return null;
    }
  }
}