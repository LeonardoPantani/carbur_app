import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CommonMap extends StatelessWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng initialPosition;
  final Function(GoogleMapController)? onMapCreated;
  final bool showMyLocation;

  const CommonMap({
    super.key,
    required this.markers,
    this.polylines = const {},
    required this.initialPosition,
    this.onMapCreated,
    this.showMyLocation = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return GoogleMap(
      key: ValueKey(brightness),
      style: brightness == Brightness.dark ? _darkMapStyle : _lightMapStyle,
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 14.5),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: showMyLocation,
      myLocationButtonEnabled: showMyLocation,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: onMapCreated,
      mapType: MapType.normal,
    );
  }
}

const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1d1d1d"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d1d1d"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1626"}]
  },
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  }
]
''';

const String _lightMapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  }
]
''';