import 'package:test/test.dart';
import 'package:l10n_key_resolver/src/key_converter.dart';

void main() {
  group('KeyConverter', () {
    group('dotToCamelCase', () {
      test('converts simple dot notation', () {
        expect(KeyConverter.dotToCamelCase('error.timeout'), 'errorTimeout');
      });

      test('converts multi-level dot notation', () {
        expect(KeyConverter.dotToCamelCase('error.auth.failed'), 'errorAuthFailed');
      });

      test('converts deep dot notation', () {
        expect(
          KeyConverter.dotToCamelCase('template.generation.success'),
          'templateGenerationSuccess',
        );
      });

      test('handles single word', () {
        expect(KeyConverter.dotToCamelCase('error'), 'error');
      });

      test('handles empty string', () {
        expect(KeyConverter.dotToCamelCase(''), '');
      });
    });

    group('camelCaseToDot', () {
      test('converts simple camelCase', () {
        expect(KeyConverter.camelCaseToDot('errorTimeout'), 'error.timeout');
      });

      test('converts multi-word camelCase', () {
        expect(KeyConverter.camelCaseToDot('errorAuthFailed'), 'error.auth.failed');
      });

      test('converts long camelCase', () {
        expect(
          KeyConverter.camelCaseToDot('templateGenerationSuccess'),
          'template.generation.success',
        );
      });

      test('handles single word', () {
        expect(KeyConverter.camelCaseToDot('error'), 'error');
      });

      test('handles empty string', () {
        expect(KeyConverter.camelCaseToDot(''), '');
      });
    });

    group('isValidDotKey', () {
      test('accepts valid keys', () {
        expect(KeyConverter.isValidDotKey('error.timeout'), true);
        expect(KeyConverter.isValidDotKey('error.auth.failed'), true);
        expect(KeyConverter.isValidDotKey('error'), true);
        expect(KeyConverter.isValidDotKey('error1.timeout2'), true);
      });

      test('rejects invalid keys', () {
        expect(KeyConverter.isValidDotKey(''), false);
        expect(KeyConverter.isValidDotKey('.error'), false);
        expect(KeyConverter.isValidDotKey('error.'), false);
        expect(KeyConverter.isValidDotKey('error..timeout'), false);
        expect(KeyConverter.isValidDotKey('Error.Timeout'), false);
        expect(KeyConverter.isValidDotKey('error_timeout'), false); // no underscores
      });
    });

    group('roundtrip', () {
      test('dot → camel → dot preserves key', () {
        const original = 'error.auth.failed';
        final camel = KeyConverter.dotToCamelCase(original);
        final back = KeyConverter.camelCaseToDot(camel);
        expect(back, original);
      });

      test('camel → dot → camel preserves key', () {
        const original = 'errorAuthFailed';
        final dot = KeyConverter.camelCaseToDot(original);
        final back = KeyConverter.dotToCamelCase(dot);
        expect(back, original);
      });
    });
  });
}
