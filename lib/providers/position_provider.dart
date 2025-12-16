import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  bool _initialized = false;
  bool isLoading = true;

  double? latitude;
  double? longitude;

  LocationProvider() {
    _init();
  }

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    print("Caricamento posizione...");
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

      debugPrint("Coordinate ottenute: $latitude, $longitude");
      notifyListeners();
    } catch (e) {
      debugPrint("Errore ottenendo posizione: $e");
    }
    isLoading = false;
  }

  Future<void> refreshPosition() async {
    await _getCurrentPosition();
  }
}
