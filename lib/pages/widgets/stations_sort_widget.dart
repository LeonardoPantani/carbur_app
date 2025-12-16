import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/station_sort.dart';
import '../../providers/settings_provider.dart';
import '../../providers/station_provider.dart';

class StationsSortWidget extends StatelessWidget {
  const StationsSortWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentSort = context.watch<StationProvider>().currentSort;

    return PopupMenuButton<StationSort>(
      icon: const Icon(Icons.sort),
      onSelected: (sort) {
        context.read<SettingsProvider>().setSort(sort);
        context.read<StationProvider>().setSorting(sort);
      },
      itemBuilder: (context) => [
        _item(
          context,
          StationSort.best,
          currentSort,
          Icons.recommend,
          AppLocalizations.of(context)!.sort_best,
        ),
        _item(
          context,
          StationSort.price,
          currentSort,
          Icons.euro,
          AppLocalizations.of(context)!.sort_cheaper,
        ),
        _item(
          context,
          StationSort.distance,
          currentSort,
          Icons.place,
          AppLocalizations.of(context)!.sort_nearest,
        ),
        _item(
          context,
          StationSort.updatedAt,
          currentSort,
          Icons.update,
          AppLocalizations.of(context)!.sort_lastupdate,
        ),
      ],
    );
  }

  PopupMenuItem<StationSort> _item(
    BuildContext context,
    StationSort sort,
    StationSort current,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<StationSort>(
      value: sort,
      enabled: current != sort,
      child: Row(
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
