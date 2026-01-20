import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fuel_type.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/brand_service.dart';
import '../utils/hyperlink_utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings_title)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l.settings_category_general,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

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
                    title: Text(l.settings_filter_brands),
                    subtitle: Text(
                      BrandService.instance.availableBrands.isEmpty
                          ? l.settings_setting_unavailable
                          : settings.selectedBrands.isEmpty
                          ? l.settings_brands_all_selected
                          : l.settings_brands_selected(
                              settings.selectedBrands.length,
                            ),
                    ),
                    enabled: BrandService.instance.availableBrands.isNotEmpty,
                    leading: const Icon(Icons.store),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: BrandService.instance.availableBrands.isNotEmpty ? () => _openBrandSelectionDialog(context, settings) : null,
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
                    subtitle: Text(settings.preferredMarkerFuel.label(context)),
                    leading: const Icon(Icons.price_check),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: settings.selectedFuels.length > 1,
                    onTap: settings.selectedFuels.length > 1
                        ? () => _openMarkerFuelDialog(context, settings)
                        : null,
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l.settings_category_legal,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  ListTile(
                    title: const Text("Privacy Policy"),
                    leading: const Icon(Icons.privacy_tip_outlined),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      openWebsite(
                        "https://www.iubenda.com/privacy-policy/53116542",
                      );
                    },
                  ),

                  ListTile(
                    title: Text(l.settings_contact_us),
                    subtitle: Text(l.settings_contact_us_subtitle),
                    leading: const Icon(Icons.mail_outline),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      openEmail(
                        'leopantaa+feedbacks@protonmail.com',
                        subject: 'USER FEEDBACK',
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
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
                  child: Text(l.button_cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  onPressed: tempFuels.isEmpty
                      ? null
                      : () {
                          settings.setSelectedFuels(tempFuels);
                          Navigator.pop(context);
                        },
                  child: Text(l.button_ok),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openBrandSelectionDialog(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final l = AppLocalizations.of(context)!;
    final allBrands = BrandService.instance.availableBrands;
    final initialSelectedSet = settings.selectedBrands.toSet();

    // sorted list
    final sortedAllBrands = List<String>.from(allBrands)
      ..sort((a, b) {
        final aSelected = initialSelectedSet.contains(a);
        final bSelected = initialSelectedSet.contains(b);

        // prioritize the selected element
        if (aSelected && !bSelected) return -1;
        if (!aSelected && bSelected) return 1;

        // otherwise sort alphabetically
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    List<String> tempSelected = List.from(settings.selectedBrands);
    List<String> filteredBrands = List.from(sortedAllBrands);
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void onSearchChanged(String query) {
              setStateDialog(() {
                if (query.isEmpty) {
                  filteredBrands = List.from(allBrands);
                } else {
                  filteredBrands = allBrands
                      .where(
                        (b) => b.toLowerCase().contains(query.toLowerCase()),
                      )
                      .toList();
                }
              });
            }

            return AlertDialog(
              title: Text(l.settings_select_brands_dialog_title),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: l.search_brands_placeholder,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                      ),
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredBrands.length,
                        itemBuilder: (context, index) {
                          final brand = filteredBrands[index];
                          final isSelected = tempSelected.contains(brand);

                          return CheckboxListTile(
                            title: Text(
                              brand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: isSelected,
                            onChanged: (bool? checked) {
                              setStateDialog(() {
                                if (checked == true) {
                                  tempSelected.add(brand);
                                } else {
                                  tempSelected.remove(brand);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(l.button_cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text(l.button_ok),
                  onPressed: () {
                    settings.setSelectedBrands(tempSelected);
                    Navigator.pop(context);
                  },
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
              child: Text(l.button_cancel),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(l.button_ok),
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
              child: Text(l.button_cancel),
            ),
            TextButton(
              onPressed: () {
                settings.setPreferredMarkerFuel(tempValue!);
                Navigator.pop(context);
              },
              child: Text(l.button_ok),
            ),
          ],
        );
      },
    );
  }
}
