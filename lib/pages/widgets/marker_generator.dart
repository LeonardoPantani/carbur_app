import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  static final Map<String, ui.Image> _brandImageCache = {};

  static const Color colorCheap = Color(0xFF2E7D32);
  static const Color colorAverage = Color(0xFFF9A825);
  static const Color colorExpensive = Color(0xFFC62828);

  static double _lastPixelRatio = 0;

  static double _iconSize = 0;
  static double _spacing = 0;
  static double _hPadding = 0;
  static double _vPadding = 0;
  static double _radius = 0;
  static double _fontSize = 0;
  static double _arrowH = 0;
  static double _arrowW = 0;

  static double _dotTotalSize = 0;
  static double _dotCenter = 0;
  static double _dotDrawRadius = 0;

  static void initialize(double pixelRatio) {
    if (_lastPixelRatio == pixelRatio) return;
    _lastPixelRatio = pixelRatio;

    _iconSize = 28 * pixelRatio;
    _spacing = 2 * pixelRatio;
    _hPadding = 6 * pixelRatio;
    _vPadding = 4 * pixelRatio;
    _radius = 4 * pixelRatio;
    _fontSize = 14 * pixelRatio;
    _arrowH = 4 * pixelRatio;
    _arrowW = 8 * pixelRatio;

    final double size = 4 * pixelRatio;
    final double padding = 1 * pixelRatio;

    _dotTotalSize = size + padding;
    _dotCenter = _dotTotalSize / 2;
    _dotDrawRadius = (size / 2);
  }

  static Color getColorForPrice(double price, double? low, double? high) {
    if (low == null || high == null) return colorAverage;
    if (price <= low) return colorCheap;
    if (price <= high) return colorAverage;
    return colorExpensive;
  }

  static Future<BitmapDescriptor> createPriceMarker({
    required String price,
    required String assetPath,
    required Color backgroundColor,
  }) async {
    ui.Image? logoImage = _brandImageCache[assetPath];
    if (logoImage == null) {
      try {
        final ByteData data = await rootBundle.load(assetPath);
        final ui.Codec codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
          targetWidth: _iconSize.toInt(),
        );
        final ui.FrameInfo fi = await codec.getNextFrame();
        logoImage = fi.image;
        _brandImageCache[assetPath] = logoImage;
      } catch (e) {
        debugPrint("Errore logo $assetPath: $e");
      }
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: price,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double logoSpace = logoImage != null ? (_iconSize + _spacing) : 0;
    final double bubbleWidth = logoSpace + textPainter.width + (_hPadding * 2);
    final double bubbleHeight =
        (textPainter.height > _iconSize ? textPainter.height : _iconSize) +
        (_vPadding * 2);
    final double totalHeight = bubbleHeight + _arrowH;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, bubbleWidth, bubbleHeight),
          Radius.circular(_radius),
        ),
      )
      ..moveTo(bubbleWidth / 2 - _arrowW / 2, bubbleHeight)
      ..lineTo(bubbleWidth / 2, totalHeight)
      ..lineTo(bubbleWidth / 2 + _arrowW / 2, bubbleHeight)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.5), 4.0, true);

    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, bgPaint);

    double currentX = _hPadding;
    if (logoImage != null) {
      final double iconY = (bubbleHeight - _iconSize) / 2;
      canvas.drawImage(logoImage, Offset(currentX, iconY), Paint());
      currentX += _iconSize + _spacing;
    }

    final double textY = (bubbleHeight - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(currentX, textY));

    final picture = recorder.endRecording();
    final image = await picture.toImage(bubbleWidth.ceil(), totalHeight.ceil());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: _lastPixelRatio,
    );
  }

  static Future<BitmapDescriptor> createDotMarker({
    required Color backgroundColor,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final Paint fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final centerOffset = Offset(_dotCenter, _dotCenter);

    canvas.drawCircle(centerOffset, _dotDrawRadius, fillPaint);
    canvas.drawCircle(centerOffset, _dotDrawRadius, borderPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _dotTotalSize.ceil(),
      _dotTotalSize.ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}
