import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/google_places_service.dart';
import '../utils/logger.dart';

enum LocationResult {
  success,
  denied,
  permanentlyDenied,
  serviceDisabled,
  error
}

class LocationProvider extends ChangeNotifier {
  bool isLoading = false;
  double? latitude;
  double? longitude;

  // getter
  LatLng? get position => latitude != null && longitude != null
      ? LatLng(latitude!, longitude!)
      : null;

  // search & Favorites vars
  bool isManual = false;
  final TextEditingController searchController = TextEditingController();
  List<PlaceSuggestion> searchSuggestions = [];
  List<PlaceSuggestion> savedPlaces = [];
  Timer? _debounce;
  String? _sessionToken;
  final GooglePlacesService _placesService = GooglePlacesService();

  LocationProvider() {
    _loadSavedPlaces();
  }

  // ---------------------------------------------------------------------------
  // LOCATION LOGIC 
  // ---------------------------------------------------------------------------
  Future<bool> tryInitializeLocation() async {
    isLoading = false;
    notifyListeners();
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.w("Servizi di localizzazione disabilitati all'avvio.");
        isLoading = false;
        notifyListeners();
        return false;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      await _fetchCurrentPosition();
      return true;
    } catch (e) {
      logger.e("Errore init posizione: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<LocationResult> requestPermissionAndFetch() async {
    isLoading = true;
    notifyListeners();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoading = false;
        notifyListeners();
        return LocationResult.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoading = false;
          notifyListeners();
          return LocationResult.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoading = false;
        notifyListeners();
        return LocationResult.permanentlyDenied;
      }

      await _fetchCurrentPosition();
      if (latitude == null) return LocationResult.error;

      return LocationResult.success;
    } catch (e) {
      logger.e("Errore requestPermissionAndFetch: $e");
      isLoading = false;
      notifyListeners();
      return LocationResult.error;
    }
  }

  Future<void> _fetchCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      latitude = pos.latitude;
      longitude = pos.longitude;
      isManual = false; // reset manual flag
      logger.i("Posizione GPS ottenuta: $latitude, $longitude");
    } catch (e) {
      logger.e("Errore Geolocator: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // MANUAL SEARCH & FAVORITES
  // ---------------------------------------------------------------------------
  void startSearchSession() {
    searchController.clear();
    searchSuggestions.clear();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    notifyListeners();
  }

  void onSearchTextChanged(String value, String languageCode) {
    if (value.isEmpty) {
      searchSuggestions.clear();
      notifyListeners();
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _placesService.fetchAutocomplete(
          value,
          languageCode,
          _sessionToken ?? "manual_session",
        );
        searchSuggestions = results;
        notifyListeners();
      } catch (e) {
        logger.e("Errore autocomplete: $e");
      }
    });
  }

  Future<void> selectPlace(PlaceSuggestion place) async {
    isLoading = true;
    notifyListeners();
    try {
      final coords = await _placesService.fetchPlaceDetails(place.placeId);
      if (coords != null) {
        setManualPosition(coords.lat, coords.lng);
        searchController.text = place.description;
        searchSuggestions.clear();
      }
    } catch (e) {
      logger.e("Errore place details: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setManualPosition(double lat, double lng) {
    latitude = lat;
    longitude = lng;
    isManual = true;
    notifyListeners();
  }

  // --- favorites Logic
  Future<void> _loadSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('saved_places_user');
    if (stored != null) {
      savedPlaces = stored
          .map((s) => PlaceSuggestion.fromJson(jsonDecode(s)))
          .toList();
      notifyListeners();
    }
  }

  Future<void> toggleSavedPlace(PlaceSuggestion place) async {
    final index = savedPlaces.indexWhere((p) => p.placeId == place.placeId);
    if (index >= 0) {
      savedPlaces.removeAt(index);
    } else {
      savedPlaces.add(place);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final data = savedPlaces.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('saved_places_user', data);
  }

  bool isPlaceSaved(String placeId) {
    return savedPlaces.any((p) => p.placeId == placeId);
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
