/// Form validation helpers used across the app.
///
/// Naming note:
///   - Getters (no args): [username], [password]  — pass directly as `validator:`
///   - Methods (with args): [required], [email], [confirmPassword], [phone], [combine]
class AppValidators {
  AppValidators._();

  // ── Getters (used as tear-offs: validator: AppValidators.username) ──────────

  /// Validates that the username is not blank and meets minimum length.
  static String? Function(String?) get username => (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Username is required';
        }
        if (value.trim().length < 3) {
          return 'Username must be at least 3 characters';
        }
        return null;
      };

  /// Validates that the password is not blank and meets minimum length.
  static String? Function(String?) get password => (String? value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      };

  // ── Methods (called inline in validator: lambdas) ───────────────────────────

  /// Validates that [value] is not blank.
  /// [fieldName] is shown in the error message, e.g. 'Full name'.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates basic email format. Returns null if [value] is null/empty
  /// (treat as optional — wrap in your own null-check if required).
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  /// Validates that [value] matches [other] (e.g. password confirmation).
  static String? confirmPassword(String? value, String? other) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != other) return 'Passwords do not match';
    return null;
  }

  /// Validates an optional phone number.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  /// Runs [value] through each validator in [fns] and returns the first error.
  static String? combine(
      String? value, List<String? Function(String?)> fns) {
    for (final fn in fns) {
      final result = fn(value);
      if (result != null) return result;
    }
    return null;
  }
}

/// Backward-compatible alias.
typedef Validators = AppValidators;