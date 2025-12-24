import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/position_provider.dart';
import '../providers/route_planner_provider.dart';

class SearchPlacePage extends StatelessWidget {
  final bool isStart;

  const SearchPlacePage({
    super.key,
    required this.isStart,
  });

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RoutePlannerProvider>();
    final locProvider = context.read<LocationProvider>();
    
    final String languageCode = Localizations.localeOf(context).languageCode;

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
          decoration: const InputDecoration(
            hintText: 'Search address',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (isStart) {
              routeProvider.onStartTextChanged(value, languageCode, lat: locProvider.latitude, lng: locProvider.longitude);
            } else {
              routeProvider.onDestinationTextChanged(value, languageCode, lat: locProvider.latitude, lng: locProvider.longitude);
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final s = suggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(s.description),
            onTap: () {
              onSelect(s);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}