import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env/api_key_getter.dart';
import '../utils/logger.dart';

class PlaceSuggestion {
  final String description;
  final String placeId;

  PlaceSuggestion(this.description, this.placeId);
}

class RoutePlannerProvider extends ChangeNotifier {
  static final String _apiKey = ApiKeyGetter.autoCompleteMaps;

  final TextEditingController startController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  String _previousStartText = "";
  String _previousDestinationText = "";

  bool useCurrentLocationAsStart = true;
  bool useCurrentLocationAsDestination = false;

  List<PlaceSuggestion> startSuggestions = [];
  List<PlaceSuggestion> destinationSuggestions = [];

  Timer? _startDebounce;
  Timer? _destinationDebounce;

  String? startPlaceId;
  String? destinationPlaceId;

  String? _sessionToken;

  bool get canSearch =>
      !(useCurrentLocationAsStart && useCurrentLocationAsDestination);

  RoutePlannerProvider() {
    if (useCurrentLocationAsStart) {
      startController.text = 'Using current location';
    }
    if (useCurrentLocationAsDestination) {
      destinationController.text = '';
    }
  }

  /* ---------------- SESSION TOKEN ---------------- */
  String _generateSessionToken() {
    logger.i("Generando nuovo session token per l'autocompletamento.");
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    final hex = values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  void startNewSession() {
    _sessionToken ??= _generateSessionToken();
  }

  /* ---------------- START ---------------- */

  void toggleStartCurrentLocation() {
    useCurrentLocationAsStart = !useCurrentLocationAsStart;

    if (useCurrentLocationAsStart) {
      _previousStartText = startController.text;
      startController.text = 'Using current location';
      startSuggestions.clear();
    } else {
      startController.text = _previousStartText;
    }

    notifyListeners();
  }

  void onStartTextChanged(
    String value,
    String languageCode, {
    double? lat,
    double? lng,
  }) {
    if (useCurrentLocationAsStart || value.isEmpty) {
      startSuggestions.clear();
      notifyListeners();
      return;
    }
    _startDebounce?.cancel();
    _startDebounce = Timer(const Duration(milliseconds: 400), () {
      _fetchAutocomplete(value, languageCode, lat: lat, lng: lng).then((
        results,
      ) {
        startSuggestions = results;
        notifyListeners();
      });
    });
  }

  Future<void> selectStartPlace(PlaceSuggestion suggestion) async {
    startController.text = suggestion.description;
    startPlaceId = suggestion.placeId;
    startSuggestions.clear();
    _sessionToken = null;
    notifyListeners();
  }

  /* ---------------- DESTINATION ---------------- */

  void toggleDestinationCurrentLocation() {
    useCurrentLocationAsDestination = !useCurrentLocationAsDestination;

    if (useCurrentLocationAsDestination) {
      _previousDestinationText = destinationController.text;
      destinationController.text = 'Using current location';
      destinationSuggestions.clear();
    } else {
      destinationController.text = _previousDestinationText;
    }

    notifyListeners();
  }

  void onDestinationTextChanged(
    String value,
    String languageCode, {
    double? lat,
    double? lng,
  }) {
    if (useCurrentLocationAsDestination || value.isEmpty) {
      destinationSuggestions.clear();
      notifyListeners();
      return;
    }
    _destinationDebounce?.cancel();
    _destinationDebounce = Timer(const Duration(milliseconds: 400), () {
      _fetchAutocomplete(value, languageCode, lat: lat, lng: lng).then((
        results,
      ) {
        destinationSuggestions = results;
        notifyListeners();
      });
    });
  }

  Future<void> selectDestinationPlace(PlaceSuggestion suggestion) async {
    destinationController.text = suggestion.description;
    destinationSuggestions.clear();
    destinationPlaceId = suggestion.placeId;
    _sessionToken = null;
    notifyListeners();
  }

  /* ---------------- GOOGLE PLACES ---------------- */

  Future<List<PlaceSuggestion>> _fetchAutocomplete(
    String input,
    String languageCode, {
    double? lat,
    double? lng,
  }) async {
    _sessionToken ??= _generateSessionToken();

    final Map<String, String> parameters = {
      'input': input,
      'key': _apiKey,
      'language': languageCode,
      'types': 'address',
      'sessiontoken': _sessionToken!,
    };

    if (lat != null && lng != null) {
      parameters['location'] = "$lat,$lng";
      parameters['radius'] = "10000";
    }

    logger.i(
      "Facendo chiamata API per autocompletamento. Testo: $input, Token: $_sessionToken",
    );

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
            .map((p) => PlaceSuggestion(p['description'], p['place_id']))
            .toList();
      }
      return [];
    } catch (e) {
      logger.e("Errore ricerca: $e");
      return [];
    }
  }

  /* ---------------- ACTION ---------------- */

  void searchFuelStations() {
    // TODO
  }

  @override
  void dispose() {
    startController.dispose();
    destinationController.dispose();
    _startDebounce?.cancel();
    _destinationDebounce?.cancel();
    super.dispose();
  }
}
