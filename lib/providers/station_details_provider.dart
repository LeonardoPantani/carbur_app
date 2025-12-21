import 'package:flutter/widgets.dart';

import '../exceptions/custom_exceptions.dart';
import '../models/station.dart';

import '../models/station_details.dart';
import '../services/station_service.dart';
import 'station_provider.dart';

class StationDetailsProvider extends ChangeNotifier {
  final Station station;
  final StationService _service = StationService();

  StationDetails? details;
  bool isLoading = false;
  StationError? error;

  StationDetailsProvider(this.station);

  Future<void> loadDetails() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      details = await _service.fetchDetails(station);
    } catch (e) {
      error = _mapExceptionToError(e);
    }

    isLoading = false;
    notifyListeners();
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
