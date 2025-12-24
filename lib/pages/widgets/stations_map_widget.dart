import 'dart:async';

import 'package:carbur_app/extensions/brand_estensions.dart';
import 'package:carbur_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/station.dart';
import '../../providers/position_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_details_provider.dart';
import '../../providers/station_provider.dart';
import '../../utils/logger.dart';
import '../station_details_page.dart';
import 'price_marker_widget.dart';

class StationsMap extends StatefulWidget {
  const StationsMap({super.key});

  @override
  State<StationsMap> createState() => _StationsMapState();
}

class _StationsMapState extends State<StationsMap> {
  final MapType _mapType = MapType.normal;
  Brightness? _lastBrightness;
  int? _lastStationsHash;
  final Map<String, BitmapDescriptor> _markerCache = {};

  Set<Marker> _markers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildMarkers();
  }

  Future<void> _rebuildMarkers() async {
    final stationsProvider = context.read<StationProvider>();
    final stations = stationsProvider.mapStations;
    final settings = context.read<SettingsProvider>();

    if (stations.isEmpty) {
      if (_markers.isNotEmpty && mounted) {
        setState(() => _markers = {});
      }
      return;
    }

    final brightness = Theme.of(context).brightness;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final markerFuel =
        settings.preferredMarkerFuel ??
        (settings.selectedFuels.isNotEmpty
            ? settings.selectedFuels.first
            : null);

    final hash = Object.hashAll(
      stations.map((s) {
        final price = markerFuel == null
            ? null
            : s.prices[markerFuel]?.pricePerLiter;

        return '${s.id}-$price';
      }),
    );

    if (_lastBrightness == brightness && _lastStationsHash == hash) {
      return;
    }

    logger.i("ricostruzione markers...");
    final stopwatch = Stopwatch()..start();

    _lastBrightness = brightness;
    _lastStationsHash = hash;

    final List<Future<void>> iconTasks = [];

    for (final s in stations) {
      final fuelPrice = markerFuel == null ? null : s.prices[markerFuel];

      if (fuelPrice == null) {
        continue;
      }

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
          ).then((bit) {
            _markerCache[cacheKey] = bit;
          }),
        );
      }
    }

    if (iconTasks.isNotEmpty) {
      await Future.wait(iconTasks);
    }

    final markers = stations
        .map((s) {
          final fuelPrice = markerFuel == null ? null : s.prices[markerFuel];

          if (fuelPrice == null) {
            return null;
          }

          final price = "${fuelPrice.pricePerLiter.toStringAsFixed(3)} €";

          final assetPath = s.brand.asset;
          final cacheKey = '$price-$assetPath-$brightness';

          return Marker(
            markerId: MarkerId(s.id.toString()),
            position: LatLng(s.latitude, s.longitude),
            icon: _markerCache[cacheKey]!,
            anchor: const Offset(0.5, 1),
            onTap: () => _openDetails(s),
          );
        })
        .whereType<Marker>()
        .toSet();

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }

    stopwatch.stop();
    logger.i(
      "la ricostruzione dei marker ha richiesto ${stopwatch.elapsedMilliseconds} ms",
    );
  }

  void _openDetails(Station s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => StationDetailsProvider(s)..loadDetails(),
          child: const StationDetailsPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stationsProvider = context.watch<StationProvider>();
    final pos = context.watch<LocationProvider>();
    final l = AppLocalizations.of(context)!;

    if (stationsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stationsProvider.error != null) {
      return RefreshIndicator(
        onRefresh: () async {
          final pos = context.read<LocationProvider>();
          final stations = context.read<StationProvider>();
          await pos.refreshPosition();
          await stations.forceReload();
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 96,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  switch (stationsProvider.error!) {
                    StationError.ministry =>
                      l.error_description_api_ministry_notworking,
                    StationError.routes =>
                      l.error_description_api_routes_notworking,
                    StationError.network =>
                      l.error_description_api_ministry_notworking,
                    StationError.unknown => l.error_description_unknown,
                  },
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (pos.latitude == null || pos.longitude == null) {
      return const Center(child: CircularProgressIndicator());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildMarkers();
    });

    final brightness = Theme.of(context).brightness;
    final mapStyle = brightness == Brightness.dark
        ? _darkMapStyle
        : _lightMapStyle;

    final userLatLng = LatLng(pos.latitude!, pos.longitude!);

    return GoogleMap(
      key: ValueKey(brightness),
      style: mapStyle,
      initialCameraPosition: CameraPosition(target: userLatLng, zoom: 14.5),
      markers: _markers,
      mapType: _mapType,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1d1d1d"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d1d1d"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1626"}]
  },
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  }
]
''';

const String _lightMapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  }
]
''';
