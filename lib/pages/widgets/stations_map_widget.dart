import 'dart:async';

import 'package:carbur_app/extensions/brand_estensions.dart';
import 'package:carbur_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../extensions/prices_estensions.dart';
import '../../models/fuel_type.dart';
import '../../models/station.dart';
import '../../providers/position_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_provider.dart';
import '../../utils/hyperlink_utils.dart';
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

  Set<Marker> _markers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildMarkers();
  }

  Future<void> _rebuildMarkers() async {
    final stationsProvider = context.read<StationProvider>();
    final brightness = Theme.of(context).brightness;
    final stations = stationsProvider.mapStations;

    final hash = Object.hashAll(stations.map((s) => s.id));

    if (_lastBrightness == brightness && _lastStationsHash == hash) {
      return;
    }

    final pos = context.read<LocationProvider>();
    if (pos.latitude == null || pos.longitude == null) {
      return;
    }

    _lastBrightness = brightness;
    _lastStationsHash = hash;

    final bg = brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;
    final fg = brightness == Brightness.dark ? Colors.white : Colors.black;

    final markers = <Marker>{};

    for (final s in stationsProvider.mapStations) {
      final price =
          "${s.prices.values.first.pricePerLiter.toStringAsFixed(3)} €";

      final icon =
          await PriceMarker(
            price: price,
            background: bg,
            textColor: fg,
            logo: Image.asset(s.brand.asset, fit: BoxFit.contain),
          ).toBitmapDescriptor(
            logicalSize: const Size(78, 30),
            imageSize: const Size(234, 90),
          );

      markers.add(
        Marker(
          markerId: MarkerId(s.id.toString()),
          position: LatLng(s.latitude, s.longitude),
          icon: icon,
          anchor: const Offset(0.5, 1),
          onTap: () {
            _onMarkerTap(s);
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMarkerTap(Station s) {
    final l = AppLocalizations.of(context)!;
    final settings = context.read<SettingsProvider>();

    final prices = s.visiblePrices(settings.selectedFuels);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            s.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final p in prices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "${p.key.label(context)}: "
                    "${p.value.pricePerLiter.toStringAsFixed(3)} €",
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                l.last_update(
                  DateFormat.MMMMd(
                    Localizations.localeOf(context).toString(),
                  ).format(s.lastUpdate),
                  DateFormat.Hm(
                    Localizations.localeOf(context).toString(),
                  ).format(s.lastUpdate),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(l.start_navigation_question),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                openNavigation(s.latitude, s.longitude);
              },
              child: Text(l.ok),
            ),
          ],
        );
      },
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
