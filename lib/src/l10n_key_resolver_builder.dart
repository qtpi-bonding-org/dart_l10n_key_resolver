import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';

import 'arb_parser.dart';
import 'resolver_generator.dart';

/// Builder that generates L10nKeyResolver from ARB files.
class L10nKeyResolverBuilder implements Builder {
  final BuilderOptions options;

  L10nKeyResolverBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions {
    // We trigger on the ARB file and output a .g.dart file
    final arbFile = options.config['arb_file'] as String? ?? 'lib/l10n/app_en.arb';
    final outputFile = options.config['output_file'] as String? ?? 'lib/l10n/l10n_key_resolver.g.dart';
    
    return {
      arbFile: [outputFile],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    
    // Read configuration
    final localizationsClass = options.config['localizations_class'] as String? ?? 'AppLocalizations';
    final localizationsImport = options.config['localizations_import'] as String? ?? 'app_localizations.dart';
    final generateDotKeys = options.config['generate_dot_keys'] as bool? ?? true;
    
    // Read and parse ARB file
    final arbContent = await buildStep.readAsString(inputId);
    final arbData = jsonDecode(arbContent) as Map<String, dynamic>;
    
    // Parse ARB entries
    final parser = ArbParser();
    final entries = parser.parse(arbData);
    
    // Generate resolver code
    final generator = ResolverGenerator(
      localizationsClass: localizationsClass,
      localizationsImport: localizationsImport,
      generateDotKeys: generateDotKeys,
    );
    
    final generatedCode = generator.generate(entries);
    
    // Write output
    final outputFile = options.config['output_file'] as String? ?? 'lib/l10n/l10n_key_resolver.g.dart';
    final outputId = AssetId(inputId.package, outputFile);
    
    await buildStep.writeAsString(outputId, generatedCode);
    
    log.info('Generated ${entries.length} l10n key mappings to $outputFile');
  }
}
