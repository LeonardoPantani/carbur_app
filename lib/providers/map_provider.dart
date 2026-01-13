import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/station.dart';
import '../pages/widgets/marker_generator.dart';
import 'settings_provider.dart';

class MapProvider extends ChangeNotifier {
  // hash that allows us to regenerate markers only if needed, when a dependency changes
  int? _lastStationsHash;

  // markers cache
  final Map<String, BitmapDescriptor> _markerCache = {};

  // dots cache
  BitmapDescriptor? _dotGreen;
  BitmapDescriptor? _dotYellow;
  BitmapDescriptor? _dotRed;

  // zoom handling
  double _currentZoom = 15;
  static const double _zoomThreshold = 13;

  // markers list
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  bool updateZoom(double newZoom) {
    if (newZoom == _currentZoom) return false;

    final oldIsSimple = _currentZoom < _zoomThreshold;
    final newIsSimple = newZoom < _zoomThreshold;
    _currentZoom = newZoom;
    return oldIsSimple != newIsSimple;
  }

  Future<void> rebuildMarkers({
    required List<Station> stations,
    required SettingsProvider settings,
    required double pixelRatio,
    required Function(Station) onStationTap,
  }) async {
    MarkerGenerator.initialize(pixelRatio);

    final bool useSimpleMarkers = _currentZoom < _zoomThreshold;

    final markerFuel = settings.preferredMarkerFuel;

    // calculating hashes
    final hash = Object.hashAll([
      ...stations.map((s) => '${s.id}-${s.prices[markerFuel]?.pricePerLiter}'),
      useSimpleMarkers,
    ]);

    // not doing anything if hash is the same
    if (_lastStationsHash == hash) {
      return;
    }
    _lastStationsHash = hash;

    // calculating price thresholds
    double? lowThreshold;
    double? highThreshold;

    if (stations.isNotEmpty) {
      final prices = stations
          .map((s) => s.prices[markerFuel]?.pricePerLiter)
          .whereType<double>()
          .toList();

      if (prices.isNotEmpty) {
        prices.sort();
        int lowIndex = (prices.length * 0.20).ceil() - 1;
        int highIndex = (prices.length * 0.70).ceil() - 1;
        if (lowIndex < 0) lowIndex = 0;
        if (highIndex < 0) highIndex = 0;

        lowThreshold = prices[lowIndex];
        highThreshold = prices[highIndex];
      }
    }

    // preparing dots if needed
    if (useSimpleMarkers) {
      if (_dotGreen == null) {
        _dotGreen = await MarkerGenerator.createDotMarker(
          backgroundColor: MarkerGenerator.colorCheap,
        );
        _dotYellow = await MarkerGenerator.createDotMarker(
          backgroundColor: MarkerGenerator.colorAverage,
        );
        _dotRed = await MarkerGenerator.createDotMarker(
          backgroundColor: MarkerGenerator.colorExpensive,
        );
      }
    } else {
      // else preparing detailed markers
      final List<Future<void>> tasks = [];
      for (final s in stations) {
        final fuelPrice = s.prices[markerFuel];
        if (fuelPrice == null) continue;

        final priceVal = fuelPrice.pricePerLiter;
        final priceStr = "${priceVal.toStringAsFixed(3)} €";
        final brandName = s.brand;
        final color = MarkerGenerator.getColorForPrice(
          priceVal,
          lowThreshold,
          highThreshold,
        );

        // cache key calculated from: price + brand + color
        final cacheKey = '$priceStr-$brandName-${color.toARGB32()}';

        if (!_markerCache.containsKey(cacheKey)) {
          tasks.add(
            MarkerGenerator.createPriceMarker(
              price: priceStr,
              brandName: brandName,
              backgroundColor: color,
            ).then((bit) => _markerCache[cacheKey] = bit),
          );
        }
      }
      if (tasks.isNotEmpty) await Future.wait(tasks);
    }

    // creating final marker
    _markers = stations
        .map((s) {
          final fuelPrice = s.prices[markerFuel];
          if (fuelPrice == null) return null;

          final priceVal = fuelPrice.pricePerLiter;

          if (useSimpleMarkers) {
            // --- DOT MARKER ---
            BitmapDescriptor icon;
            final color = MarkerGenerator.getColorForPrice(
              priceVal,
              lowThreshold,
              highThreshold,
            );
            if (color == MarkerGenerator.colorCheap) {
              icon = _dotGreen!;
            } else if (color == MarkerGenerator.colorAverage) {
              icon = _dotYellow!;
            } else {
              icon = _dotRed!;
            }

            return Marker(
              markerId: MarkerId(s.id.toString()),
              position: LatLng(s.latitude, s.longitude),
              icon: icon,
              anchor: const Offset(0.5, 0.5),
              onTap: () => onStationTap(s),
              zIndexInt: 0,
            );
          } else {
            // --- DETAILED MARKER ---
            final priceStr = "${priceVal.toStringAsFixed(3)} €";
            final color = MarkerGenerator.getColorForPrice(
              priceVal,
              lowThreshold,
              highThreshold,
            );
            final cacheKey = '$priceStr-${s.brand}-${color.toARGB32()}';

            // calculating zIndex in case of clipping of the bubble caused by near fuel stations
            int zIndexInt = 0;
            if (priceVal > 0) {
              zIndexInt = -(priceVal * 1000).round();
            } else {
              zIndexInt = -9999;
            }

            return Marker(
              markerId: MarkerId(s.id.toString()),
              position: LatLng(s.latitude, s.longitude),
              icon: _markerCache[cacheKey]!,
              anchor: const Offset(0.5, 1),
              onTap: () => onStationTap(s),
              zIndexInt: zIndexInt,
            );
          }
        })
        .whereType<Marker>()
        .toSet();

    notifyListeners();
  }

  void clearMarkers() {
    _markers = {};
    _markerCache.clear();
    notifyListeners();
  }
}
