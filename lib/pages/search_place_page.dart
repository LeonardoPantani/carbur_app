import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/position_provider.dart';
import '../providers/plan_route_provider.dart';

class SearchPlacePage extends StatelessWidget {
  final bool isStart;

  const SearchPlacePage({super.key, required this.isStart});

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<PlanRouteProvider>();
    final locProvider = context.read<LocationProvider>();
    final l = AppLocalizations.of(context)!;

    final String languageCode = Localizations.localeOf(context).languageCode;

    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final controller = isStart
        ? routeProvider.startController
        : routeProvider.destinationController;

    final suggestions = isStart
        ? routeProvider.startSuggestions
        : routeProvider.destinationSuggestions;

    final onSelect = isStart
        ? routeProvider.selectStartPlace
        : routeProvider.selectDestinationPlace;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isStart ? l.routeplanner_enter_start_placeholder : l.routeplanner_enter_destination_placeholder,
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (isStart) {
              routeProvider.onStartTextChanged(
                value,
                languageCode,
                lat: locProvider.latitude,
                lng: locProvider.longitude,
              );
            } else {
              routeProvider.onDestinationTextChanged(
                value,
                languageCode,
                lat: locProvider.latitude,
                lng: locProvider.longitude,
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final s = suggestions[index];
                return ListTile(
                  leading: Icon(
                    placeTypeToIcon(s.types),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(s.description),
                  onTap: () {
                    onSelect(s);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          if(!isKeyboardVisible)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l.autocomplete_compliance_google_text,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData placeTypeToIcon(List<String> types) {
    for (final type in types) {
      switch (type) {
        case 'airport':
          return Icons.flight;
        case 'train_station':
          return Icons.train;
        case 'subway_station':
          return Icons.subway;
        case 'bus_station':
          return Icons.directions_bus;

        case 'restaurant':
          return Icons.restaurant;
        case 'cafe':
          return Icons.local_cafe;
        case 'bar':
          return Icons.local_bar;

        case 'hospital':
          return Icons.local_hospital;
        case 'pharmacy':
          return Icons.local_pharmacy;

        case 'school':
        case 'university':
          return Icons.school;

        case 'shopping_mall':
        case 'store':
        case 'supermarket':
          return Icons.shopping_cart;

        case 'gas_station':
          return Icons.local_gas_station;
        case 'park':
          return Icons.park;
        case 'lodging':
          return Icons.hotel;

        case 'tourist_attraction':
        case 'museum':
        case 'zoo':
          return Icons.attractions;

        case 'locality':
        case 'political':
        case 'geocode':
          return Icons.location_city;
      }
    }

    return Icons.place;
  }
}
