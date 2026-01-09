import 'package:flutter/widgets.dart';
import '../exceptions/custom_exceptions.dart';
import '../models/station.dart';
import '../models/station_details.dart';
import '../services/fuel_station_service.dart';
import 'station_provider.dart';

class StationDetailsProvider extends ChangeNotifier {
  final Station station;
  final FuelStationService _service = FuelStationService();

  static final Map<int, StationDetails> _memoryCache = {};
  bool _isDisposed = false;

  StationDetails? details;
  bool isLoading = false;
  StationError? error;

  StationDetailsProvider(this.station);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadDetails() async {
    error = null;
    // looking for data in cache
    if (_memoryCache.containsKey(station.id)) {
      details = _memoryCache[station.id];
      isLoading = false;
      notifyListeners();
    } else {
      // we load them if we do not have details in cache
      isLoading = true;
      notifyListeners();
    }

    try {
      // trying to obtain new details
      final freshDetails = await _service.fetchDetails(station);

      if (_isDisposed) return;

      // if i am able (internet working & minister website working)
      _memoryCache[station.id] = freshDetails;
      details = freshDetails;
    } catch (e) {
      if (_isDisposed) return;
      
      // if we do not have any details saved we show the error, otherwise we show them from cache
      if (details == null) {
        error = _mapExceptionToError(e);
      }
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  StationError _mapExceptionToError(Object e) {
    if (e is ApiException || e is ApiTimeoutException) {
      return StationError.ministry;
    }
    if (e is NetworkException) {
      return StationError.network;
    }
    return StationError.unknown;
  }
}
