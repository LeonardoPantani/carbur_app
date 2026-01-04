import 'package:flutter/material.dart';
import '../exceptions/custom_exceptions.dart';
import '../models/fuel_type.dart';
import '../models/station.dart';
import '../models/station_sort.dart';
import '../services/station_service.dart';
import '../utils/logger.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

enum StationError { ministry, routes, network, unknown }

class StationProvider extends ChangeNotifier {
  final StationService _service = StationService();

  LocationProvider? _pos;
  SettingsProvider? _settings;

  StationSort _sort = StationSort.best;
  StationSort get currentSort => _sort;

  bool isLoading = true;
  StationError? error;

  List<Station> _allStations = [];
  List<Station> stations = [];

  List<FuelType> _lastFuels = [];
  int? _lastRadiusKm;

  Future<void> loadStations() async {
    if (_pos == null || _settings == null) return;

    final lat = _pos!.latitude!;
    final lng = _pos!.longitude!;
    final radiusKm = _settings!.radiusKm;
    const fetchRadiusKm = 10;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final stopwatch = Stopwatch()..start();
      logger.i("Contattando il sito del ministero.");
      _allStations = await _service.fetchStations(
        lat: lat,
        lng: lng,
        radiusKm: fetchRadiusKm,
      );
      stopwatch.stop();
      logger.i(
        "Dati dal ministero ricevuti. Latenza: ${stopwatch.elapsedMilliseconds} ms",
      );

      stations = _allStations;
      _lastRadiusKm = radiusKm;

      // updating driving distances dinamically
      _refineTopDrivingDistances(lat, lng).then((_) {
        _applySorting(_settings!.selectedFuels);
        notifyListeners();
      });
    } catch (e) {
      error = _mapExceptionToError(e);
      _allStations = [];
      stations = [];
      isLoading = false;
      notifyListeners();
      return;
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
    logger.i("Forzando ricarica.");
    return loadStations();
  }

  void updateDependencies(LocationProvider pos, SettingsProvider settings) {
    _pos = pos;
    _settings = settings;
    _sort = settings.sort;

    _handleAutoUpdates();
  }

  void setSorting(StationSort sort) {
    logger.i("cambiando ordinamento a ${sort.toString()}");
    _sort = sort;
    _applySorting(_settings!.selectedFuels);
    notifyListeners();
  }

  List<Station> sortStations(List<Station> input) {
    if (_settings == null) return input;
    final copy = List<Station>.from(input);
    _performSort(copy, _settings!.selectedFuels, _sort);
    return copy;
  }

  void _applySorting(List<FuelType> fuels) {
    _performSort(stations, fuels, _sort);
  }

  void _performSort(List<Station> targetList, List<FuelType> fuels, StationSort sortMode) {
    if (sortMode == StationSort.best) {
      _applyBestSorting(targetList, fuels);
      return;
    }

    targetList.sort((a, b) {
      switch (sortMode) {
        case StationSort.price:
          final pa = _lowestPrice(a, fuels);
          final pb = _lowestPrice(b, fuels);
          return pa.compareTo(pb);

        case StationSort.distance:
          return a.distanceKm.compareTo(b.distanceKm);

        case StationSort.updatedAt:
          return b.lastUpdate.compareTo(a.lastUpdate);

        case StationSort.best:
          return 0;
      }
    });
  }

  List<Station> get listStations {
    final radiusKm = _settings!.radiusKm;
    return _filterByFuel(
      stations,
    ).where((s) => s.distanceKm <= radiusKm).toList();
  }

  List<Station> get mapStations {
    const mapRadiusKm = 10.0;
    return _filterByFuel(
      _allStations,
    ).where((s) => s.distanceKm <= mapRadiusKm).toList();
  }

  List<Station> _filterByFuel(List<Station> input) {
    final fuels = _settings!.selectedFuels;
    if (fuels.isEmpty) return List.from(input);

    return input.where((s) {
      return s.prices.keys.any((k) => fuels.contains(k));
    }).toList();
  }

  /*
      Ordinamento "Best" refactorizzato per accettare una lista target
  */
  void _applyBestSorting(List<Station> targetList, List<FuelType> fuels) {
    if (targetList.isEmpty) return;

    final prices = targetList
        .map((s) => _lowestPrice(s, fuels))
        .where((p) => p.isFinite)
        .toList();

    if (prices.isEmpty) return;

    final distances = targetList.map((s) => s.distanceKm).toList();
    final times = targetList
        .map((s) => s.lastUpdate.millisecondsSinceEpoch)
        .toList();

    if (distances.isEmpty || times.isEmpty) return;

    final pMin = prices.reduce((a, b) => a < b ? a : b);
    final pMax = prices.reduce((a, b) => a > b ? a : b);

    final dMin = distances.reduce((a, b) => a < b ? a : b);
    final dMax = distances.reduce((a, b) => a > b ? a : b);

    final tMin = times.reduce((a, b) => a < b ? a : b);
    final tMax = times.reduce((a, b) => a > b ? a : b);

    const wPrice = 0.5;
    const wDistance = 0.35;
    const wTime = 0.15;

    double score(Station s) {
      final price = _lowestPrice(s, fuels);
      if (!price.isFinite) return double.infinity;

      final pNorm = (price - pMin) / (pMax - pMin + 1e-9);
      final dNorm = (s.distanceKm - dMin) / (dMax - dMin + 1e-9);
      final tNorm =
          (tMax - s.lastUpdate.millisecondsSinceEpoch) / (tMax - tMin + 1e-9);

      return wPrice * pNorm + wDistance * dNorm + wTime * tNorm;
    }

    targetList.sort((a, b) => score(a).compareTo(score(b)));
  }

  void _handleAutoUpdates() {
    if (_pos == null || _settings == null) return;

    if (_pos!.isLoading || _pos!.latitude == null) {
      return;
    }

    if (_lastRadiusKm == null) {
      logger.i(
        "L'ultimo raggio di ricerca era nullo (primo caricamento o refresh forzato).",
      );
      loadStations();
      return;
    }

    if (_settings!.radiusKm != _lastRadiusKm) {
      logger.i("Il raggio nuovo è diverso da quello precedente.");
      loadStations();
      return;
    }

    if (_settings!.selectedFuels != _lastFuels) {
      logger.i("Il filtro dei distributori è cambiato.");
      _applyFuelFilter(_settings!.selectedFuels);
      return;
    }
  }

  Future<void> _refineTopDrivingDistances(
    double fromLat,
    double fromLng,
  ) async {
    final stopwatch = Stopwatch()..start();
    logger.i("Ottenendo distanze reali in auto...");
    final candidates = List<Station>.from(_allStations)
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    final topCandidates = candidates.take(20).toList();

    final futures = topCandidates.map((station) async {
      try {
        final realDistance = await _service.fetchDrivingDistanceKm(
          fromLat: fromLat,
          fromLng: fromLng,
          toLat: station.latitude,
          toLng: station.longitude,
        );
        return MapEntry(station, realDistance);
      } catch (_) {
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);

    for (final entry in results) {
      if (entry == null) continue;
      entry.key.distanceKm = entry.value;
    }

    final radiusKm = _settings!.radiusKm;
    stations = _allStations.where((s) => s.distanceKm <= radiusKm).toList();

    stopwatch.stop();
    logger.i(
      "Distanze reali ottenute. Latenza: ${stopwatch.elapsedMilliseconds} ms",
    );
  }

  double _lowestPrice(Station s, List<FuelType> fuels) {
    final matches = s.prices.entries
        .where((e) => fuels.contains(e.key))
        .map((e) => e.value.pricePerLiter);

    if (matches.isEmpty) return double.infinity;
    return matches.reduce((a, b) => a < b ? a : b);
  }

  StationError _mapExceptionToError(Object e) {
    if (e is ApiException || e is ApiTimeoutException) {
      return StationError.ministry;
    }
    if (e is NoRouteException) {
      return StationError.routes;
    }
    if (e is NetworkException) {
      return StationError.network;
    }
    return StationError.unknown;
  }
}