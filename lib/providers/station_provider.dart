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
    notifyListeners();

    try {
      final stopwatch = Stopwatch()..start();
      logger.i("contattando il sito del ministero, lat = $lat, lng = $lng");
      _allStations = await _service.fetchStations(
        lat: lat,
        lng: lng,
        radiusKm: fetchRadiusKm,
      );
      stopwatch.stop();
      logger.i(
        "l'ottenimento dei dati dal ministero ha richiesto ${stopwatch.elapsedMilliseconds} ms",
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
    logger.i("forzando ricarica");
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

  void _applySorting(List<FuelType> fuels) {
    if (_sort == StationSort.best) {
      _applyBestSorting(fuels);
      return;
    }

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
      First we calculate max() and min() of the following parameters from all stations found within range:
      - distance
      - price
      - update time

      Then we normalize. Distance and Price must be lower while Update Time must be most recent (higher):
        d'_s = (d_s - min(d))/(max(d)-min(d))
        p'_s = (p_s - min(p))/(max(p)-min(p))
        t'_s = (max(t)-t_s)/(max(t)-min(t))
      
      We now have values between [0, 1], Distance and Price near 0 are good, Update Time near 1 is good.

      Finally we calculate the cost function:
        score = w_d * d'_s + w_p * p'_s + w_t * t'_s
      with the following constraint (vincolo):
        w_d + w_p + w_t = 1
  */

  void _applyBestSorting(List<FuelType> fuels) {
    if (stations.isEmpty) return;

    final prices = stations
        .map((s) => _lowestPrice(s, fuels))
        .where((p) => p.isFinite)
        .toList();

    if (prices.isEmpty) return;

    final distances = stations.map((s) => s.distanceKm).toList();
    final times = stations
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

    stations.sort((a, b) => score(a).compareTo(score(b)));
  }

  void _handleAutoUpdates() {
    logger.i("handleAutoUpdates chiamata");
    if (_pos == null || _settings == null) return;

    if (_pos!.isLoading || _pos!.latitude == null) {
      return;
    }

    if (_lastRadiusKm == null) {
      logger.i(
        "il raggio di ricerca ultimo era nullo (primo caricamento o refresh forzato)",
      );
      loadStations();
      return;
    }

    if (_settings!.radiusKm != _lastRadiusKm) {
      logger.i("il raggio nuovo è diverso da quello precedente");
      loadStations();
      return;
    }

    if (_settings!.selectedFuels != _lastFuels) {
      logger.i("il filtro dei distributori è cambiato");
      _applyFuelFilter(_settings!.selectedFuels);
      return;
    }
  }

  // ignore: unused_element
  Future<void> _refineTopDrivingDistances(
    double fromLat,
    double fromLng,
  ) async {
    final stopwatch = Stopwatch()..start();
    logger.i("ottenendo distanze reali in auto...");
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
      "aggiornamento distanze reali completato in ${stopwatch.elapsedMilliseconds} ms",
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
