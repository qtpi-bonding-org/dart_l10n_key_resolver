/// A build_runner generator that creates type-safe resolvers for l10n keys.
///
/// This package generates a resolver class that maps dot-notation message keys
/// (e.g., 'error.auth.failed') to ARB camelCase getters (e.g., `l10n.errorAuthFailed`).
///
/// ## Convention
///
/// Dot-notation keys are automatically converted to camelCase:
/// - `error.timeout` → `errorTimeout`
/// - `error.auth.failed` → `errorAuthFailed`
/// - `template.generation.success` → `templateGenerationSuccess`
///
/// ## Usage
///
/// 1. Add to your `pubspec.yaml`:
/// ```yaml
/// dev_dependencies:
///   l10n_key_resolver: ^0.1.0
///   build_runner: ^2.4.0
/// ```
///
/// 2. Create a `build.yaml` in your project root:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       l10n_key_resolver:
///         options:
///           arb_file: lib/l10n/app_en.arb
///           output_file: lib/l10n/l10n_key_resolver.g.dart
///           localizations_class: AppLocalizations
///           localizations_import: package:your_app/l10n/app_localizations.dart
/// ```
///
/// 3. Run the generator:
/// ```bash
/// dart run build_runner build
/// ```
///
/// 4. Use the generated resolver:
/// ```dart
/// final resolver = L10nKeyResolver(appLocalizations);
/// final message = resolver.resolve('error.auth.failed'); // Returns localized string
/// ```
library l10n_key_resolver;

export 'src/key_converter.dart';
