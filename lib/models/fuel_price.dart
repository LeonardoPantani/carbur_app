import 'fuel_type.dart';

class FuelPrice {
  final FuelType type;
  final double pricePerLiter;
  final bool isSelf;

  FuelPrice({
    required this.type,
    required this.pricePerLiter,
    required this.isSelf,
  });
}
