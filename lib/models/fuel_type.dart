import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

enum FuelType {
  petrol,
  diesel,
  methane,
  lpg,
}

extension FuelTypeInfo on FuelType {
  int get ministerCode {
    switch (this) {
      case FuelType.petrol:   return 1;
      case FuelType.diesel:   return 2;
      case FuelType.methane:  return 3;
      case FuelType.lpg:      return 4;
    }
  }

  String label(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    switch (this) {
      case FuelType.petrol:
        return l.fuel_petrol;
      case FuelType.diesel:
        return l.fuel_diesel;
      case FuelType.methane:
        return l.fuel_methane;
      case FuelType.lpg:
        return l.fuel_lpg;
    }
  }
}
