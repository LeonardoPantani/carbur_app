import 'package:flutter/material.dart';

class PriceMarker extends StatelessWidget {
  final String price;
  final Color background;
  final Color textColor;
  final Widget? logo;

  const PriceMarker({
    super.key,
    required this.price,
    required this.background,
    required this.textColor,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            if (logo != null) ...[
              SizedBox(width: 14, height: 14, child: logo),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  price,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
