import 'dart:math';

import 'package:flutter/material.dart';
import '../exceptions/custom_exceptions.dart';
import '../models/fuel_type.dart';
import '../models/station.dart';
import '../models/station_sort.dart';
import '../repositories/station_repository.dart';
import '../utils/logger.dart';

enum StationError { ministry, routes, network, unknown }

class StationProvider extends ChangeNotifier {
  final StationRepository _repository = StationRepository();

  double? _lastFetchLat;
  double? _lastFetchLng;
  int? _lastFetchRadius;

  int _filterRadiusKm = 10;
  List<FuelType> _filterFuels = [];
  StationSort _currentSort = StationSort.best;
  List<Station> _allStations = [];

  List<Station> stations = [];
  bool isLoading = false;
  StationError? error;
  StationSort get currentSort => _currentSort;

  // ---- public methods
  Future<void> loadStations({
    required double lat,
    required double lng,
    required int radiusKm,
    required List<FuelType> fuels,
    required StationSort sort,
  }) async {
    // checking if we need to reload
    final movedTooMuch = _lastFetchLat == null || _lastFetchLng == null
        ? true
        : _movedMoreThanXMeters(100, lat, lng, _lastFetchLat!, _lastFetchLng!);
    bool needsNetworkFetch =
        _allStations.isEmpty ||
        movedTooMuch ||
        (_lastFetchRadius != null && radiusKm > _lastFetchRadius!);

    _filterRadiusKm = radiusKm;
    _filterFuels = List.from(fuels);
    _currentSort = sort;

    if (needsNetworkFetch) {
      _lastFetchLat = lat;
      _lastFetchLng = lng;
      _lastFetchRadius = radiusKm;

      await _fetchFromNetwork();
    } else {
      logger.i("Parametri di rete invariati. Applico solo filtri locali.");
      _applyLocalFilters();
    }
  }

  List<Station> get listStations {
    return _filterByFuel(
      stations,
    ).where((s) => s.distanceKm <= _filterRadiusKm).toList();
  }

  List<Station> get mapStations {
    const mapRadiusKm = 10.0;
    return _filterByFuel(
      _allStations,
    ).where((s) => s.distanceKm <= mapRadiusKm).toList();
  }

  void setSorting(StationSort sort) {
    logger.i("Cambiando ordinamento a ${sort.toString()}");
    _currentSort = sort;
    _performSort(stations, _filterFuels, _currentSort);
    notifyListeners();
  }

  List<Station> sortStations(List<Station> input) {
    final copy = List<Station>.from(input);
    _performSort(copy, _filterFuels, _currentSort);
    return copy;
  }

  // ---- private methods
  Future<void> _fetchFromNetwork() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      logger.i("Inizio download dati dal Repository...");
      _allStations = await _repository.fetchStationsWithDrivingDistances(
        lat: _lastFetchLat!,
        lng: _lastFetchLng!,
        radiusKm: _lastFetchRadius!,
      );

      _applyLocalFilters();
    } catch (e) {
      logger.e("Errore fetch: $e");
      error = _mapExceptionToError(e);
      _allStations = [];
      stations = [];
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyLocalFilters() {
    if (_filterFuels.isEmpty) {
      stations = List.from(_allStations);
    } else {
      stations = _allStations.where((s) {
        return s.prices.keys.any((k) => _filterFuels.contains(k));
      }).toList();
    }

    _performSort(stations, _filterFuels, _currentSort);

    notifyListeners();
  }

  void _performSort(
    List<Station> targetList,
    List<FuelType> fuels,
    StationSort sortMode,
  ) {
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

  List<Station> _filterByFuel(List<Station> input) {
    if (_filterFuels.isEmpty) return List.from(input);

    return input.where((s) {
      return s.prices.keys.any((k) => _filterFuels.contains(k));
    }).toList();
  }

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

  bool _movedMoreThanXMeters(
    int meters,
    double lat,
    double lng,
    double lastLat,
    double lastLng,
  ) {
    const metersPerDegree = 111000.0;

    final dLat = (lat - lastLat) * metersPerDegree;
    final dLng = (lng - lastLng) * metersPerDegree * cos(lat * pi / 180);

    final distanceSquared = dLat * dLat + dLng * dLng;
    return distanceSquared > meters * meters;
  }
}
