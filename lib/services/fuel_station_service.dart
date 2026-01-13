import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../exceptions/custom_exceptions.dart';
import '../models/station.dart';
import '../models/fuel_type.dart';
import '../models/fuel_price.dart';
import '../models/station_details.dart';
import '../utils/logger.dart';

class FuelStationService {
  // obtain fuel stations near me. API restricts to a max 10 km radius
  Future<List<Station>> fetchStations({
    required double lat,
    required double lng,
    required int radiusKm,
  }) async {
    final body = {
      "points": [
        {"lat": lat, "lng": lng},
      ],
      "radius": radiusKm,
    };

    try {
      final response = await Future.any([
        http.post(
          Uri.parse("https://carburanti.mise.gov.it/ospzApi/search/zone"),
          headers: {
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0",
          },
          body: jsonEncode(body),
        ),
        Future.delayed(const Duration(seconds: 10), () {
          throw TimeoutException("Hard timeout");
        }),
      ]);

      if (response.statusCode != 200) {
        logger.i("Risposta API non valida (statusCode != 200)");
        throw ApiException();
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json["success"] != true) {
        logger.i("Risposta API non valida (json[success] != true)");
        throw ApiException();
      }

      final List results = json["results"];
      return results.map((e) => _stationFromJson(e)).toList();
    } on TimeoutException {
      logger.i("Il sito del ministero è andato in timeout.");
      throw ApiTimeoutException();
    } on SocketException {
      logger.i("Impossibile contattare il sito web.");
      throw NetworkException();
    }
  }

  // obtain details of a station
  Future<StationDetails> fetchDetails(Station station) async {
    final uri = Uri.parse(
      'https://carburanti.mise.gov.it/ospzApi/registry/servicearea/${station.id}',
    );

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'Mozilla/5.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) throw ApiException();

      final Map<String, dynamic> json = jsonDecode(response.body);
      return StationDetails.fromJson(station: station, json: json);
    } on TimeoutException {
      logger.i("Il sito del ministero è andato in timeout.");
      throw ApiTimeoutException();
    } on SocketException {
      logger.i("Impossibile contattare il sito web.");
      throw NetworkException();
    }
  }

  // fetch stations along route
  Future<List<Station>> fetchStationsOnRoute({
    required List<Map<String, double>> points,
  }) async {
    final uri = Uri.parse(
      "https://carburanti.mise.gov.it/ospzApi/search/route",
    );

    // optimization for minister website
    List<Map<String, double>> optimizedPoints = points;
    if (points.length > 100) {
      int skip = (points.length / 100).ceil();
      optimizedPoints = [];
      for (int i = 0; i < points.length; i += skip) {
        optimizedPoints.add(points[i]);
      }
      if (optimizedPoints.last != points.last) {
        optimizedPoints.add(points.last);
      }
    }

    final body = {
      "priceOrder": "asc",
      "service": null,
      "points": optimizedPoints,
    };

    try {
      final response = await Future.any([
        http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0",
          },
          body: jsonEncode(body),
        ),
        Future.delayed(const Duration(seconds: 15), () {
          throw TimeoutException("Hard timeout ministero");
        }),
      ]);

      if (response.statusCode != 200) {
        logger.e("Errore API Ministero Route: ${response.statusCode}");
        throw ApiException();
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json["success"] != true) {
        throw ApiException();
      }

      final List results = json["results"];
      return results.map((e) => _stationFromJson(e)).toList();
    } on TimeoutException {
      logger.i("Timeout durante la ricerca sul percorso.");
      throw ApiTimeoutException();
    } on SocketException {
      logger.i("Errore di rete durante la ricerca sul percorso.");
      throw NetworkException();
    } catch (e) {
      logger.e("Errore generico fetchStationsOnRoute: $e");
      throw ApiException();
    }
  }

  Future<List<Station>> fetchStationsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids.map((id) => fetchStationById(id));
    final results = await Future.wait(futures);
    return results.whereType<Station>().toList();
  }

  Future<Station?> fetchStationById(int id) async {
    try {
      final uri = Uri.parse(
        'https://carburanti.mise.gov.it/ospzApi/registry/servicearea/$id',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body);

      return _stationFromDetailsJson(json);
    } catch (_) {
      return null;
    }
  }

  // helper methods
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
      brand: json["brand"],
      lastUpdate: DateTime.parse(json["insertDate"]),
      latitude: json["location"]["lat"],
      longitude: json["location"]["lng"],
      distanceKm: double.tryParse(json["distance"].toString()) ?? 0.0,
      prices: fuels,
    );
  }

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
      default:
        return null;
    }
  }

  Station _stationFromDetailsJson(Map<String, dynamic> json) {
    final fuels = <FuelType, FuelPrice>{};
    DateTime? lastUpdate;

    if (json["fuels"] != null) {
      for (final fuelJson in json["fuels"]) {
        final type = _fuelTypeFromMinisterId(fuelJson["fuelId"]);
        if (type != null) {
          final price = FuelPrice(
            type: type,
            pricePerLiter: (fuelJson["price"] as num).toDouble(),
            isSelf: fuelJson["isSelf"] ?? true,
          );
          fuels[type] = price;

          if (fuelJson["insertDate"] != null) {
            final dt = DateTime.tryParse(fuelJson["insertDate"]);
            if (dt != null) {
              if (lastUpdate == null || dt.isAfter(lastUpdate)) {
                lastUpdate = dt;
              }
            }
          }
        }
      }
    }

    return Station(
      id: json["id"],
      name: json["name"] ?? json["nomeImpianto"] ?? "Stazione",
      brand: json["brand"] ?? "Sconosciuto",
      lastUpdate: lastUpdate ?? DateTime.now(),
      latitude: 0.0,
      longitude: 0.0,
      distanceKm: 0.0,
      prices: fuels,
    );
  }
}
