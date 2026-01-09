import 'package:carbur_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../extensions/navigation_extensions.dart';
import '../../providers/map_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_provider.dart';
import '../../utils/logger.dart';
import 'common_map.dart';

class StationsMap extends StatefulWidget {
  const StationsMap({super.key});

  @override
  State<StationsMap> createState() => _StationsMapState();
}

class _StationsMapState extends State<StationsMap> {
  void _triggerRebuild(BuildContext context) {
    final stationsProvider = context.read<StationProvider>();
    final mapProvider = context.read<MapProvider>();

    mapProvider.rebuildMarkers(
      stations: stationsProvider.mapStations,
      settings: context.read<SettingsProvider>(),
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
      onStationTap: (s) => context.openStationDetails(s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stationsProvider = context.watch<StationProvider>();
    final mapProvider = context.watch<MapProvider>();
    final positionProvider = context.watch<LocationProvider>();
    final settings = context.read<SettingsProvider>();

    final l = AppLocalizations.of(context)!;

    if (stationsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (positionProvider.latitude == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stationsProvider.error != null) {
      return RefreshIndicator(
        onRefresh: () async {
          final pos = context.read<LocationProvider>();
          await pos.refreshPosition();

          if (pos.latitude != null) {
            await stationsProvider.loadStations(
                lat: pos.latitude!,
                lng: pos.longitude!,
                radiusKm: settings.radiusKm,
                fuels: settings.selectedFuels,
                sort: settings.sort,
            );
          }
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          switch (stationsProvider.error!) {
                            StationError.ministry => Icons.error_outline,
                            StationError.routes => Icons.error_outline,
                            StationError.network => Icons.wifi_off_outlined,
                            StationError.unknown => Icons.error_outline,
                          },
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
                              l.error_description_no_connection,
                            StationError.unknown => l.error_description_unknown,
                          },
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.i(
        "[Map Widget] Le dipendenze sono cambiate. Aggiornamento marker richiesto.",
      );
      _triggerRebuild(context);
    });

    return CommonMap(
      markers: mapProvider.markers,
      initialPosition: LatLng(
        positionProvider.latitude!,
        positionProvider.longitude!,
      ),
      showMyLocation: true,
      onCameraMove: (position) {
        if (mapProvider.updateZoom(position.zoom)) {
          logger.i(
            "Lo zoom della mappa è cambiato molto. Aggiornamento marker richiesto.",
          );
          _triggerRebuild(context);
        }
      },
    );
  }
}
