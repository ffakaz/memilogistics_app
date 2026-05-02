import 'package:memilogistics_app/shared/validation_result.dart';

class UserCredentials {
  final String email;
  final String password;

  const UserCredentials({
    required this.email,
    required this.password,
  });

  /// Email validation
  bool get isValidEmail {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  /// Password validation
  bool get isValidPassword => password.length >= 6;

  /// Full validation result
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
      return ValidationResult.invalid('Password must be at least 6 characters');
    }

    return ValidationResult.valid();
  }
}