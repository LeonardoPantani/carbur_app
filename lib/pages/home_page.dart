import 'package:carbur_app/pages/plan_route_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../pages/settings_page.dart';
import '../providers/map_provider.dart';
import 'widgets/stations_list_widget.dart';
import 'widgets/stations_map_widget.dart';
import 'widgets/stations_sort_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  bool get _showSortMenu => _currentIndex == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "CarburApp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _buildActions(context),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StationsMap(),
          StationsList(),
          ChangeNotifierProvider(
            create: (_) => MapProvider(), // this MapProvider is separated from the first one.
            child: const PlanRoutePage(), // this beacause PlanRoutePage must have another map with no markers
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      if (_showSortMenu) const StationsSortWidget(), // stations sort only when list is selected
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
      ),
    ];
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: AppLocalizations.of(context)!.section_map,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_gas_station),
          label: AppLocalizations.of(context)!.section_stations_list,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.directions),
          label: AppLocalizations.of(context)!.section_route_planner,
        ),
      ],
    );
  }
}
