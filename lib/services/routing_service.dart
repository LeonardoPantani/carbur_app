import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../env/api_key_getter.dart';
import '../exceptions/custom_exceptions.dart';
import '../utils/logger.dart';

class RoutingService {
  // to obtain real driving distance
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

    try {
      final response = await Future.any([
        http.post(uri, headers: headers, body: jsonEncode(body)),
        Future.delayed(const Duration(seconds: 10), () {
          throw TimeoutException("Hard timeout");
        }),
      ]);

      if (response.statusCode != 200) {
        logger.e("Errore Routes API: ${response.body}");
        throw ApiException();
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw NetworkException();
    }
  }
}
