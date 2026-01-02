import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../env/api_key_getter.dart';
import '../exceptions/custom_exceptions.dart';
import '../models/station.dart';
import '../models/fuel_type.dart';
import '../models/fuel_price.dart';
import '../models/station_details.dart';
import '../utils/logger.dart';

class StationService {
  // obtain fuel stations near me. API restricts to a max 10 km radius
  Future<List<Station>> fetchStations({
    required double lat,
    required double lng,
    required int radiusKm,
    bool asc = true,
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

  // obtain real driving distance
  Future<double> fetchDrivingDistanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final url =
        "https://router.project-osrm.org/route/v1/driving/"
        "$fromLng,$fromLat;$toLng,$toLat"
        "?overview=false&generate_hints=false";

    try {
      final response = await Future.any([
        http.get(Uri.parse(url)),
        Future.delayed(const Duration(seconds: 30), () {
          throw TimeoutException("Hard timeout");
        }),
      ]);
      if (response.statusCode != 200) {
        throw ApiException();
      }

      final json = jsonDecode(response.body);

      if (json["routes"] == null || json["routes"].isEmpty) {
        throw NoRouteException();
      }

      final distanceMeters = json["routes"][0]["distance"] as num;
      return distanceMeters.toDouble() / 1000.0;
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
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
            headers: const {
              'User-Agent': 'Mozilla/5.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException();
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return StationDetails.fromJson(station: station, json: json);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw NetworkException();
    }
  }

  // calculating route
  Future<Map<String, dynamic>?> computeRoute({
    double? lat,
    double? lng,
    bool useCurrentLocationAsStart = true,
    bool useCurrentLocationAsDestination = false,
    String? startPlaceId,
    String? destinationPlaceId,
    required bool avoidTolls,
    required String languageCode,
  }) async {
    assert(
      !(useCurrentLocationAsStart && useCurrentLocationAsDestination),
    ); // cannot route to myself
    assert(
      startPlaceId != destinationPlaceId,
    ); // cannot go from one place to same place

    logger.i("Calcolo del percorso in macchina...");

    final uri = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': ApiKeyGetter.routes,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };

    Map<String, dynamic> origin;
    Map<String, dynamic> destination;

    if (useCurrentLocationAsStart) {
      assert(lat != null && lng != null);
      origin = {
        "location": {
          "latLng": {"latitude": lat, "longitude": lng},
        },
      };
    } else {
      origin = {"placeId": startPlaceId};
    }

    if (useCurrentLocationAsDestination) {
      destination = {
        "location": {
          "latLng": {"latitude": lat, "longitude": lng},
        },
      };
    } else {
      destination = {"placeId": destinationPlaceId};
    }

    final body = {
      "origin": origin,
      "destination": destination,
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "routeModifiers": {
        "avoidTolls": avoidTolls,
        "avoidHighways": false,
        "avoidFerries": false,
      },
      "computeAlternativeRoutes": false,
      "languageCode": languageCode,
      "units": "METRIC",
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      logger.e("Errore Routes API: ${response.body}");
      return null;
    }

    return jsonDecode(response.body);
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
}
