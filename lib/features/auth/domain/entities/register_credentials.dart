import 'package:memilogistics_app/shared/validation_result.dart';

class RegisterCredentials {
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterCredentials({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  bool get isValidEmail {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  bool get isValidPassword => password.length >= 8 && password.length <= 20;

  ValidationResult validate() {
    if (email.isEmpty) {
      return ValidationResult.invalid('Email is required');
    }

    if (!isValidEmail) {
      return ValidationResult.invalid('Invalid email format');
    }

    if (password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (!isValidPassword) {
      return ValidationResult.invalid('Password must be 8-20 characters');
    }

    if (password != confirmPassword) {
      return ValidationResult.invalid('Passwords do not match');
    }

    return ValidationResult.valid();
  }
}
