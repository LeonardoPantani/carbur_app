import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/api_key_getter.dart';
import '../utils/logger.dart';

class PlaceSuggestion {
  final String description;
  final String placeId;
  final List<String> types;

  PlaceSuggestion(this.description, this.placeId, this.types);

  // for storing favorites 
  Map<String, dynamic> toJson() => {
    'description': description,
    'placeId': placeId,
    'types': types,
  };

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      json['description'],
      json['placeId'],
      List<String>.from(json['types'] ?? []),
    );
  }
}

class GooglePlacesService {
  final String _apiKey = ApiKeyGetter.autoCompleteMaps;

  Future<List<PlaceSuggestion>> fetchAutocomplete(
    String input,
    String languageCode,
    String sessionToken, {
    double? lat,
    double? lng,
  }) async {
    final Map<String, String> parameters = {
      'input': input,
      'key': _apiKey,
      'language': languageCode,
      'sessiontoken': sessionToken,
    };

    if (lat != null && lng != null) {
      parameters['locationbias'] = "circle:50000@$lat,$lng";
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      parameters,
    );

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        return (data['predictions'] as List)
            .map((p) => PlaceSuggestion(
                  p['description'],
                  p['place_id'],
                  List<String>.from(p['types'] ?? const []),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      logger.e("Errore Places Autocomplete: $e");
      return [];
    }
  }

  Future<({double lat, double lng})?> fetchPlaceDetails(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {'place_id': placeId, 'fields': 'geometry', 'key': _apiKey},
    );

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        return (
          lat: (location['lat'] as num).toDouble(),
          lng: (location['lng'] as num).toDouble()
        );
      }
    } catch (e) {
      logger.e("Errore Places Details: $e");
    }
    return null;
  }
}