import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/brand_service.dart';

class BrandLogoWidget extends StatelessWidget {
  final String brandName;
  final double size;

  const BrandLogoWidget({
    super.key,
    required this.brandName,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final String? localPath = BrandService.instance.getLogoPathForBrand(
      brandName,
    );

    if (localPath != null) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => _buildFallback(),
        );
      }
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Image.asset(
      'assets/unknown.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
