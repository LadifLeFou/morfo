import 'dart:io';

import 'package:flutter/widgets.dart';

/// Mobile/desktop : rend un fichier image local.
Widget buildFileImage(String path, BoxFit fit, Widget fallback) {
  final String p =
      path.startsWith('file://') ? Uri.parse(path).toFilePath() : path;
  return Image.file(
    File(p),
    fit: fit,
    errorBuilder: (BuildContext _, Object _, StackTrace? _) => fallback,
  );
}
