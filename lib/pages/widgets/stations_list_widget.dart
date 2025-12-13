import 'package:carbur_app/models/fuel_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

import '../../extensions/brand_estensions.dart';
import '../../extensions/prices_estensions.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/position_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_provider.dart';
import '../../extensions/number_extensions.dart';

class StationList extends StatelessWidget {
  const StationList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StationProvider>();
    final settings = context.watch<FuelSettingsProvider>();

    if (provider.isLoading) return const ShimmerStationList();

    if (provider.error != null) {
      return Center(child: Text("Error: ${provider.error}"));
    }

    if (provider.stations.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          final pos = context.read<PositionProvider>();
          final stations = context.read<StationProvider>();
          await pos.refreshPosition();
          await stations.forceReload();
        },
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
      onRefresh: () async {
        final pos = context.read<PositionProvider>();
        final stations = context.read<StationProvider>();
        await pos.refreshPosition();
        await stations.forceReload();
      },
      child: ListView.builder(
        key: ValueKey(Theme.of(context).brightness),
        itemCount: provider.stations.length,
        itemBuilder: (context, index) {
          final station = provider.stations[index];
          final prices = station.visiblePrices(settings.selectedFuels);
          final spans = <InlineSpan>[];
          for (int i = 0; i < prices.length; i++) {
            spans.add(TextSpan(text: "${prices[i].key.label(context)}: "));
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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

          // single element
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
                    children: spans,
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
            onTap: () async {
              final uri = Uri.parse(
                "https://www.google.com/maps/dir/?api=1&origin=&destination=${station.latitude},${station.longitude}&travelmode=driving",
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          );
        },
      ),
    );
  }
}

// fake list shown while loading
class ShimmerStationList extends StatelessWidget {
  const ShimmerStationList({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
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
