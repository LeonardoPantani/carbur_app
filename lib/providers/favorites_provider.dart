import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';
import '../services/station_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final StationService _service = StationService();
  
  // Cache locale: ID -> {lat, lng} (Serve SOLO per il tasto navigazione)
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

  // Carica
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

  // Aggiungi/Rimuovi
  Future<void> toggleFavorite(Station station) async {
    if (_savedCoords.containsKey(station.id)) {
      _savedCoords.remove(station.id);
      _favoriteStations.removeWhere((s) => s.id == station.id);
    } else {
      // Salviamo le coordinate attuali per il futuro
      _savedCoords[station.id] = (lat: station.latitude, lng: station.longitude);
      _favoriteStations.add(station); 
    }
    notifyListeners();
    
    // Persistenza semplice
    final prefs = await SharedPreferences.getInstance();
    final data = _savedCoords.entries.map((e) => jsonEncode({
      'id': e.key, 'lat': e.value.lat, 'lng': e.value.lng
    })).toList();
    await prefs.setStringList('fav_stations_simple', data);
  }

  // Refresh dei prezzi
  Future<void> refreshData() async {
    if (_savedCoords.isEmpty) return;
    
    final freshData = await _service.fetchStationsByIds(_savedCoords.keys.toList());
    
    _favoriteStations = freshData.map((s) {
      // Reimpostiamo le coordinate salvate per permettere la navigazione
      final coords = _savedCoords[s.id];
      if (coords != null) {
        return s.copyWithCoordinates(lat: coords.lat, lng: coords.lng);
      }
      return s;
    }).toList();
    
    notifyListeners();
  }
  
  void toggleFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    if (_showFavoritesOnly) refreshData();
    notifyListeners();
  }

  bool isFavorite(int id) => _savedCoords.containsKey(id);
}