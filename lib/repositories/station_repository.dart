import '../models/station.dart';
import '../models/station_details.dart';
import '../services/fuel_station_service.dart';
import '../services/routing_service.dart';
import '../utils/logger.dart';

const enableAccurateDistances = false;

class StationRepository {
  final FuelStationService _fuelService;
  final RoutingService _routingService;

  StationRepository({
    FuelStationService? fuelService,
    RoutingService? routingService,
  }) : _fuelService = fuelService ?? FuelStationService(),
       _routingService = routingService ?? RoutingService();

  Future<List<Station>> obtainStations({
    required double lat,
    required double lng,
    required int radiusKm,
  }) async {
    List<Station> stations = await _fuelService.fetchStations(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
    );

    // removing stations where lastUpdate is more than 1 month old
    stations = stations.where((s) => s.lastUpdate.isAfter(DateTime.now().subtract(const Duration(days: 30)))).toList();

    // immediately return [] if empty
    if (stations.isEmpty) return [];

    // calculating accurate distances
    if (enableAccurateDistances) {
      final candidates = List<Station>.from(stations)
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      final topCandidates = candidates.take(10).toList();

      logger.i(
        "Calcolo distanze reali per ${topCandidates.length} stazioni...",
      );
      final stopwatch = Stopwatch()..start();

      final futures = topCandidates.map((station) async {
        try {
          final realDistance = await _routingService.fetchDrivingDistanceKm(
            fromLat: lat,
            fromLng: lng,
            toLat: station.latitude,
            toLng: station.longitude,
          );
          station.distanceKm = realDistance;
          return true;
        } catch (e) {
          return false;
        }
      });

      await Future.wait(futures);
      stopwatch.stop();
      logger.i("Distanze calcolate in ${stopwatch.elapsedMilliseconds}ms");
    }
    
    return stations;
  }

  Future<StationDetails> getStationDetails(Station station) {
    return _fuelService.fetchDetails(station);
  }
}
