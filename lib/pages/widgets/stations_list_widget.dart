import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/station.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_provider.dart';
import '../../providers/favorites_provider.dart';
import 'station_list_tile.dart';

class StationsList extends StatelessWidget {
  const StationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final stationsProvider = context.watch<StationProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    AppLocalizations l = AppLocalizations.of(context)!;

    if (stationsProvider.isLoading) {
      return RefreshIndicator(
        onRefresh: () async {},
        child: const ShimmerStationList(),
      );
    }

    bool isFavLoading = favoritesProvider.showFavoritesOnly && favoritesProvider.isLoading;
    if (stationsProvider.isLoading || isFavLoading) {
      return RefreshIndicator(
        onRefresh: () async {},
        child: const ShimmerStationList(),
      );
    }

    if (stationsProvider.error != null) {
      return RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: LayoutBuilder(
          builder: (context, constraints) {
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

    List<Station> stationsToShow;

    if (favoritesProvider.showFavoritesOnly) {
      stationsToShow = stationsProvider.sortStations(favoritesProvider.favoriteStations);
    } else {
      stationsToShow = stationsProvider.listStations;
    }

    if (stationsToShow.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      favoritesProvider.showFavoritesOnly
                          ? Icons.star_border
                          : Icons.local_gas_station_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      favoritesProvider.showFavoritesOnly
                          ? l.favorites_empty
                          : l.no_stations_found,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  favoritesProvider.showFavoritesOnly
                      ? l.stations_favorited(stationsToShow.length)
                      : l.stations_found(stationsToShow.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              key: ValueKey(Theme.of(context).brightness),
              itemCount: stationsToShow.length,
              itemBuilder: (context, index) {
                final station = stationsToShow[index];
                return StationTile(
                  station: station,
                  showDistance: !favoritesProvider.showFavoritesOnly,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final pos = context.read<LocationProvider>();
    final settings = context.read<SettingsProvider>();
    final stations = context.read<StationProvider>();
    final favorites = context.read<FavoritesProvider>();
    
    await pos.tryInitializeLocation();

    if (pos.latitude != null) {
       await stations.loadStations(
          lat: pos.latitude!,
          lng: pos.longitude!,
          radiusKm: settings.radiusKm,
          fuels: settings.selectedFuels,
          sort: settings.sort,
       );
    }

    if (favorites.showFavoritesOnly) {
      await favorites.refreshData();
    }
  }
}

class ShimmerStationList extends StatelessWidget {
  const ShimmerStationList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return ListView.builder(
      itemCount: 11,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Shimmer.fromColors(
                baseColor: base,
                highlightColor: highlight,
                child: Container(
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(color: highlight),
                ),
              ),
            ),
          );
        }

        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12, 6, 16, 4),
            horizontalTitleGap: 12,
            leading: SizedBox(
              width: 60,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(color: highlight),
              ),
            ),
            title: Container(
              height: 16,
              width: double.infinity,
              color: highlight,
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.6,
                  color: highlight,
                ),
                const SizedBox(height: 10),
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.35,
                  color: highlight,
                ),
              ],
            ),
            trailing: Container(height: 30, width: 20, color: highlight),
          ),
        );
      },
    );
  }
}