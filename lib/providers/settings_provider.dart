import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_type.dart';
import '../models/station_sort.dart';

class SettingsProvider extends ChangeNotifier {
  final List<FuelType> availableFuels = FuelType.values;

  List<FuelType> selectedFuels = [FuelType.petrol];
  int radiusKm = 3;
  StationSort sort = StationSort.best;
  FuelType? preferredMarkerFuel;

  bool configurationChanged = false;

  SettingsProvider() {
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

    final preferredCode = prefs.getInt('preferredMarkerFuel');
    if (preferredCode != null) {
      final found = selectedFuels.where((f) => f.ministerCode == preferredCode);
      preferredMarkerFuel = found.isNotEmpty ? found.first : null;
    }

    radiusKm = prefs.getInt('radiusKm') ?? radiusKm;

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

  Future<void> _savePreferredMarkerFuel() async {
    final prefs = await SharedPreferences.getInstance();

    if (preferredMarkerFuel == null) {
      await prefs.remove('preferredMarkerFuel');
    } else {
      await prefs.setInt(
        'preferredMarkerFuel',
        preferredMarkerFuel!.ministerCode,
      );
    }
  }

  void toggleFuel(FuelType fuel) {
    final isSelected = selectedFuels.contains(fuel);

    if (isSelected) {
      selectedFuels.remove(fuel);
    } else {
      selectedFuels.add(fuel);
    }

    if (preferredMarkerFuel != null &&
        !selectedFuels.contains(preferredMarkerFuel)) {
      preferredMarkerFuel =
          selectedFuels.isNotEmpty ? selectedFuels.first : null;
      _savePreferredMarkerFuel();
    }

    _saveSelectedFuels();
    _markChanged();
  }

  void setSelectedFuels(List<FuelType> newFuels) {
    final oldSet = selectedFuels.toSet();
    final newSet = newFuels.toSet();

    if (oldSet.length == newSet.length && oldSet.containsAll(newSet)) {
      return;
    }

    selectedFuels = List.from(newFuels);
    if (preferredMarkerFuel != null &&
        !selectedFuels.contains(preferredMarkerFuel)) {
      preferredMarkerFuel = selectedFuels.isNotEmpty
          ? selectedFuels.first
          : null;
      _savePreferredMarkerFuel();
    }
    _saveSelectedFuels();
    _markChanged();
  }

  void setRadius(int km) {
    if (km == radiusKm) return;

    radiusKm = km;
    _saveRadius();
    _markChanged();
  }

  void setSort(StationSort newSort) {
    if (newSort == sort) return;

    sort = newSort;
    _saveSort();
    _markChanged();
  }

  void setPreferredMarkerFuel(FuelType? fuel) {
    if (fuel != null && !selectedFuels.contains(fuel)) return;

    if (preferredMarkerFuel == fuel) return;

    preferredMarkerFuel = fuel;
    _savePreferredMarkerFuel();
    _markChanged();
  }
}
