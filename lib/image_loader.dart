import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

Future<ui.Image> loadImageFromAssets(String assetPath) async {
  ByteData bd = await rootBundle.load(assetPath);

  Uint8List bytes = Uint8List.view(bd.buffer);
  ui.Codec codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}