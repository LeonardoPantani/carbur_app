import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/location_provider.dart';
import '../providers/plan_route_provider.dart';
import '../services/google_places_service.dart';
import 'home_page.dart';

enum SearchMode { start, destination, manualLocation }

class SearchPlacePage extends StatelessWidget {
  final SearchMode mode;

  const SearchPlacePage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<PlanRouteProvider>();
    final locProvider = context.watch<LocationProvider>();
    final l = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;

    TextEditingController controller;
    List<PlaceSuggestion> suggestions;
    Function(String) onChanged;
    Function(PlaceSuggestion) onSelect;
    VoidCallback onClear;
    String hintText;

    switch (mode) {
      case SearchMode.start:
        controller = routeProvider.startController;
        suggestions = routeProvider.startSuggestions;
        onChanged = (val) => routeProvider.onStartTextChanged(
          val,
          languageCode,
          lat: locProvider.latitude,
          lng: locProvider.longitude,
        );
        onSelect = (s) {
          routeProvider.selectStartPlace(s);
          Navigator.pop(context);
        };
        onClear = () => routeProvider.onStartTextChanged('', languageCode);
        hintText = l.routeplanner_enter_start_placeholder;
        break;
      case SearchMode.destination:
        controller = routeProvider.destinationController;
        suggestions = routeProvider.destinationSuggestions;
        onChanged = (val) => routeProvider.onDestinationTextChanged(
          val,
          languageCode,
          lat: locProvider.latitude,
          lng: locProvider.longitude,
        );
        onSelect = (s) {
          routeProvider.selectDestinationPlace(s);
          Navigator.pop(context);
        };
        onClear = () =>
            routeProvider.onDestinationTextChanged('', languageCode);
        hintText = l.routeplanner_enter_destination_placeholder;
        break;
      case SearchMode.manualLocation:
        controller = locProvider.searchController;
        suggestions = locProvider.searchSuggestions;
        onChanged = (val) => locProvider.onSearchTextChanged(val, languageCode);
        onSelect = (s) async {
          await locProvider.selectPlace(s);

          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          }
        };

        onClear = () => locProvider.onSearchTextChanged('', languageCode);
        hintText = l.enter_address_placeholder;
        break;
    }

    final savedPlaces = locProvider.savedPlaces;
    final showSavedPlaces = controller.text.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onClear();
                    },
                  )
                : null,
          ),
          onChanged: onChanged,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: showSavedPlaces && savedPlaces.isNotEmpty
                  ? _buildSavedPlacesList(
                      context,
                      savedPlaces,
                      onSelect,
                      locProvider,
                    )
                  : _buildSuggestionsList(
                      context,
                      suggestions,
                      onSelect,
                      locProvider,
                    ),
            ),
            _buildGoogleFooter(context, l),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPlacesList(
    BuildContext context,
    List<PlaceSuggestion> places,
    Function(PlaceSuggestion) onSelect,
    LocationProvider locProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            AppLocalizations.of(context)!.saved_places,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final s = places[index];
              return ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.orange),
                title: Text(s.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,),
                  tooltip: AppLocalizations.of(context)!.button_tooltip_remove_places_from_saved,
                  onPressed: () => locProvider.toggleSavedPlace(s),
                ),
                onTap: () => onSelect(s),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    List<PlaceSuggestion> suggestions,
    Function(PlaceSuggestion) onSelect,
    LocationProvider locProvider,
  ) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final s = suggestions[index];
        final isSaved = locProvider.isPlaceSaved(s.placeId);

        return ListTile(
          leading: Icon(placeTypeToIcon(s.types)),
          title: Text(s.description),
          trailing: IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.orange : null,
            ),
            onPressed: () => locProvider.toggleSavedPlace(s),
          ),
          onTap: () => onSelect(s),
        );
      },
    );
  }

  Widget _buildGoogleFooter(BuildContext context, AppLocalizations l) {
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        l.autocomplete_compliance_google_text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.secondary,
        ),
        textAlign: TextAlign.center,
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
