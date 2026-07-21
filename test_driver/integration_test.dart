// Pilote de `flutter drive` : reçoit les captures produites par
// `integration_test/screenshots_test.dart` et les écrit sur disque.

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String nom,
      List<int> octets, [
      Map<String, Object?>? args,
    ]) async {
      final File fichier = File('build/screenshots/$nom.png')
        ..createSync(recursive: true);
      fichier.writeAsBytesSync(octets);
      stdout.writeln('capture écrite : ${fichier.path}');
      return true;
    },
  );
}
