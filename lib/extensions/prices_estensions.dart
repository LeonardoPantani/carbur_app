import '../models/fuel_price.dart';
import '../models/fuel_type.dart';
import '../models/station.dart';

extension StationVisiblePrices on Station {
  List<MapEntry<FuelType, FuelPrice>> visiblePrices(List<FuelType> selected) {
    if (selected.isEmpty) return prices.entries.toList();
    return prices.entries
        .where((e) => selected.contains(e.key))
        .toList();
  }
}
