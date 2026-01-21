import 'package:carbur_app/pages/widgets/brand_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/fuel_type.dart';
import '../../models/station.dart';
import '../../providers/settings_provider.dart';
import '../../extensions/prices_estensions.dart';
import '../../extensions/number_extensions.dart';
import '../../extensions/navigation_extensions.dart';
import '../../l10n/app_localizations.dart';

class StationTile extends StatelessWidget {
  final Station station;
  final bool showDistance;

  const StationTile({
    super.key,
    required this.station,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      horizontalTitleGap: 3,
      leading: SizedBox(
        width: 75,
        child: AspectRatio(
          aspectRatio: 1,
          child: BrandLogoWidget(brandName: station.brand, size: 75,),
        ),
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              children: _buildPriceSpans(context, station, settings),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.last_update(
              DateFormat.MMMMd(
                Localizations.localeOf(context).toString(),
              ).format(station.lastUpdate)
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: showDistance
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                  Text(
                    station.distanceKm.formatDistance(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("km", style: Theme.of(context).textTheme.bodySmall),
                ],
            )
          : null,
      onTap: () => context.openStationDetails(station),
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
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${prices[i].value.pricePerLiter.formatPrice(context)} €",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      if (i < prices.length - 1) spans.add(const TextSpan(text: " • "));
    }
    return spans;
  }
}
