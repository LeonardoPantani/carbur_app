import 'fuel_type.dart';
import 'fuel_price.dart';

enum StationSort {
  best,
  price,
  distance,
  updatedAt,
}

class Station {
  final int id;
  final String name;
  final String brand;
  final DateTime lastUpdate;
  final double latitude;
  final double longitude;
  double distanceKm;
  final Map<FuelType, FuelPrice> prices;

  Station({
    required this.id,
    required this.name,
    required this.brand,
    required this.lastUpdate,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.prices,
  });

  set updateDistanceKm(double value) {
    if (value > 0) {
      distanceKm = value;
    }
  }

  Station copyWithCoordinates({required double lat, required double lng}) {
    return Station(
      id: id,
      name: name,
      brand: brand,
      lastUpdate: lastUpdate,
      latitude: lat,
      longitude: lng,
      distanceKm: distanceKm,
      prices: prices,
    );
  }
}