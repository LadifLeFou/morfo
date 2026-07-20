
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Côté le plus long, en pixels, de l'image envoyée au backend.
const int _kMaxSide = 1024;

/// Prépare une photo avant envoi : orientation appliquée aux pixels, taille
/// bornée, ré-encodage JPEG.
///
/// Indispensable : un iPhone en portrait stocke les pixels **en paysage** et
/// ajoute une balise EXIF `Orientation`. Les visionneuses la respectent, mais
/// les modèles d'IA décodent les pixels bruts et l'ignorent — le rendu revenait
/// donc pivoté. On « cuit » la rotation dans les pixels et on retire la balise,
/// pour que ce que voit le modèle soit exactement ce que voit l'utilisateur.
///
/// Rendu en isolate ([compute]) : décoder puis ré-encoder une photo d'iPhone
/// bloquerait l'UI plusieurs centaines de millisecondes.
Future<Uint8List> prepareForUpload(Uint8List input) =>
    compute(_prepare, input);

Uint8List _prepare(Uint8List input) {
  try {
    // `decodeImage` ne se contente pas de renvoyer null sur des octets
    // illisibles : selon le format qu'il croit reconnaître, il lève. On
    // rattrape pour qu'une photo corrompue dégrade au lieu de planter.
    final img.Image? decoded = img.decodeImage(input);
    if (decoded == null) return input;

    // Applique la rotation EXIF aux pixels et neutralise la balise.
    img.Image out = img.bakeOrientation(decoded);

    // Borne le côté le plus long en conservant les proportions.
    final int longest = out.width > out.height ? out.width : out.height;
    if (longest > _kMaxSide) {
      final bool landscape = out.width >= out.height;
      out = img.copyResize(
        out,
        width: landscape ? _kMaxSide : null,
        height: landscape ? null : _kMaxSide,
        interpolation: img.Interpolation.average,
      );
    }

    return img.encodeJpg(out, quality: 88);
  } catch (_) {
    return input;
  }
}
