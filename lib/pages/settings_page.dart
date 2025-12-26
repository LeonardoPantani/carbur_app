import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fuel_type.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/hyperlink_utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings_title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(l.settings_fuel_types),
                  subtitle: Text(
                    settings.selectedFuels
                        .map((f) => f.label(context))
                        .join(", "),
                  ),
                  leading: const Icon(Icons.local_gas_station),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openFuelSelectionDialog(context, settings),
                ),

                ListTile(
                  title: Text(l.settings_search_radius),
                  subtitle: Text("${settings.radiusKm} km"),
                  leading: const Icon(Icons.my_location),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openRadiusDialog(context, settings),
                ),

                ListTile(
                  title: Text(l.settings_marker_fuel),
                  subtitle: Text(
                    settings.preferredMarkerFuel?.label(context) ??
                        l.settings_marker_fuel_auto,
                  ),
                  leading: const Icon(Icons.price_check),
                  trailing: const Icon(Icons.chevron_right),
                  enabled: settings.selectedFuels.length > 1,
                  onTap: settings.selectedFuels.length > 1 ? () => _openMarkerFuelDialog(context, settings) : null,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: InkWell(
              onTap: () {
                openWebsite("https://github.com/LeonardoPantani");
              },
              child: Text(
                l.settings_footer_madeby("Leonardo Pantani"),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFuelSelectionDialog(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final l = AppLocalizations.of(context)!;
    List<FuelType> tempFuels = List.from(settings.selectedFuels);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(l.settings_select_fuels),
              content: SizedBox(
                width: double.maxFinite,
                height: 250,
                child: ListView(
                  shrinkWrap: true,
                  children: settings.availableFuels.map((fuel) {
                    final selected = tempFuels.contains(fuel);

                    return CheckboxListTile(
                      title: Text(fuel.label(context)),
                      value: selected,
                      onChanged: (value) {
                        setStateDialog(() {
                          if (value == true) {
                            tempFuels.add(fuel);
                          } else {
                            tempFuels.remove(fuel);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(l.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  onPressed: tempFuels.isEmpty
                      ? null
                      : () {
                          settings.setSelectedFuels(tempFuels);
                          Navigator.pop(context);
                        },
                  child: Text(l.ok),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openRadiusDialog(BuildContext context, SettingsProvider settings) {
    final l = AppLocalizations.of(context)!;
    int tempValue = settings.radiusKm;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l.settings_search_radius),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                min: 1,
                max: 10,
                divisions: 9,
                value: tempValue.toDouble(),
                label: "$tempValue km",
                onChanged: (value) {
                  tempValue = value.toInt();
                  (context as Element).markNeedsBuild();
                },
              ),
              Text("$tempValue km"),
            ],
          ),
          actions: [
            TextButton(
              child: Text(l.cancel),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(l.ok),
              onPressed: () {
                settings.setRadius(tempValue);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _openMarkerFuelDialog(BuildContext context, SettingsProvider settings) {
    final l = AppLocalizations.of(context)!;

    FuelType? tempValue = settings.preferredMarkerFuel;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l.settings_marker_fuel),
          content: DropdownButtonFormField<FuelType?>(
            initialValue: tempValue,
            decoration: const InputDecoration(isDense: true),
            items: [
              DropdownMenuItem<FuelType?>(
                value: null,
                child: Text(l.settings_marker_fuel_auto),
              ),
              ...settings.selectedFuels.map(
                (fuel) => DropdownMenuItem<FuelType?>(
                  value: fuel,
                  child: Text(fuel.label(context)),
                ),
              ),
            ],
            onChanged: (value) {
              tempValue = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () {
                settings.setPreferredMarkerFuel(tempValue);
                Navigator.pop(context);
              },
              child: Text(l.ok),
            ),
          ],
        );
      },
    );
  }
}
