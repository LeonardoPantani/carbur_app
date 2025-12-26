import 'package:carbur_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../extensions/navigation_extensions.dart';
import '../../providers/map_provider.dart';
import '../../providers/position_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_provider.dart';
import 'common_map.dart';

class StationsMap extends StatefulWidget {
  const StationsMap({super.key});

  @override
  State<StationsMap> createState() => _StationsMapState();
}

class _StationsMapState extends State<StationsMap> {
  @override
  Widget build(BuildContext context) {
    final stationsProvider = context.watch<StationProvider>();
    final mapProvider = context.watch<MapProvider>();
    final positionProvider = context.watch<LocationProvider>();
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

    if (positionProvider.latitude == null ||
        positionProvider.longitude == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // trigger that regenerates markers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapProvider.rebuildMarkers(
        stations: stationsProvider.mapStations,
        settings: context.read<SettingsProvider>(),
        brightness: Theme.of(context).brightness,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
        onStationTap: (s) => context.openStationDetails(s),
      );
    });

    return CommonMap(
      markers: mapProvider.markers,
      initialPosition: LatLng(
        positionProvider.latitude!,
        positionProvider.longitude!,
      ),
      showMyLocation: true,
    );
  }
}
