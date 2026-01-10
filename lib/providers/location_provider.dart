import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/logger.dart';

class LocationProvider extends ChangeNotifier {
  bool isLoading = false;

  double? latitude;
  double? longitude;

  LatLng? get position => latitude != null && longitude != null
      ? LatLng(latitude!, longitude!)
      : null;

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
}
