import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:carbur_app/models/fuel_type.dart' show FuelType;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../env/api_key_getter.dart';
import '../models/station.dart';
import '../services/station_service.dart';
import '../utils/logger.dart';
import '../utils/map_utils.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

class PlaceSuggestion {
  final String description;
  final String placeId;
  final List<String> types;

  PlaceSuggestion(this.description, this.placeId, this.types);
}

class PlanRouteProvider extends ChangeNotifier {
  static final String _apiKeyAutocomplete = ApiKeyGetter.autoCompleteMaps;

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

  bool avoidTolls = false;

  void setAvoidTolls(bool value) {
    if (avoidTolls == value) return;
    avoidTolls = value;
    hasSearched = false;
    notifyListeners();
  }

  List<LatLng> routePolylinePoints = [];

  bool hasSearched = false;

  bool get canSearch {
    if (hasSearched) return false;

    final bothCurrent =
        useCurrentLocationAsStart && useCurrentLocationAsDestination;

    final startInvalid = !useCurrentLocationAsStart && startPlaceId == null;

    final destinationInvalid =
        !useCurrentLocationAsDestination && destinationPlaceId == null;

    final samePlace =
        !useCurrentLocationAsStart &&
        !useCurrentLocationAsDestination &&
        startPlaceId != null &&
        startPlaceId == destinationPlaceId;

    return !(bothCurrent || startInvalid || destinationInvalid || samePlace);
  }

  List<Station> stationsOnRoute = [];

  PlanRouteProvider() {
    if (useCurrentLocationAsStart) {
      startController.text = '';
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
      startController.text = '';
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
    hasSearched = false;
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
      destinationController.text = '';
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
    hasSearched = false;
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
    String? excludePlaceId,
  }) async {
    _sessionToken ??= _generateSessionToken();

    final Map<String, String> parameters = {
      'input': input,
      'key': _apiKeyAutocomplete,
      'language': languageCode,
      'sessiontoken': _sessionToken!,
    };

    if (lat != null && lng != null) {
      parameters['locationbias'] = "circle:50000@$lat,$lng";
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
            .map(
              (p) => PlaceSuggestion(
                p['description'],
                p['place_id'],
                List<String>.from(p['types'] ?? const []),
              ),
            )
            .where((p) => p.placeId != excludePlaceId)
            .toList();
      }
      return [];
    } catch (e) {
      logger.e("Errore ricerca: $e");
      return [];
    }
  }

  /* ---------------- ACTION ---------------- */

  Future<void> searchFuelStations(
    BuildContext context,
    String languageCode,
  ) async {
    final location = context.read<LocationProvider>();
    final settings = context.read<SettingsProvider>();

    final double? lat = location.latitude;
    final double? lng = location.longitude;

    final result = await StationService().computeRoute(
      avoidTolls: avoidTolls,
      languageCode: languageCode,
      useCurrentLocationAsStart: useCurrentLocationAsStart,
      useCurrentLocationAsDestination: useCurrentLocationAsDestination,
      startPlaceId: startPlaceId,
      destinationPlaceId: destinationPlaceId,
      lat: lat,
      lng: lng,
    );

    final routes = result?['routes'];
    if (routes == null || routes.isEmpty) return;

    final encodedPolyline = routes[0]['polyline']['encodedPolyline'] as String;
    final pointsJson = decodePolylineToPoints(encodedPolyline);

    final List<Map<String, double>> ministerPoints = pointsJson
        .map((p) => {"lat": p['lat']!, "lng": p['lng']!})
        .toList();
    routePolylinePoints = ministerPoints
        .map((p) => LatLng(p['lat']!, p['lng']!))
        .toList();

    String fuelType = "1-x";
    if (settings.selectedFuels.isNotEmpty) {
      final first = settings.selectedFuels.first;
      fuelType = "${first.index + 1}-x";
    }

    try {
      // calling minister website
      final List<Station> fetchedStations = await StationService()
          .fetchStationsOnRoute(points: ministerPoints, fuelType: fuelType);

      stationsOnRoute = fetchedStations;
      hasSearched = true;
      notifyListeners();
    } catch (e) {
      logger.e("Errore durante il recupero dei distributori sul percorso: $e");
    }
  }

  void clear() {
    startController.text = '';
    destinationController.clear();
    routePolylinePoints = [];
    stationsOnRoute = [];
    useCurrentLocationAsStart = true;
    useCurrentLocationAsDestination = false;
    notifyListeners();
  }

  void swapStartAndDestination() {
    final tmpUseCurrentStart = useCurrentLocationAsStart;
    final tmpUseCurrentDestination = useCurrentLocationAsDestination;

    final tmpStartText = startController.text;
    final tmpDestinationText = destinationController.text;

    final tmpStartPlaceId = startPlaceId;
    final tmpDestinationPlaceId = destinationPlaceId;

    useCurrentLocationAsStart = tmpUseCurrentDestination;
    useCurrentLocationAsDestination = tmpUseCurrentStart;

    startController.text = tmpDestinationText;
    destinationController.text = tmpStartText;

    startPlaceId = tmpDestinationPlaceId;
    destinationPlaceId = tmpStartPlaceId;

    startSuggestions.clear();
    destinationSuggestions.clear();

    hasSearched = false;

    notifyListeners();
  }

  List<Station> getStationsFilteredBy(List<FuelType> selectedFuels) {
    if (stationsOnRoute.isEmpty) return [];

    return stationsOnRoute.where((station) {
      return station.prices.keys.any((k) => selectedFuels.contains(k));
    }).toList();
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
