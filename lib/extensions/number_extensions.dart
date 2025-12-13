import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension NumberFormatting on num {
  static final Map<String, NumberFormat> _priceCache = {};
  static final Map<String, NumberFormat> _distanceCache = {};

  String formatPrice(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = _priceCache.putIfAbsent(
      locale,
      () => NumberFormat("#,##0.000", locale),
    );

    return formatter.format(this);
  }

  String formatDistance(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = _distanceCache.putIfAbsent(
      locale,
      () => NumberFormat("#,#0.0", locale),
    );

    return formatter.format(this);
  }
}
