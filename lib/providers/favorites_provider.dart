import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';
import '../services/fuel_station_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FuelStationService _service = FuelStationService();

  final Map<int, ({double lat, double lng})> _savedCoords = {};

  List<Station> _favoriteStations = [];
  bool _showFavoritesOnly = false;
  bool _isLoading = true;

  List<Station> get favoriteStations => _favoriteStations;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('fav_stations_simple');
    if (stored != null) {
      for (var s in stored) {
        final map = jsonDecode(s);
        _savedCoords[map['id']] = (lat: map['lat'], lng: map['lng']);
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(Station station) async {
    if (_savedCoords.containsKey(station.id)) {
      _savedCoords.remove(station.id);
      _favoriteStations.removeWhere((s) => s.id == station.id);
    } else {
      _savedCoords[station.id] = (
        lat: station.latitude,
        lng: station.longitude,
      );
      _favoriteStations.add(station);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final data = _savedCoords.entries
        .map(
          (e) =>
              jsonEncode({'id': e.key, 'lat': e.value.lat, 'lng': e.value.lng}),
        )
        .toList();
    await prefs.setStringList('fav_stations_simple', data);
  }

  Future<void> refreshData() async {
    if (_savedCoords.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final freshData = await _service.fetchStationsByIds(
        _savedCoords.keys.toList(),
      );

      _favoriteStations = freshData.map((s) {
        final coords = _savedCoords[s.id];
        if (coords != null) {
          return s.copyWithCoordinates(lat: coords.lat, lng: coords.lng);
        }
        return s;
      }).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    if (_showFavoritesOnly) refreshData();
    notifyListeners();
  }

  bool isFavorite(int id) => _savedCoords.containsKey(id);
}
