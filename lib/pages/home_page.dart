import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../pages/settings_page.dart';
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
        title: const Text(
          "CarburApp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _buildActions(context),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          StationsMap(),
          StationList(),
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
      ],
    );
  }
}
