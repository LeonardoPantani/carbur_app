import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/station_details_provider.dart';
import '../pages/station_details_page.dart';

extension NavigationExtensions on BuildContext {
  void openStationDetails(Station station) {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => StationDetailsProvider(station)..loadDetails(),
          child: const StationDetailsPage(),
        ),
      ),
    );
  }
}