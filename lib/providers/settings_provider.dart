import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_type.dart';
import '../models/station.dart';
import '../services/brand_service.dart';

class SettingsProvider extends ChangeNotifier {
  final List<FuelType> availableFuels = FuelType.values;
  List<FuelType> selectedFuels = [FuelType.petrol];
  List<String> selectedBrands = [];
  int radiusKm = 3;
  FuelType preferredMarkerFuel = FuelType.petrol;
  StationSort sort = StationSort.best;

  double _fuelConsumptionL100Km = 7.0; 
  bool _isKmPerLiter = false;
  double get fuelConsumptionL100km => _fuelConsumptionL100Km;
  bool get isKmPerLiter => _isKmPerLiter;
  double get displayConsumption {
    if (_isKmPerLiter) {
      if (_fuelConsumptionL100Km == 0) return 0;
      return 100 / _fuelConsumptionL100Km;
    }
    return _fuelConsumptionL100Km;
  }

  bool _isFirstRun = true;
  bool get isFirstRun => _isFirstRun;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSettings();
    _isInitialized = true;
    notifyListeners();
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

    // loading fuel types
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

    // loading brands
    final storedBrands = prefs.getStringList('selectedBrands') ?? [];
    final allBrands = BrandService.instance.availableBrands;
    
    if (allBrands.isNotEmpty) {
      selectedBrands = storedBrands
          .where((b) => allBrands.contains(b))
          .toList();
    } else {
      selectedBrands = [];
    }

    // loading preferred fuel
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

    // loading radius
    radiusKm = prefs.getInt('radiusKm') ?? radiusKm;

    // loading sorting
    final sortIndex = prefs.getInt('stationSort');
    if (sortIndex != null && sortIndex < StationSort.values.length) {
      sort = StationSort.values[sortIndex];
    }

    // loading fuel consumption
    _fuelConsumptionL100Km = prefs.getDouble('fuel_consumption') ?? 7.0;
    _isKmPerLiter = prefs.getBool('is_km_per_liter') ?? false;
  }

  Future<void> _saveSelectedFuels() async {
    final prefs = await SharedPreferences.getInstance();
    final codes = selectedFuels.map((f) => f.ministerCode).toList();
    await prefs.setStringList(
      'selectedFuels',
      codes.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveSelectedBrands() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedBrands', selectedBrands);
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

  Future<void> saveConsumption(double value) async {
    if (value <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    
    if (_isKmPerLiter) {
      _fuelConsumptionL100Km = 100 / value;
    } else {
      _fuelConsumptionL100Km = value;
    }
    await prefs.setDouble('fuel_consumption', _fuelConsumptionL100Km);
    notifyListeners();
  }

  Future<void> toggleUnit(bool isKmPerL) async {
    _isKmPerLiter = isKmPerL;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_km_per_liter', _isKmPerLiter);
    notifyListeners();
  }

  // public methods
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

  void setSelectedBrands(List<String> newBrands) {
    final oldSet = selectedBrands.toSet();
    final newSet = newBrands.toSet();

    if (oldSet.length == newSet.length && oldSet.containsAll(newSet)) {
      return;
    }

    selectedBrands = List.from(newBrands);
    _saveSelectedBrands();
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