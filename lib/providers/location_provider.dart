import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/logger.dart';

class LocationProvider extends ChangeNotifier {
  bool _initialized = false;
  bool isLoading = true;

  double? latitude;
  double? longitude;

  LocationProvider() {
    _init();
  }

  LatLng? get position => latitude != null && longitude != null
      ? LatLng(latitude!, longitude!)
      : null;

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    logger.i("Caricamento posizione...");
    await _requestLocationPermission();
    await _getCurrentPosition();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
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

      logger.i("Coordinate ottenute: $latitude, $longitude");
      notifyListeners();
    } catch (e) {
      logger.i("Errore ottenendo posizione: $e");
    }
    isLoading = false;
  }

  Future<void> refreshPosition() async {
    await _getCurrentPosition();
  }
}
