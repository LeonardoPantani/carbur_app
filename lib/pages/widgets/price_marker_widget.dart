import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/logger.dart';

// internal cache for fuel stations brands images
final Map<String, ui.Image> _brandImageCache = {};

Future<BitmapDescriptor> priceToMarker({
  required String price,
  required Brightness brightness,
  required double pixelRatio,
  required String assetPath,
}) async {
  final double iconSize = 16 * pixelRatio;
  final double spacing = 3 * pixelRatio;
  final double horizontalPadding = 4 * pixelRatio;
  final double verticalPadding = 2 * pixelRatio;
  final double radius = 4 * pixelRatio;
  final double fontSize = 12 * pixelRatio;

  // 1. loading logo (nice if already cached)
  ui.Image? logoImage = _brandImageCache[assetPath];
  
  if (logoImage == null) {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: iconSize.toInt(),
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      logoImage = fi.image;
      _brandImageCache[assetPath] = logoImage; // saving in logos cache
    } catch (e) {
      logger.i("Errore caricamento logo $assetPath: $e");
    }
  }

  final textPainter = TextPainter(
    text: TextSpan(
      text: price,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  // calculating dimensions
  final double logoSpace = logoImage != null ? (iconSize + spacing) : 0;
  final double width = logoSpace + textPainter.width + (horizontalPadding * 2);
  final double height = (textPainter.height > iconSize ? textPainter.height : iconSize) + (verticalPadding * 2);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final bgPaint = Paint()
    ..isAntiAlias = true
    ..color = brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white;

  // background
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, height), Radius.circular(radius)),
    bgPaint,
  );

  double currentX = horizontalPadding;

  // drawing logo
  if (logoImage != null) {
    final double iconY = (height - iconSize) / 2;
    canvas.drawImage(logoImage, Offset(currentX, iconY), Paint());
    currentX += iconSize + spacing;
  }

  // drawing text
  final double textY = (height - textPainter.height) / 2;
  textPainter.paint(canvas, Offset(currentX, textY));

  final picture = recorder.endRecording();
  final image = await picture.toImage(width.ceil(), height.ceil());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    imagePixelRatio: pixelRatio,
  );
}