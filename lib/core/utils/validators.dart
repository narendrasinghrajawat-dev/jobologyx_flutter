/// Reusable form-field validators shared across every feature's forms.
/// Each returns `null` when valid, or an error message to show below the
/// field.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w\.\-+]+@[\w\-]+\.[\w\-.]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return "Email is required";
    if (!_emailPattern.hasMatch(v)) return "Enter a valid email address";
    return null;
  }

  static String? password(String? value) {
    final v = value ?? "";
    if (v.isEmpty) return "Password is required";
    if (v.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final v = value ?? "";
    if (v.isEmpty) return "Please confirm your password";
    if (v != password) return "Passwords do not match";
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return "Name is required";
    if (v.length < 2) return "Name must be at least 2 characters";
    return null;
  }

  /// Phone is optional almost everywhere — only validates format if non-empty.
  static String? phone(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return null;
    if (v.length < 7 || !RegExp(r'^[0-9+\-\s()]+$').hasMatch(v)) {
      return "Enter a valid phone number";
    }
    return null;
  }

  static String? required(String? value, {String fieldName = "This field"}) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return "$fieldName is required";
    return null;
  }
}
