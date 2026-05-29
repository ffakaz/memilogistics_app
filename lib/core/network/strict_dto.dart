// lib/core/network/strict_dto.dart

class StrictDto {
  StrictDto._();

  static T requireField<T>(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key) || json[key] == null) {
      throw FormatException('Required field "$key" is missing or null');
    }
    final value = json[key];
    if (value is T) return value;
    // Allow some basic conversions
    if (T == double && value is num) return (value.toDouble() as dynamic) as T;
    if (T == int && value is num) return (value.toInt() as dynamic) as T;
    if (T == String) return value.toString() as T;
    throw FormatException('Field "$key" has unexpected type: ${value.runtimeType}, expected $T');
  }

  static T? optionalField<T>(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key) || json[key] == null) return null;
    final value = json[key];
    if (value is T) return value;
    if (T == double && value is num) return (value.toDouble() as dynamic) as T;
    if (T == int && value is num) return (value.toInt() as dynamic) as T;
    if (T == String) return value.toString() as T;
    return null;
  }
}
