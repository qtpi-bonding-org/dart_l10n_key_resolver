import 'package:build/build.dart';
import 'src/l10n_key_resolver_builder.dart';

/// Creates the l10n key resolver builder.
///
/// Configure in your `build.yaml`:
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
Builder l10nKeyResolverBuilder(BuilderOptions options) {
  return L10nKeyResolverBuilder(options);
}
