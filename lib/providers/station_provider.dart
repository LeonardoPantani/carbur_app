import 'package:flutter/material.dart';
import '../models/fuel_type.dart';
import '../models/station.dart';
import '../models/station_sort.dart';
import '../services/station_service.dart';
import 'position_provider.dart';
import 'settings_provider.dart';

class StationProvider extends ChangeNotifier {
  final StationService _service = StationService();

  PositionProvider? _pos;
  FuelSettingsProvider? _settings;

  StationSort _sort = StationSort.price;
  StationSort get currentSort => _sort;

  bool isLoading = true;
  String? error;

  List<Station> _allStations = [];
  List<Station> stations = [];

  List<FuelType> _lastFuels = [];
  int? _lastRadiusKm;

  Future<void> loadStations() async {
    if (_pos == null || _settings == null) return;

    final lat = _pos!.latitude!;
    final lng = _pos!.longitude!;
    final radiusKm = _settings!.radiusKm;

    isLoading = true;
    notifyListeners();

    try {
      print("contattando il sito del ministero, lat = $lat, lng = $lng, radiusKm = $radiusKm");
      _allStations = await _service.fetchStations(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );

      stations = _allStations;
      _lastRadiusKm = radiusKm;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;

    _applyFuelFilter(_settings!.selectedFuels);
  }

  void _applyFuelFilter(List<FuelType> fuels) {
    if (fuels.isEmpty) {
      stations = List.from(_allStations);
    } else {
      stations = _allStations.where((s) {
        return s.prices.keys.any((k) => fuels.contains(k));
      }).toList();
    }

    _applySorting(fuels);
    _lastFuels = List.from(fuels);

    notifyListeners();
  }

  Future<void> forceReload() async {
    print("forzando ricarica");
    _lastRadiusKm = null;
    return loadStations();
  }

  void updateDependencies(PositionProvider pos, FuelSettingsProvider settings) {
    _pos = pos;
    _settings = settings;

    _sort = settings.sort;

    _handleAutoUpdates();
  }

  void setSorting(StationSort sort) {
    print("cambiando ordinamento a ${sort.toString()}");
    _sort = sort;
    _applySorting(_settings!.selectedFuels);
    notifyListeners();
  }

  void _applySorting(List<FuelType> fuels) {
    stations.sort((a, b) {
      switch (_sort) {
        case StationSort.price:
          final pa = _lowestPrice(a, fuels);
          final pb = _lowestPrice(b, fuels);
          return pa.compareTo(pb);

        case StationSort.distance:
          return a.distanceKm.compareTo(b.distanceKm);

        case StationSort.updatedAt:
          return b.lastUpdate.compareTo(a.lastUpdate);
      }
    });
  }

  void _handleAutoUpdates() {
    print("handleAutoUpdates chiamata");
    if (_pos == null || _settings == null) return;

    if (_pos!.isLoading || _pos!.latitude == null) {
      return;
    }

    if (_lastRadiusKm == null) {
      print(
        "il raggio di ricerca ultimo era nullo (primo caricamento o refresh forzato)",
      );
      loadStations();
      return;
    }

    if (_settings!.radiusKm != _lastRadiusKm) {
      print("il raggio nuovo è diverso da quello precedente");
      loadStations();
      return;
    }

    if (_settings!.selectedFuels != _lastFuels) {
      print("il filtro dei distributori è cambiato");
      _applyFuelFilter(_settings!.selectedFuels);
      return;
    }
  }

  double _lowestPrice(Station s, List<FuelType> fuels) {
    final matches = s.prices.entries
        .where((e) => fuels.contains(e.key))
        .map((e) => e.value.pricePerLiter);

    if (matches.isEmpty) return double.infinity;
    return matches.reduce((a, b) => a < b ? a : b);
  }
}
