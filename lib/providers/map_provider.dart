import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../extensions/brand_estensions.dart';
import '../models/station.dart';
import '../pages/widgets/price_marker_widget.dart';
import 'settings_provider.dart';

class MapProvider extends ChangeNotifier {
  Brightness? _lastBrightness;
  int? _lastStationsHash;
  final Map<String, BitmapDescriptor> _markerCache = {};

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  Future<void> rebuildMarkers({
    required List<Station> stations,
    required SettingsProvider settings,
    required Brightness brightness,
    required double pixelRatio,
    required Function(Station) onStationTap,
  }) async {
    final markerFuel =
        settings.preferredMarkerFuel ??
        (settings.selectedFuels.isNotEmpty
            ? settings.selectedFuels.first
            : null);

    final hash = Object.hashAll(
      stations.map(
        (s) =>
            '${s.id}-${markerFuel == null ? null : s.prices[markerFuel]?.pricePerLiter}',
      ),
    );

    if (_lastBrightness == brightness && _lastStationsHash == hash) return;

    _lastBrightness = brightness;
    _lastStationsHash = hash;

    final List<Future<void>> iconTasks = [];
    for (final s in stations) {
      final fuelPrice = markerFuel == null ? null : s.prices[markerFuel];
      if (fuelPrice == null) continue;

      final price = "${fuelPrice.pricePerLiter.toStringAsFixed(3)} €";
      final assetPath = s.brand.asset;
      final cacheKey = '$price-$assetPath-$brightness';

      if (!_markerCache.containsKey(cacheKey)) {
        iconTasks.add(
          priceToMarker(
            price: price,
            brightness: brightness,
            pixelRatio: pixelRatio,
            assetPath: assetPath,
          ).then((bit) => _markerCache[cacheKey] = bit),
        );
      }
    }

    if (iconTasks.isNotEmpty) await Future.wait(iconTasks);

    _markers = stations
        .map((s) {
          final fuelPrice = markerFuel == null ? null : s.prices[markerFuel];
          if (fuelPrice == null) return null;

          final price = "${fuelPrice.pricePerLiter.toStringAsFixed(3)} €";
          final assetPath = s.brand.asset;
          final cacheKey = '$price-$assetPath-$brightness';

          return Marker(
            markerId: MarkerId(s.id.toString()),
            position: LatLng(s.latitude, s.longitude),
            icon: _markerCache[cacheKey]!,
            anchor: const Offset(0.5, 1),
            onTap: () => onStationTap(s),
          );
        })
        .whereType<Marker>()
        .toSet();

    notifyListeners();
  }

  void clearMarkers() {
  _markers = {};
  notifyListeners();
}
}
