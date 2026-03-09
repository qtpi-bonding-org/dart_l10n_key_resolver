import 'package:test/test.dart';
import 'package:l10n_key_resolver/src/arb_parser.dart';
import 'package:l10n_key_resolver/src/resolver_generator.dart';

void main() {
  group('ResolverGenerator', () {
    late ResolverGenerator generator;

    setUp(() {
      generator = ResolverGenerator(
        localizationsClass: 'AppLocalizations',
        localizationsImport: 'app_localizations.dart',
        generateDotKeys: true,
      );
    });

    test('generates header with imports', () {
      final entries = <ArbEntry>[];
      final code = generator.generate(entries);

      expect(code, contains('// GENERATED CODE - DO NOT MODIFY BY HAND'));
      expect(code, contains("import 'app_localizations.dart';"));
    });

    test('generates class with constructor', () {
      final entries = <ArbEntry>[];
      final code = generator.generate(entries);

      expect(code, contains('class L10nKeyResolver {'));
      expect(code, contains('final AppLocalizations _l10n;'));
      expect(code, contains('const L10nKeyResolver(this._l10n);'));
    });

    test('generates resolve method for simple keys', () {
      final entries = [
        const ArbEntry(
          arbKey: 'errorTimeout',
          dotKey: 'error.timeout',
          value: 'Timeout',
        ),
      ];

      final code = generator.generate(entries);

      expect(code, contains("'error.timeout' => _l10n.errorTimeout,"));
    });

    test('generates resolve method for parameterized keys', () {
      final entries = [
        const ArbEntry(
          arbKey: 'templateFieldsCount',
          dotKey: 'template.fields.count',
          value: '{count} Fields',
          placeholders: [ArbPlaceholder(name: 'count', type: 'int')],
        ),
      ];

      final code = generator.generate(entries);

      expect(
        code,
        contains("'template.fields.count' => _l10n.templateFieldsCount("),
      );
      expect(code, contains("args?['count'] as int? ?? 0"));
    });

    test('generates knownKeys set', () {
      final entries = [
        const ArbEntry(
          arbKey: 'errorTimeout',
          dotKey: 'error.timeout',
          value: 'Timeout',
        ),
        const ArbEntry(
          arbKey: 'successGeneric',
          dotKey: 'success.generic',
          value: 'Success',
        ),
      ];

      final code = generator.generate(entries);

      expect(code, contains('static const knownKeys = <String>{'));
      expect(code, contains("'error.timeout',"));
      expect(code, contains("'success.generic',"));
    });

    test('generates hasKey method', () {
      final entries = <ArbEntry>[];
      final code = generator.generate(entries);

      expect(
        code,
        contains('static bool hasKey(String key) => knownKeys.contains(key);'),
      );
    });

    test('generates bidirectional key maps when generateDotKeys is true', () {
      final entries = [
        const ArbEntry(
          arbKey: 'errorTimeout',
          dotKey: 'error.timeout',
          value: 'Timeout',
        ),
      ];

      final code = generator.generate(entries);

      expect(code, contains('static const arbToDotKey = <String, String>{'));
      expect(code, contains("'errorTimeout': 'error.timeout',"));
      expect(code, contains('static const dotToArbKey = <String, String>{'));
      expect(code, contains("'error.timeout': 'errorTimeout',"));
    });

    test('uses arbKey when generateDotKeys is false', () {
      final gen = ResolverGenerator(
        localizationsClass: 'AppLocalizations',
        localizationsImport: 'app_localizations.dart',
        generateDotKeys: false,
      );

      final entries = [
        const ArbEntry(
          arbKey: 'errorTimeout',
          dotKey: 'error.timeout',
          value: 'Timeout',
        ),
      ];

      final code = gen.generate(entries);

      expect(code, contains("'errorTimeout' => _l10n.errorTimeout,"));
      expect(code, isNot(contains("'error.timeout' =>")));
    });

    test('handles multiple parameter types', () {
      final entries = [
        const ArbEntry(
          arbKey: 'complexMessage',
          dotKey: 'complex.message',
          value: '{name} did {count} things at {time}',
          placeholders: [
            ArbPlaceholder(name: 'name', type: 'String'),
            ArbPlaceholder(name: 'count', type: 'int'),
            ArbPlaceholder(name: 'time', type: 'DateTime'),
          ],
        ),
      ];

      final code = generator.generate(entries);

      expect(code, contains("args?['name'] as String? ?? ''"));
      expect(code, contains("args?['count'] as int? ?? 0"));
      expect(code, contains("args?['time'] as DateTime? ?? DateTime.now()"));
    });

    test('generates L10nKeys class with constants', () {
      final entries = [
        const ArbEntry(
          arbKey: 'errorTimeout',
          dotKey: 'error.timeout',
          value: 'Timeout',
        ),
        const ArbEntry(
          arbKey: 'successGeneric',
          dotKey: 'success.generic',
          value: 'Success',
        ),
      ];

      final code = generator.generate(entries);

      expect(code, contains('abstract class L10nKeys {'));
      expect(
        code,
        contains("static const errorTimeout = 'error.timeout';"),
      );
      expect(
        code,
        contains("static const successGeneric = 'success.generic';"),
      );
    });

    test('L10nKeys uses arbKey when generateDotKeys is false', () {
      final gen = ResolverGenerator(
        localizationsClass: 'AppLocalizations',
        localizationsImport: 'app_localizations.dart',
        generateDotKeys: false,
      );

      final entries = [
        const ArbEntry(
          arbKey: 'errorTimeout',
          dotKey: 'error.timeout',
          value: 'Timeout',
        ),
      ];

      final code = gen.generate(entries);

      expect(code, contains("static const errorTimeout = 'errorTimeout';"));
    });

    test('L10nKeys includes parameterized keys', () {
      final entries = [
        const ArbEntry(
          arbKey: 'templateFieldsCount',
          dotKey: 'template.fields.count',
          value: '{count} Fields',
          placeholders: [ArbPlaceholder(name: 'count', type: 'int')],
        ),
      ];

      final code = generator.generate(entries);

      expect(
        code,
        contains(
          "static const templateFieldsCount = 'template.fields.count';",
        ),
      );
    });

    test('generates valid Dart code structure', () {
      final entries = [
        const ArbEntry(
          arbKey: 'simple',
          dotKey: 'simple',
          value: 'Simple',
        ),
        const ArbEntry(
          arbKey: 'withParam',
          dotKey: 'with.param',
          value: '{n}',
          placeholders: [ArbPlaceholder(name: 'n', type: 'int')],
        ),
      ];

      final code = generator.generate(entries);

      // Check balanced braces
      final openBraces = '{'.allMatches(code).length;
      final closeBraces = '}'.allMatches(code).length;
      expect(openBraces, closeBraces);

      // Check balanced parentheses
      final openParens = '('.allMatches(code).length;
      final closeParens = ')'.allMatches(code).length;
      expect(openParens, closeParens);
    });
  });
}
