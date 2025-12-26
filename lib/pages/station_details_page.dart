import 'package:carbur_app/extensions/number_extensions.dart';
import 'package:carbur_app/extensions/prices_estensions.dart';
import 'package:carbur_app/models/fuel_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../extensions/brand_estensions.dart';
import '../extensions/station_facilities_extension.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/station_details_provider.dart';
import '../utils/hyperlink_utils.dart';

class StationDetailsPage extends StatelessWidget {
  const StationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StationDetailsProvider>();
    final l = AppLocalizations.of(context)!;

    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.station_details_title)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null || provider.details == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.station_details_title)),
        body: Center(child: Text(l.error_description_unknown)),
      );
    }

    final details = provider.details!;
    final station = details.station;

    final weekDays = [
      l.weekday_monday,
      l.weekday_tuesday,
      l.weekday_wednesday,
      l.weekday_thursday,
      l.weekday_friday,
      l.weekday_saturday,
      l.weekday_sunday,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.station_details_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // row that comprehends: title, address | brand logo image
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // title, address
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title (clickable)
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      content: Text(
                                        l.station_identifier(station.id),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(l.ok),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  station.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                              // address
                              Text(
                                details.address,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // logo
                        Image.asset(
                          station.brand.asset,
                          width: 75,
                          height: 75,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // fuel prices header
                    Text(
                      l.fuel_prices_title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    // list of fuel prices (showing only selected in settings)
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        final prices = station.visiblePrices(
                          settings.selectedFuels,
                        );

                        if (prices.isEmpty) {
                          return Text(
                            l.fuel_prices_not_available,
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: prices.map((p) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${p.key.label(context)}: ${p.value.pricePerLiter.formatPrice(context)} €',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // opening hours headers
                    Text(
                      l.opening_hours_title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    // showing error if empty
                    if (details.openingHours.isEmpty)
                      Text(l.opening_hours_not_available, style: TextStyle(color: Theme.of(context).colorScheme.secondary),)
                    else
                      // showing disclaimer and table with opening hours
                      Text(
                        l.opening_hours_note,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (details.openingHours.isNotEmpty)
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        border: TableBorder.symmetric(
                          inside: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        children: [
                          TableRow(
                            children: [
                              _th(context, l.weekday),
                              _th(context, l.morning),
                              _th(context, l.afternoon),
                            ],
                          ),
                          ...List.generate(details.openingHours.length, (i) {
                            final o = details.openingHours[i];

                            String morning = '--';
                            String afternoon = '--';

                            if (!o.closed && !o.h24) {
                              morning =
                                  '${o.morningOpen ?? '--'}-${o.morningClose ?? '--'}';
                              afternoon =
                                  '${o.afternoonOpen ?? '--'}-${o.afternoonClose ?? '--'}';
                            } else if (o.h24) {
                              morning = l.open_24h;
                              afternoon = l.open_24h;
                            }

                            return TableRow(
                              children: [
                                _td(context, weekDays[i]),
                                _td(context, morning),
                                _td(context, afternoon),
                              ],
                            );
                          }),
                        ],
                      ),
                    const SizedBox(height: 12),

                    // facilities header
                    Text(
                      l.facilities_title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    // showing error if empty
                    if (details.services.isEmpty)
                      Text(l.facilities_not_available, style: TextStyle(color: Theme.of(context).colorScheme.secondary),)
                    else
                      // showing list of facilities
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: details.services.map((f) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• ${f.label(context)}'),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),

                    // other infos header
                    Text(
                      l.other_infos_title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    // showing error if empty
                    if (details.phone?.isEmpty == true && details.email?.isEmpty == true && details.website?.isEmpty == true)
                      Text(l.other_infos_notavailable, style: TextStyle(color: Theme.of(context).colorScheme.secondary),)
                    else
                      // showing other infos: phone, email, website
                      if (details.phone?.isNotEmpty == true)
                        Row(
                          children: [
                            Text('${l.phone}: ',),
                            InkWell(
                              onTap: () => openPhone(details.phone!),
                              child: Text(
                                details.phone!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                      if (details.email?.isNotEmpty == true)
                        Row(
                          children: [
                            Text('${l.email}: ',),
                            InkWell(
                              onTap: () => openEmail(details.email!),
                              child: Text(
                                details.email!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                      if (details.website?.isNotEmpty == true)
                        Row(
                          children: [
                            Text('${l.website}: '),
                            InkWell(
                              onTap: () => openWebsite(details.website!),
                              child: Text(
                                details.website!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),

            // showing at the bottom the back and navigate buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l.back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: Text(l.start_navigation),
                    onPressed: () {
                      openNavigation(station.latitude, station.longitude);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _th(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _td(BuildContext context, String text) {
    return Padding(padding: const EdgeInsets.all(8), child: Text(text));
  }
}
