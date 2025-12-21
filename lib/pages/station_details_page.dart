import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../extensions/brand_estensions.dart';
import '../extensions/station_facilities_extension.dart';
import '../l10n/app_localizations.dart';
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              const SizedBox(height: 4),
                              Text(
                                details.address,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          station.brand.asset,
                          width: 75,
                          height: 75,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (details.phone?.isNotEmpty == true)
                      InkWell(
                        onTap: () => openPhone(details.phone!),
                        child: Text(
                          '${l.phone}: ${details.phone}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                    if (details.email?.isNotEmpty == true)
                      InkWell(
                        onTap: () => openEmail(details.email!),
                        child: Text(
                          '${l.email}: ${details.email}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                    if (details.website?.isNotEmpty == true)
                      InkWell(
                        onTap: () => openWebsite(details.website!),
                        child: Text(
                          '${l.website}: ${details.website}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    Text(
                      l.opening_hours_title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    if (details.openingHours.isNotEmpty)
                      Text(
                        l.opening_hours_note,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (details.openingHours.isEmpty)
                      Text(l.opening_hours_not_available)
                    else
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
                    const SizedBox(height: 24),

                    Text(
                      l.facilities_title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    if (details.services.isEmpty)
                      Text(l.facilities_not_available)
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: details.services.map((f) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• ${f.label(context)}'),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

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
