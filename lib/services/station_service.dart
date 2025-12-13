import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/station.dart';
import '../models/fuel_type.dart';
import '../models/fuel_price.dart';

class StationService {
  static const String _url = "https://carburanti.mise.gov.it/ospzApi/search/zone";

  Future<List<Station>> fetchStations({
    required double lat,
    required double lng,
    required int radiusKm,
    bool asc = true,
  }) async {
    final body = {
      "points": [
        {"lat": lat, "lng": lng}
      ],
      "radius": radiusKm,
    };

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Errore API ministero: ${response.statusCode}");
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (json["success"] != true) {
      throw Exception("Risposta API non valida");
    }

    final List results = json["results"];

    return results.map((e) => _stationFromJson(e)).toList();
  }

  // ------------------------------------------------------------
  // convertion from json to station model
  // ------------------------------------------------------------
  Station _stationFromJson(Map<String, dynamic> json) {
    final fuels = <FuelType, FuelPrice>{};

    for (final fuelJson in json["fuels"]) {
      final type = _fuelTypeFromMinisterId(fuelJson["fuelId"]);
      if (type != null) {
        fuels[type] = FuelPrice(
          type: type,
          pricePerLiter: (fuelJson["price"] as num).toDouble(),
          isSelf: fuelJson["isSelf"] ?? true,
        );
      }
    }

    return Station(
      id: json["id"],
      name: json["name"],
      brandString: json["brand"] ?? "",
      lastUpdate: DateTime.parse(json["insertDate"]),
      latitude: json["location"]["lat"],
      longitude: json["location"]["lng"],
      distanceKm: double.tryParse(json["distance"].toString()) ?? 0.0,
      prices: fuels,
    );
  }

  // ------------------------------------------------------------
  // convertion from fuel id to fuel type
  // ------------------------------------------------------------
  FuelType? _fuelTypeFromMinisterId(int id) {
    switch (id) {
      case 1:
        return FuelType.petrol;
      case 2:
        return FuelType.diesel;
      case 3:
        return FuelType.methane;
      case 4:
        return FuelType.lpg;
      case 323:
        return FuelType.lcng;
      case 324:
        return FuelType.lng;
      default:
        return null;
    }
  }
}
