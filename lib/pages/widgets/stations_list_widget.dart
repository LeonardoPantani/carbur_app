import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/position_provider.dart';
import '../../providers/station_provider.dart';
import 'station_list_tile.dart';

class StationsList extends StatelessWidget {
  const StationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StationProvider>();
    AppLocalizations l = AppLocalizations.of(context)!;

    if (provider.isLoading) {
      return RefreshIndicator(
        onRefresh: () async {},
        child: const ShimmerStationList(),
      );
    }

    if (provider.error != null) {
      return RefreshIndicator(
        onRefresh: () => _onRefresh(context),
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
                  switch (provider.error!) {
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

    if (provider.listStations.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Center(
              heightFactor: 10,
              child: Text(AppLocalizations.of(context)!.no_stations_found),
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
            child: Text(
              l.stations_found(provider.listStations.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: ValueKey(Theme.of(context).brightness),
              itemCount: provider.listStations.length,
              itemBuilder: (context, index) {
                final station = provider.listStations[index];
                return StationTile(station: station);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final pos = context.read<LocationProvider>();
    final stations = context.read<StationProvider>();
    await pos.refreshPosition();
    await stations.forceReload();
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
            leading: Container(width: 75, height: 75, color: highlight),
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
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.35,
                  color: highlight,
                ),
              ],
            ),
            trailing: Container(height: 16, width: 40, color: highlight),
          ),
        );
      },
    );
  }
}
