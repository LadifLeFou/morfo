// Vérifie que l'orientation EXIF est bien « cuite » dans les pixels avant
// envoi au backend — cause des rendus pivotés côté IA.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:morfo/core/image_prep.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Ce qui compte pour le backend : la sortie ne doit JAMAIS porter une balise
  // d'orientation qui ferait pivoter l'image. Un modèle d'IA lit les pixels
  // bruts ; si la balise disait encore « pivoter de 90° », il verrait la photo
  // couchée. On vérifie donc que les pixels sont autoportants.
  //
  // Note : on ne peut pas fabriquer ici un vrai JPEG « pixels couchés + balise
  // EXIF » — le paquet `image` applique l'orientation dès l'encodage. La preuve
  // de bout en bout se fait sur un vrai fichier d'iPhone.
  test('la sortie ne porte aucune orientation EXIF pivotante', () async {
    final img.Image src = img.Image(width: 200, height: 100);
    img.fill(src, color: img.ColorRgb8(120, 80, 200));
    src.exif.imageIfd.orientation = 6;

    final Uint8List prepared =
        await prepareForUpload(Uint8List.fromList(img.encodeJpg(src)));
    final img.Image after = img.decodeImage(prepared)!;

    final int? orientation = after.exif.imageIfd.orientation;
    expect(orientation == null || orientation == 1, isTrue,
        reason: 'orientation résiduelle = $orientation : un décodeur qui '
            'ignore l’EXIF verrait la photo pivotée');
  });

  test('une image déjà droite n’est pas pivotée', () async {
    final img.Image portrait = img.Image(width: 100, height: 200);
    img.fill(portrait, color: img.ColorRgb8(10, 200, 90));

    final Uint8List prepared =
        await prepareForUpload(Uint8List.fromList(img.encodeJpg(portrait)));
    final img.Image after = img.decodeImage(prepared)!;

    expect(after.width, 100);
    expect(after.height, 200);
  });

  test('le côté le plus long est borné à 1024 px, proportions conservées',
      () async {
    final img.Image big = img.Image(width: 4032, height: 3024);
    img.fill(big, color: img.ColorRgb8(200, 200, 200));

    final Uint8List prepared =
        await prepareForUpload(Uint8List.fromList(img.encodeJpg(big)));
    final img.Image after = img.decodeImage(prepared)!;

    expect(after.width, 1024);
    expect(after.height, 768); // 4:3 conservé
  });

  test('des octets illisibles sont renvoyés tels quels, sans exception',
      () async {
    final Uint8List garbage = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
    expect(await prepareForUpload(garbage), garbage);
  });
}
