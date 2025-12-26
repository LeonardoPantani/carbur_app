import 'package:google_maps_flutter/google_maps_flutter.dart';

List<Map<String, double>> decodePolylineToPoints(String encoded) {
  final List<Map<String, double>> points = [];

  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < encoded.length) {
    int shift = 0;
    int result = 0;
    int b;

    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    final int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;

    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    final int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    points.add({"lat": lat / 1e5, "lng": lng / 1e5});
  }

  return points;
}

LatLngBounds computeBounds(List<LatLng> points) {
  double south = points.first.latitude;
  double north = points.first.latitude;
  double west = points.first.longitude;
  double east = points.first.longitude;

  for (final p in points) {
    if (p.latitude < south) south = p.latitude;
    if (p.latitude > north) north = p.latitude;
    if (p.longitude < west) west = p.longitude;
    if (p.longitude > east) east = p.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(south, west),
    northeast: LatLng(north, east),
  );
}
