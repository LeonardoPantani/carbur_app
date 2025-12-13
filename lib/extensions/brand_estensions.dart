import '../models/station.dart';

extension BrandIcon on Brand {
  String get asset {
    switch (this) {
      case Brand.ala:
        return "assets/brands/ala.png";
      case Brand.apiIp:
        return "assets/brands/api_ip.png";
      case Brand.beyfin:
        return "assets/brands/beyfin.png";
      case Brand.economy:
        return "assets/brands/economy.png";
      case Brand.eni:
        return "assets/brands/eni.png";
      case Brand.esso:
        return "assets/brands/esso.png";
      case Brand.europam:
        return "assets/brands/europam.png";
      case Brand.q8:
        return "assets/brands/q8.png";
      case Brand.shell:
        return "assets/brands/shell.png";
      case Brand.tamoil:
        return "assets/brands/tamoil.png";
      case Brand.pompeBianche:
      case Brand.unknown:
        return "assets/brands/unknown.png";
    }
  }
}
