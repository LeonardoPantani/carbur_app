import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fuel_type.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

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
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openFuelSelectionDialog(context, settings),
                ),

                ListTile(
                  title: Text(l.settings_search_radius),
                  subtitle: Text("${settings.radiusKm} km"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openRadiusDialog(context, settings),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse("https://github.com/LeonardoPantani");
                await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                height: 350,
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
}
