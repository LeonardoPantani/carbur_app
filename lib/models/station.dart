import 'fuel_type.dart';
import 'fuel_price.dart';

enum Brand {
  eni,
  q8,
  esso,
  shell,
  apiIp,
  beyfin,
  economy,
  pompeBianche,
  ala,
  europam,
  tamoil,
  unknown,
}

class Station {
  final int id;
  final String name;
  final Brand brand;
  final DateTime lastUpdate;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final Map<FuelType, FuelPrice> prices;

  Station({
    required this.id,
    required this.name,
    required String brandString,
    required this.lastUpdate,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.prices,
  }) : brand = _parseBrand(brandString);
}

Brand _parseBrand(String raw) {
  final b = raw.toLowerCase();

  if (b.contains("eni") || b.contains("agip")) return Brand.eni;
  if (b.contains("q8")) return Brand.q8;
  if (b.contains("esso")) return Brand.esso;
  if (b.contains("shell")) return Brand.shell;
  if (b.contains("api") || b.contains("ip")) return Brand.apiIp;
  if (b.contains("beyfin")) return Brand.beyfin;
  if (b.contains("economy")) return Brand.economy;
  if (b.contains("pompebianche")) return Brand.pompeBianche;
  if (b.contains("ala")) return Brand.ala;
  if (b.contains("tamoil")) return Brand.tamoil;
  if (b.contains("europam")) return Brand.europam;

  return Brand.unknown;
}
