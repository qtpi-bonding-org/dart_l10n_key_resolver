import 'package:test/test.dart';
import 'package:l10n_key_resolver/src/arb_parser.dart';

void main() {
  group('ArbParser', () {
    late ArbParser parser;

    setUp(() {
      parser = ArbParser();
    });

    test('parses simple string entries', () {
      final arb = {
        '@@locale': 'en',
        'errorTimeout': 'The operation timed out.',
        'successGeneric': 'Success!',
      };

      final entries = parser.parse(arb);

      expect(entries.length, 2);
      expect(entries[0].arbKey, 'errorTimeout');
      expect(entries[0].dotKey, 'error.timeout');
      expect(entries[0].value, 'The operation timed out.');
      expect(entries[0].hasParameters, false);
    });

    test('skips metadata keys starting with @', () {
      final arb = {
        '@@locale': 'en',
        'errorTimeout': 'Timeout',
        '@errorTimeout': {'description': 'Error message'},
      };

      final entries = parser.parse(arb);

      expect(entries.length, 1);
      expect(entries[0].arbKey, 'errorTimeout');
    });

    test('parses entries with placeholders', () {
      final arb = {
        'templateFieldsCount': '{count} Fields',
        '@templateFieldsCount': {
          'placeholders': {
            'count': {'type': 'int'},
          },
        },
      };

      final entries = parser.parse(arb);

      expect(entries.length, 1);
      expect(entries[0].hasParameters, true);
      expect(entries[0].placeholders.length, 1);
      expect(entries[0].placeholders[0].name, 'count');
      expect(entries[0].placeholders[0].dartType, 'int');
    });

    test('parses multiple placeholders', () {
      final arb = {
        'performanceWarning': 'Took {timeMs}ms. {suggestion}',
        '@performanceWarning': {
          'placeholders': {
            'timeMs': {'type': 'int'},
            'suggestion': {'type': 'String'},
          },
        },
      };

      final entries = parser.parse(arb);

      expect(entries[0].placeholders.length, 2);
      expect(entries[0].placeholders[0].name, 'timeMs');
      expect(entries[0].placeholders[0].dartType, 'int');
      expect(entries[0].placeholders[1].name, 'suggestion');
      expect(entries[0].placeholders[1].dartType, 'String');
    });

    test('extracts description from metadata', () {
      final arb = {
        'errorTimeout': 'Timeout',
        '@errorTimeout': {'description': 'Shown when operation times out'},
      };

      final entries = parser.parse(arb);

      expect(entries[0].description, 'Shown when operation times out');
    });

    test('sorts entries by dot key', () {
      final arb = {
        'zzzLast': 'Last',
        'aaaFirst': 'First',
        'mmmMiddle': 'Middle',
      };

      final entries = parser.parse(arb);

      expect(entries[0].dotKey, 'aaa.first');
      expect(entries[1].dotKey, 'mmm.middle');
      expect(entries[2].dotKey, 'zzz.last');
    });

    test('handles entries without metadata', () {
      final arb = {
        'simpleKey': 'Simple value',
      };

      final entries = parser.parse(arb);

      expect(entries.length, 1);
      expect(entries[0].description, null);
      expect(entries[0].placeholders, isEmpty);
    });
  });

  group('ArbPlaceholder', () {
    test('maps type to dartType correctly', () {
      expect(
        const ArbPlaceholder(name: 'n', type: 'int').dartType,
        'int',
      );
      expect(
        const ArbPlaceholder(name: 'n', type: 'integer').dartType,
        'int',
      );
      expect(
        const ArbPlaceholder(name: 'n', type: 'double').dartType,
        'num',
      );
      expect(
        const ArbPlaceholder(name: 'n', type: 'num').dartType,
        'num',
      );
      expect(
        const ArbPlaceholder(name: 'n', type: 'DateTime').dartType,
        'DateTime',
      );
      expect(
        const ArbPlaceholder(name: 'n', type: 'String').dartType,
        'String',
      );
      expect(
        const ArbPlaceholder(name: 'n', type: 'unknown').dartType,
        'String',
      );
    });
  });
}
