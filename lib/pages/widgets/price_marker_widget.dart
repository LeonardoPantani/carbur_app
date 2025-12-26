import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// internal cache for fuel stations brands images
final Map<String, ui.Image> _brandImageCache = {};

Future<BitmapDescriptor> priceToMarker({
  required String price,
  required Brightness brightness,
  required double pixelRatio,
  required String assetPath,
}) async {
  final double iconSize = 32 * pixelRatio;
  final double spacing = 4 * pixelRatio;
  final double horizontalPadding = 8 * pixelRatio;
  final double verticalPadding = 4 * pixelRatio;
  final double radius = 4 * pixelRatio;
  final double fontSize = 14 * pixelRatio;
  final double arrowHeight = 6 * pixelRatio;
  final double arrowWidth = 10 * pixelRatio;

  // loading logo
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
      _brandImageCache[assetPath] = logoImage;
    } catch (e) {
      debugPrint("Errore caricamento logo $assetPath: $e");
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

  // calculating sizes
  final double logoSpace = logoImage != null ? (iconSize + spacing) : 0;
  final double bubbleWidth =
      logoSpace + textPainter.width + (horizontalPadding * 2);
  final double bubbleHeight =
      (textPainter.height > iconSize ? textPainter.height : iconSize) +
      (verticalPadding * 2);

  // total height comprehensive with arrow
  final double totalWidth = bubbleWidth;
  final double totalHeight = bubbleHeight + arrowHeight;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final bgPaint = Paint()
    ..isAntiAlias = true
    ..color = brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

  // starting to draw rectangle
  final path = Path();
  path.addRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, bubbleWidth, bubbleHeight),
      Radius.circular(radius),
    ),
  );

  // triangle (arrow)
  path.moveTo(bubbleWidth / 2 - arrowWidth / 2, bubbleHeight);
  path.lineTo(bubbleWidth / 2, bubbleHeight + arrowHeight);
  path.lineTo(bubbleWidth / 2 + arrowWidth / 2, bubbleHeight);
  path.close();

  canvas.drawShadow(path, Colors.black, 3.0, true);
  canvas.drawPath(path, bgPaint);

  double currentX = horizontalPadding;
  if (logoImage != null) {
    final double iconY = (bubbleHeight - iconSize) / 2;
    canvas.drawImage(logoImage, Offset(currentX, iconY), Paint());
    currentX += iconSize + spacing;
  }

  final double textY = (bubbleHeight - textPainter.height) / 2;
  textPainter.paint(canvas, Offset(currentX, textY));

  final picture = recorder.endRecording();
  final image = await picture.toImage(totalWidth.ceil(), totalHeight.ceil());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    imagePixelRatio: pixelRatio,
  );
}
