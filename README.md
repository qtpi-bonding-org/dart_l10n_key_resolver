# l10n_key_resolver

A build_runner generator that creates type-safe resolvers for Flutter l10n keys, mapping dot-notation keys (e.g., `error.auth.failed`) to ARB camelCase getters (e.g., `l10n.errorAuthFailed`).

## Features

- **Automatic key conversion**: Dot-notation keys → camelCase ARB getters
- **Parameterized message support**: Handles placeholders with type safety
- **Validation helpers**: Check if keys exist at runtime
- **Bidirectional mapping**: Convert between dot and camelCase formats

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  l10n_key_resolver:
    path: ../flutter_l10n_key_resolver  # or git/pub reference
  build_runner: ^2.4.0
```

## Configuration

Create or update `build.yaml` in your project root:

```yaml
targets:
  $default:
    builders:
      l10n_key_resolver:l10n_key_resolver:
        options:
          arb_file: lib/l10n/app_en.arb
          output_file: lib/l10n/l10n_key_resolver.g.dart
          localizations_class: AppLocalizations
          localizations_import: app_localizations.dart
          generate_dot_keys: true
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `arb_file` | `lib/l10n/app_en.arb` | Path to your primary ARB file |
| `output_file` | `lib/l10n/l10n_key_resolver.g.dart` | Generated resolver output path |
| `localizations_class` | `AppLocalizations` | Your Flutter localizations class name |
| `localizations_import` | `app_localizations.dart` | Import path for localizations class |
| `generate_dot_keys` | `true` | Use dot-notation keys (vs camelCase) |

## Usage

### 1. Run the generator

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Use the generated resolver

```dart
import 'l10n/l10n_key_resolver.g.dart';

class MyLocalizationService {
  final AppLocalizations _l10n;
  late final L10nKeyResolver _resolver;

  MyLocalizationService(this._l10n) {
    _resolver = L10nKeyResolver(_l10n);
  }

  String translate(String key, {Map<String, dynamic>? args}) {
    return _resolver.resolve(key, args: args) ?? key;
  }
}
```

### 3. Translate with dot-notation keys

```dart
// Simple keys
final message = resolver.resolve('error.auth.failed');
// Returns: "Authentication failed. Please try again."

// Parameterized keys
final warning = resolver.resolve(
  'template.generation.performance_warning',
  args: {'timeMs': 5000, 'suggestion': 'reduce fields'},
);
// Returns: "Generation took longer than expected (5000ms). Consider: reduce fields"
```

## Key Convention

The generator converts between dot-notation and camelCase:

| Dot Notation | ARB Key (camelCase) |
|--------------|---------------------|
| `error.timeout` | `errorTimeout` |
| `error.auth.failed` | `errorAuthFailed` |
| `template.generation.success` | `templateGenerationSuccess` |
| `async_ui.error.generic` | `asyncUiErrorGeneric` |

## Generated Code

The generator creates a resolver class with:

```dart
class L10nKeyResolver {
  final AppLocalizations _l10n;
  
  const L10nKeyResolver(this._l10n);

  /// Resolves a dot-notation key to its localized string.
  String? resolve(String key, {Map<String, dynamic>? args}) {
    return switch (key) {
      'error.timeout' => _l10n.errorTimeout,
      'error.auth.failed' => _l10n.errorAuthFailed,
      // ... all keys from your ARB file
      _ => null,
    };
  }

  /// Set of all known keys (for validation/debugging).
  static const knownKeys = <String>{'error.timeout', 'error.auth.failed', ...};

  /// Checks if a key is known to this resolver.
  static bool hasKey(String key) => knownKeys.contains(key);
}
```

## Utilities

The package also exports `KeyConverter` for manual conversions:

```dart
import 'package:l10n_key_resolver/l10n_key_resolver.dart';

// Dot to camelCase
KeyConverter.dotToCamelCase('error.auth.failed'); // 'errorAuthFailed'

// CamelCase to dot
KeyConverter.camelCaseToDot('errorAuthFailed'); // 'error.auth.failed'

// Validate dot-notation key
KeyConverter.isValidDotKey('error.auth.failed'); // true
KeyConverter.isValidDotKey('Error.Auth'); // false (uppercase)
```

## License

MIT
