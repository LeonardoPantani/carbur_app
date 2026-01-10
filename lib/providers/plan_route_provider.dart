import 'dart:async';

import 'package:carbur_app/models/fuel_type.dart' show FuelType;
import 'package:carbur_app/services/fuel_station_service.dart';
import 'package:carbur_app/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/station.dart';
import '../services/google_places_service.dart';
import '../utils/logger.dart';
import '../utils/map_utils.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

class PlanRouteProvider extends ChangeNotifier {
  final GooglePlacesService _placesService = GooglePlacesService();

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

  List<Station> _allStations = [];

  List<Station> stationsOnRoute = [];

  PlanRouteProvider() {
    if (useCurrentLocationAsStart) {
      startController.text = '';
    }
    if (useCurrentLocationAsDestination) {
      destinationController.text = '';
    }
  }

  void startNewSession() {
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
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
      _placesService.fetchAutocomplete(value, languageCode, _sessionToken!, lat: lat, lng: lng).then((
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
      _placesService.fetchAutocomplete(value, languageCode, _sessionToken!, lat: lat, lng: lng).then((
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

  /* ---------------- ACTION ---------------- */

  Future<void> searchFuelStations(
    BuildContext context,
    String languageCode,
  ) async {
    final location = context.read<LocationProvider>();
    final settings = context.read<SettingsProvider>();

    final FuelStationService fuelStationService = FuelStationService();
    final RoutingService routingService = RoutingService();

    final double? lat = location.latitude;
    final double? lng = location.longitude;

    try {
      final result = await routingService.computeRoute(
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

      final encodedPolyline =
          routes[0]['polyline']['encodedPolyline'] as String;
      final pointsJson = decodePolylineToPoints(encodedPolyline);

      final List<Map<String, double>> ministerPoints = pointsJson
          .map((p) => {"lat": p['lat']!, "lng": p['lng']!})
          .toList();
      routePolylinePoints = ministerPoints
          .map((p) => LatLng(p['lat']!, p['lng']!))
          .toList();

      // calling minister website
      final List<Station> fetchedStations = await fuelStationService
          .fetchStationsOnRoute(points: ministerPoints);

      _allStations = fetchedStations;
      updateFuelFilter(settings.selectedFuels);

      hasSearched = true;
      notifyListeners();
    } catch (e) {
      logger.e("Errore durante il recupero dei distributori sul percorso: $e");
      rethrow;
    }
  }

  void updateFuelFilter(List<FuelType> selectedFuels) {
    if (_allStations.isEmpty) {
      stationsOnRoute = [];
      notifyListeners();
      return;
    }

    stationsOnRoute = _allStations.where((station) {
      return station.prices.keys.any((k) => selectedFuels.contains(k));
    }).toList();

    notifyListeners();
  }

  void clear() {
    startController.text = '';
    destinationController.clear();
    startPlaceId = null;
    destinationPlaceId = null;
    routePolylinePoints = [];
    _allStations = [];
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

  @override
  void dispose() {
    startController.dispose();
    destinationController.dispose();
    _startDebounce?.cancel();
    _destinationDebounce?.cancel();
    super.dispose();
  }
}
