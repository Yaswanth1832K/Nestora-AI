/// Input validation utilities.
abstract final class Validators {
  Validators._();

  static bool isValidEmail(String? value) {
    if (value == null || value.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  static bool isValidPassword(String? value, {int minLength = 6}) {
    if (value == null) return false;
    return value.length >= minLength;
  }
}
