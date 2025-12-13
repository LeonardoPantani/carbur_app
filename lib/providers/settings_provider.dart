import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_type.dart';
import '../models/station_sort.dart';

class FuelSettingsProvider extends ChangeNotifier {
  final List<FuelType> availableFuels = FuelType.values;

  List<FuelType> selectedFuels = [FuelType.petrol];
  int radiusKm = 5;
  StationSort sort = StationSort.price;

  bool configurationChanged = false;

  FuelSettingsProvider() {
    _loadSettings();
  }

  void _markChanged() {
    configurationChanged = true;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final stored = prefs.getStringList('selectedFuels');

    if (stored != null) {
      selectedFuels = stored.map((value) {
        final numeric = int.tryParse(value);
        return FuelType.values.firstWhere(
          (f) => f.ministerCode == numeric,
          orElse: () => FuelType.petrol,
        );
      }).toList();
    } else {
      selectedFuels = [FuelType.petrol];
    }

    radiusKm = prefs.getInt('radiusKm') ?? 10;

    final sortIndex = prefs.getInt('stationSort');
    if (sortIndex != null) {
      sort = StationSort.values[sortIndex];
    }

    notifyListeners();
  }

  Future<void> _saveSelectedFuels() async {
    final prefs = await SharedPreferences.getInstance();
    final codes = selectedFuels.map((f) => f.ministerCode).toList();
    await prefs.setStringList(
      'selectedFuels',
      codes.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveRadius() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('radiusKm', radiusKm);
  }

  Future<void> _saveSort() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stationSort', sort.index);
  }

  void setSort(StationSort newSort) {
    sort = newSort;
    _saveSort();
    notifyListeners();
  }

  void toggleFuel(FuelType fuel) {
    final isSelected = selectedFuels.contains(fuel);

    if (isSelected) {
      selectedFuels.remove(fuel);
    } else {
      selectedFuels.add(fuel);
    }

    _saveSelectedFuels();
    _markChanged();
  }

  void updateRadius(int km) {
    radiusKm = km;
    _saveRadius();
    _markChanged();
  }

  void setSelectedFuels(List<FuelType> newFuels) {
    selectedFuels = List.from(newFuels);
    _saveSelectedFuels();
    _markChanged();
  }
}
