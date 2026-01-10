import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/google_places_service.dart';
import '../utils/logger.dart';

class LocationProvider extends ChangeNotifier {
  bool isLoading = false;

  double? latitude;
  double? longitude;

  LatLng? get position => latitude != null && longitude != null
      ? LatLng(latitude!, longitude!)
      : null;

  // Search & Favorites
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

  // --- manual search logic
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
      searchSuggestions = await _placesService.fetchAutocomplete(
        value,
        languageCode,
        _sessionToken ?? "manual_session",
      );
      notifyListeners();
    });
  }

  Future<void> selectPlace(PlaceSuggestion place) async {
    isLoading = true;
    notifyListeners();

    // obtaining coords
    final coords = await _placesService.fetchPlaceDetails(place.placeId);
    
    if (coords != null) {
      // setting manual location
      setManualPosition(coords.lat, coords.lng);
      searchController.text = place.description;
      searchSuggestions.clear();
    }
    
    isLoading = false;
    notifyListeners();
  }
  
  void setManualPosition(double lat, double lng) {
    latitude = lat;
    longitude = lng;
    isManual = true;
    logger.i("Posizione manuale impostata: $lat, $lng");
    notifyListeners();
  }

  // --- favorites logic
  Future<void> _loadSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('saved_places_user');
    if (stored != null) {
      savedPlaces = stored
          .map((s) => PlaceSuggestion.fromJson(jsonDecode(s)))
          .toList();
    }
    notifyListeners();
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

  // --- location logic
  Future<bool> initializeLocation() async {
    isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        logger.w("Permesso posizione negato dall'utente.");
        isLoading = false;
        notifyListeners();
        return false;
      }

      await _getCurrentPosition();
      return true;
    } catch (e) {
      logger.e("Errore inizializzazione posizione: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _getCurrentPosition() async {
    isLoading = true;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      latitude = pos.latitude;
      longitude = pos.longitude;

      logger.i("Posizione utente ottenuta.");
      notifyListeners();
    } catch (e) {
      logger.i("Errore ottenendo posizione: $e");
    }
    isLoading = false;
  }

  Future<void> refreshPosition() async {
    await _getCurrentPosition();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
