import 'dart:typed_data';

import '../../core/models/template.dart';

/// Arguments passés à l'écran de génération (via go_router `extra`).
class GenerateArgs {
  const GenerateArgs({
    required this.template,
    required this.bytes,
    this.sourcePath,
    this.customPrompt,
  });

  final Template template;
  final Uint8List bytes;
  final String? sourcePath;
  final String? customPrompt;
}
