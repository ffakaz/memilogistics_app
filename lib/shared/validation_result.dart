abstract class ValidationResult {
  const ValidationResult();

  factory ValidationResult.valid() = Valid;

  factory ValidationResult.invalid(String message) = Invalid;

  bool get isValid;

  String? get message;
}

class Valid extends ValidationResult {
  const Valid();

  @override
  bool get isValid => true;

  @override
  String? get message => null;
}

class Invalid extends ValidationResult {
  final String _message;

  const Invalid(this._message);

  @override
  bool get isValid => false;

  @override
  String? get message => _message;
}