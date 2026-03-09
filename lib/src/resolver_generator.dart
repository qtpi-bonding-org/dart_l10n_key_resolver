import 'arb_parser.dart';

/// Generates the L10nKeyResolver class from parsed ARB entries.
class ResolverGenerator {
  final String localizationsClass;
  final String localizationsImport;
  final bool generateDotKeys;

  ResolverGenerator({
    required this.localizationsClass,
    required this.localizationsImport,
    this.generateDotKeys = true,
  });

  /// Generates the complete resolver file content.
  String generate(List<ArbEntry> entries) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generator: l10n_key_resolver');
    buffer.writeln('// Generated at: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    buffer.writeln("import '$localizationsImport';");
    buffer.writeln();

    // Class definition
    buffer.writeln('/// Generated resolver for l10n keys.');
    buffer.writeln('///');
    buffer.writeln('/// Maps dot-notation keys to $localizationsClass getters.');
    buffer.writeln('///');
    buffer.writeln('/// Usage:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// final resolver = L10nKeyResolver(l10n);');
    buffer.writeln("/// final message = resolver.resolve('error.auth.failed');");
    buffer.writeln('/// ```');
    buffer.writeln('class L10nKeyResolver {');
    buffer.writeln('  final $localizationsClass _l10n;');
    buffer.writeln();
    buffer.writeln('  const L10nKeyResolver(this._l10n);');
    buffer.writeln();

    // Generate resolve method
    _generateResolveMethod(buffer, entries);

    // Generate known keys set
    _generateKnownKeys(buffer, entries);

    // Close class
    buffer.writeln('}');
    buffer.writeln();

    // Generate keys constants class
    _generateKeysClass(buffer, entries);

    return buffer.toString();
  }

  void _generateResolveMethod(StringBuffer buffer, List<ArbEntry> entries) {
    buffer.writeln('  /// Resolves a dot-notation key to its localized string.');
    buffer.writeln('  ///');
    buffer.writeln('  /// Returns null if the key is not found.');
    buffer.writeln('  ///');
    buffer.writeln('  /// For parameterized messages, pass the arguments map.');
    buffer.writeln('  String? resolve(String key, {Map<String, dynamic>? args}) {');
    buffer.writeln('    return switch (key) {');

    // Group entries by whether they have parameters
    final simpleEntries = entries.where((e) => !e.hasParameters).toList();
    final paramEntries = entries.where((e) => e.hasParameters).toList();

    // Simple entries (no parameters)
    if (simpleEntries.isNotEmpty) {
      buffer.writeln('      // Simple keys (no parameters)');
      for (final entry in simpleEntries) {
        final dotKey = generateDotKeys ? entry.dotKey : entry.arbKey;
        buffer.writeln("      '$dotKey' => _l10n.${entry.arbKey},");
      }
    }

    // Parameterized entries
    if (paramEntries.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('      // Parameterized keys');
      for (final entry in paramEntries) {
        final dotKey = generateDotKeys ? entry.dotKey : entry.arbKey;
        final params = _generateParameterCall(entry);
        buffer.writeln("      '$dotKey' => _l10n.${entry.arbKey}($params),");
      }
    }

    buffer.writeln();
    buffer.writeln('      _ => null,');
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln();
  }

  String _generateParameterCall(ArbEntry entry) {
    final params = <String>[];

    for (final placeholder in entry.placeholders) {
      final name = placeholder.name;
      final dartType = placeholder.dartType;
      final defaultValue = _getDefaultValue(dartType);

      params.add("args?['$name'] as $dartType? ?? $defaultValue");
    }

    return params.join(', ');
  }

  String _getDefaultValue(String dartType) {
    return switch (dartType) {
      'int' => '0',
      'num' || 'double' => '0.0',
      'bool' => 'false',
      'DateTime' => 'DateTime.now()',
      _ => "''",
    };
  }

  void _generateKnownKeys(StringBuffer buffer, List<ArbEntry> entries) {
    buffer.writeln('  /// Set of all known keys (for validation/debugging).');
    buffer.writeln('  static const knownKeys = <String>{');

    for (final entry in entries) {
      final dotKey = generateDotKeys ? entry.dotKey : entry.arbKey;
      buffer.writeln("    '$dotKey',");
    }

    buffer.writeln('  };');
    buffer.writeln();

    buffer.writeln('  /// Checks if a key is known to this resolver.');
    buffer.writeln('  static bool hasKey(String key) => knownKeys.contains(key);');
    buffer.writeln();

    // Generate reverse lookup (camelCase to dot)
    if (generateDotKeys) {
      buffer.writeln('  /// Maps ARB camelCase keys to dot-notation keys.');
      buffer.writeln('  static const arbToDotKey = <String, String>{');
      for (final entry in entries) {
        buffer.writeln("    '${entry.arbKey}': '${entry.dotKey}',");
      }
      buffer.writeln('  };');
      buffer.writeln();

      buffer.writeln('  /// Maps dot-notation keys to ARB camelCase keys.');
      buffer.writeln('  static const dotToArbKey = <String, String>{');
      for (final entry in entries) {
        buffer.writeln("    '${entry.dotKey}': '${entry.arbKey}',");
      }
      buffer.writeln('  };');
    }
  }

  void _generateKeysClass(StringBuffer buffer, List<ArbEntry> entries) {
    buffer.writeln('/// Type-safe constants for all l10n keys.');
    buffer.writeln('///');
    buffer.writeln('/// Usage:');
    buffer.writeln('/// ```dart');
    buffer.writeln("/// l10n.translate(L10nKeys.errorTimeout);");
    buffer.writeln('/// ```');
    buffer.writeln('abstract class L10nKeys {');

    for (final entry in entries) {
      final key = generateDotKeys ? entry.dotKey : entry.arbKey;
      buffer.writeln("  static const ${entry.arbKey} = '$key';");
    }

    buffer.writeln('}');
  }
}
