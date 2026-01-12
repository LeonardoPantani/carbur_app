import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_type.dart';
import '../models/station.dart';

class SettingsProvider extends ChangeNotifier {
  final List<FuelType> availableFuels = FuelType.values;
  List<FuelType> selectedFuels = [FuelType.petrol];
  int radiusKm = 5;
  FuelType preferredMarkerFuel = FuelType.petrol;
  StationSort sort = StationSort.best;

  bool _isFirstRun = true;
  bool get isFirstRun => _isFirstRun;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', false);
    _isFirstRun = false;
    notifyListeners();
  }

  void _ensureValidPreferredFuel() {
    if (!selectedFuels.contains(preferredMarkerFuel)) {
      preferredMarkerFuel = selectedFuels.first;
      _savePreferredMarkerFuel();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isFirstRun = prefs.getBool('is_first_run') ?? true;

    // loading [selected fuel] preference
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

    // loading [preferred marker fuel] preference
    final preferredCode = prefs.getInt('preferredMarkerFuel');
    if (preferredCode != null) {
      try {
        preferredMarkerFuel = FuelType.values.firstWhere(
          (f) => f.ministerCode == preferredCode,
        );
      } catch (_) {
        preferredMarkerFuel = FuelType.petrol;
      }
    }
    _ensureValidPreferredFuel();

    // loading [radius] preference
    radiusKm = prefs.getInt('radiusKm') ?? radiusKm;

    // loading [sorting] preference (editable in the fuel stations page only)
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
    await prefs.setInt('preferredMarkerFuel', preferredMarkerFuel.ministerCode);
  }

  // ---- public methods
  void toggleFuel(FuelType fuel) {
    final isSelected = selectedFuels.contains(fuel);

    if (isSelected) {
      selectedFuels.remove(fuel);
    } else {
      selectedFuels.add(fuel);
    }

    _saveSelectedFuels();
    _ensureValidPreferredFuel();
    notifyListeners();
  }

  void setSelectedFuels(List<FuelType> newFuels) {
    final oldSet = selectedFuels.toSet();
    final newSet = newFuels.toSet();

    if (oldSet.length == newSet.length && oldSet.containsAll(newSet)) {
      return;
    }

    selectedFuels = List.from(newFuels);
    _saveSelectedFuels();
    _ensureValidPreferredFuel();
    notifyListeners();
  }

  void setRadius(int km) {
    if (km == radiusKm) return;
    radiusKm = km;
    _saveRadius();
    notifyListeners();
  }

  void setSort(StationSort newSort) {
    if (newSort == sort) return;
    sort = newSort;
    _saveSort();
    notifyListeners();
  }

  void setPreferredMarkerFuel(FuelType fuel) {
    if (!selectedFuels.contains(fuel)) return;
    if (preferredMarkerFuel == fuel) return;

    preferredMarkerFuel = fuel;
    _savePreferredMarkerFuel();
    notifyListeners();
  }
}
