import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/station_sort.dart';
import '../pages/settings_page.dart';
import '../providers/settings_provider.dart';
import '../providers/station_provider.dart';
import 'widgets/stations_list_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final currentSort = context.watch<StationProvider>().currentSort;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CarburApp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<_SortAction>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              context.read<FuelSettingsProvider>().setSort(sort.sort);
              context.read<StationProvider>().setSorting(sort.sort);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SortAction(StationSort.price),
                enabled: currentSort != StationSort.price,
                child: Row(
                  children: [
                    const Icon(Icons.euro, size: 18),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.sort_cheaper),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _SortAction(StationSort.distance),
                enabled: currentSort != StationSort.distance,
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 18),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.sort_nearest),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _SortAction(StationSort.updatedAt),
                enabled: currentSort != StationSort.updatedAt,
                child: Row(
                  children: [
                    const Icon(Icons.update, size: 18),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.sort_lastupdate),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),

      body: const StationList(),
    );
  }
}

class _SortAction {
  final StationSort sort;
  const _SortAction(this.sort);
}
