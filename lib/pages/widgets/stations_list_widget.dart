import 'package:carbur_app/models/fuel_type.dart';
import 'package:carbur_app/models/station.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../extensions/brand_estensions.dart';
import '../../extensions/prices_estensions.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/position_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_details_provider.dart';
import '../../providers/station_provider.dart';
import '../../extensions/number_extensions.dart';
import '../station_details_page.dart';

class StationsList extends StatelessWidget {
  const StationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StationProvider>();
    final settings = context.watch<SettingsProvider>();
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

                return ListTile(
                  leading: Image.asset(
                    station.brand.asset,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          children: _buildPriceSpans(
                            context,
                            station,
                            settings,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.last_update(
                          DateFormat.MMMMd(
                            Localizations.localeOf(context).toString(),
                          ).format(station.lastUpdate),
                          DateFormat.Hm(
                            Localizations.localeOf(context).toString(),
                          ).format(station.lastUpdate),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        station.distanceKm.formatDistance(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("km", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) =>
                              StationDetailsProvider(station)..loadDetails(),
                          child: const StationDetailsPage(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildPriceSpans(
    BuildContext context,
    Station station,
    SettingsProvider settings,
  ) {
    final prices = station.visiblePrices(settings.selectedFuels);
    final spans = <InlineSpan>[];

    for (int i = 0; i < prices.length; i++) {
      spans.add(TextSpan(text: "${prices[i].key.label(context)}: "));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${prices[i].value.pricePerLiter.formatPrice(context)} €",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      if (i < prices.length - 1) {
        spans.add(const TextSpan(text: " • "));
      }
    }
    return spans;
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
            leading: Container(width: 50, height: 50, color: highlight),
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
