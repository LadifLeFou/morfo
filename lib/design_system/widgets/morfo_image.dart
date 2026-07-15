import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Import conditionnel : dart:io seulement hors web.
import 'file_image_stub.dart' if (dart.library.io) 'file_image_io.dart';
import 'holo_placeholder.dart';

/// Résout une source d'image hétérogène vers un widget affichable :
/// - `http(s)://` → image réseau cachée
/// - `blob:` (web) → image réseau
/// - chemin de fichier local (mobile) → Image.file
/// - marqueur démo `morfo://` ou vide → [HoloPlaceholder]
class MorfoImage extends StatelessWidget {
  const MorfoImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.icon,
  });

  final String url;
  final BoxFit fit;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget fallback =
        HoloPlaceholder(seed: url.isEmpty ? 'morfo' : url, icon: icon);

    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (BuildContext _, String _) => fallback,
        errorWidget: (BuildContext _, String _, Object _) => fallback,
      );
    }
    if (url.startsWith('blob:')) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (BuildContext _, Object _, StackTrace? _) => fallback,
      );
    }
    if (url.startsWith('/') || url.startsWith('file')) {
      return buildFileImage(url, fit, fallback);
    }
    return fallback;
  }
}
