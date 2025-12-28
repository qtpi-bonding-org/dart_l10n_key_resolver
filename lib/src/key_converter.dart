/// Utilities for converting between dot-notation keys and camelCase ARB keys.
///
/// Convention:
/// - Dot notation: `error.auth.failed` (used in MessageKey)
/// - CamelCase: `errorAuthFailed` (used in ARB/AppLocalizations)
class KeyConverter {
  /// Converts a dot-notation key to camelCase.
  ///
  /// Examples:
  /// - `error.timeout` → `errorTimeout`
  /// - `error.auth.failed` → `errorAuthFailed`
  /// - `template.generation.success` → `templateGenerationSuccess`
  static String dotToCamelCase(String dotKey) {
    final parts = dotKey.split('.');
    if (parts.isEmpty) return dotKey;

    final buffer = StringBuffer(parts.first.toLowerCase());

    for (int i = 1; i < parts.length; i++) {
      buffer.write(_capitalize(parts[i]));
    }

    return buffer.toString();
  }

  /// Converts a camelCase ARB key to dot-notation.
  ///
  /// Examples:
  /// - `errorTimeout` → `error.timeout`
  /// - `errorAuthFailed` → `error.auth.failed`
  /// - `templateGenerationSuccess` → `template.generation.success`
  static String camelCaseToDot(String camelKey) {
    final buffer = StringBuffer();

    for (int i = 0; i < camelKey.length; i++) {
      final char = camelKey[i];
      if (char.toUpperCase() == char && char.toLowerCase() != char) {
        // It's an uppercase letter
        if (buffer.isNotEmpty) {
          buffer.write('.');
        }
        buffer.write(char.toLowerCase());
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  /// Capitalizes the first letter of a string.
  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Validates that a dot-notation key follows the expected format.
  ///
  /// Valid keys:
  /// - Contain only lowercase letters, numbers, and dots
  /// - Don't start or end with a dot
  /// - Don't have consecutive dots
  static bool isValidDotKey(String key) {
    if (key.isEmpty) return false;
    if (key.startsWith('.') || key.endsWith('.')) return false;
    if (key.contains('..')) return false;

    final validChars = RegExp(r'^[a-z0-9.]+$');
    return validChars.hasMatch(key);
  }
}
