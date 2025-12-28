import 'key_converter.dart';

/// Represents a parsed ARB entry with its metadata.
class ArbEntry {
  /// The ARB key (camelCase, e.g., 'errorAuthFailed')
  final String arbKey;

  /// The dot-notation key (e.g., 'error.auth.failed')
  final String dotKey;

  /// The default value/message
  final String value;

  /// Placeholder parameters, if any
  final List<ArbPlaceholder> placeholders;

  /// Description from ARB metadata
  final String? description;

  const ArbEntry({
    required this.arbKey,
    required this.dotKey,
    required this.value,
    this.placeholders = const [],
    this.description,
  });

  /// Whether this entry has parameters
  bool get hasParameters => placeholders.isNotEmpty;
}

/// Represents a placeholder parameter in an ARB entry.
class ArbPlaceholder {
  final String name;
  final String type;
  final String? description;

  const ArbPlaceholder({
    required this.name,
    required this.type,
    this.description,
  });

  /// Returns the Dart type for this placeholder
  String get dartType {
    return switch (type.toLowerCase()) {
      'int' || 'integer' => 'int',
      'double' || 'num' || 'number' => 'num',
      'datetime' || 'date' => 'DateTime',
      _ => 'String',
    };
  }
}

/// Parses ARB JSON into structured entries.
class ArbParser {
  /// Parses ARB JSON map into a list of ArbEntry objects.
  ///
  /// Filters out:
  /// - Keys starting with '@' (metadata)
  /// - Keys starting with '@@' (file-level metadata like @@locale)
  List<ArbEntry> parse(Map<String, dynamic> arbData) {
    final entries = <ArbEntry>[];

    for (final key in arbData.keys) {
      // Skip metadata keys
      if (key.startsWith('@')) continue;

      final value = arbData[key];
      if (value is! String) continue;

      // Get metadata for this key (if exists)
      final metadataKey = '@$key';
      final metadata = arbData[metadataKey] as Map<String, dynamic>?;

      // Parse placeholders from metadata
      final placeholders = _parsePlaceholders(metadata);

      // Convert camelCase ARB key to dot-notation
      final dotKey = KeyConverter.camelCaseToDot(key);

      entries.add(ArbEntry(
        arbKey: key,
        dotKey: dotKey,
        value: value,
        placeholders: placeholders,
        description: metadata?['description'] as String?,
      ));
    }

    // Sort by dot key for consistent output
    entries.sort((a, b) => a.dotKey.compareTo(b.dotKey));

    return entries;
  }

  /// Parses placeholder definitions from ARB metadata.
  List<ArbPlaceholder> _parsePlaceholders(Map<String, dynamic>? metadata) {
    if (metadata == null) return [];

    final placeholdersData = metadata['placeholders'] as Map<String, dynamic>?;
    if (placeholdersData == null) return [];

    final placeholders = <ArbPlaceholder>[];

    for (final entry in placeholdersData.entries) {
      final name = entry.key;
      final data = entry.value as Map<String, dynamic>?;

      placeholders.add(ArbPlaceholder(
        name: name,
        type: data?['type'] as String? ?? 'String',
        description: data?['description'] as String?,
      ));
    }

    return placeholders;
  }
}
