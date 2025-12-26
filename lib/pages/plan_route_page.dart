import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/route_planner_provider.dart';
import '../utils/utils.dart';
import 'search_place_page.dart';

class PlanRoutePage extends StatefulWidget {
  const PlanRoutePage({super.key});

  @override
  State<PlanRoutePage> createState() => _PlanRoutePageState();
}

class _PlanRoutePageState extends State<PlanRoutePage> {
  GoogleMapController? _mapController;
  final MapType _mapType = MapType.normal;
  bool _routeFitted = false;

  static const LatLng _userLocation = LatLng(43.7167, 10.4017);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.watch<RoutePlannerProvider>();

    if (_mapController != null &&
        provider.routePolylinePoints.isNotEmpty &&
        !_routeFitted) {
      final bounds = computeBounds(provider.routePolylinePoints);

      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));

      _routeFitted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutePlannerProvider>();
    final String languageCode = Localizations.localeOf(context).languageCode;

    final brightness = Theme.of(context).brightness;
    final mapStyle = brightness == Brightness.dark
        ? _darkMapStyle
        : _lightMapStyle;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            width: double.infinity,
            child: GoogleMap(
              key: ValueKey(brightness),
              style: mapStyle,
              initialCameraPosition: const CameraPosition(
                target: _userLocation,
                zoom: 14,
              ),
              mapType: _mapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              polylines: provider.routePolylinePoints.isEmpty
                  ? {}
                  : {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: provider.routePolylinePoints,
                        width: 4,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLocationField(
                  label: 'Start point',
                  controller: provider.startController,
                  useCurrentLocation: provider.useCurrentLocationAsStart,
                  onToggleCurrentLocation: provider.toggleStartCurrentLocation,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      tooltip: 'Swap start and destination',
                      icon: const Icon(Icons.swap_vert),
                      onPressed: provider.swapStartAndDestination,
                    ),
                  ],
                ),

                _buildLocationField(
                  label: 'Destination',
                  controller: provider.destinationController,
                  useCurrentLocation: provider.useCurrentLocationAsDestination,
                  onToggleCurrentLocation:
                      provider.toggleDestinationCurrentLocation,
                ),

                const SizedBox(height: 6),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Avoid tolls'),
                  value: provider.avoidTolls,
                  onChanged: provider.setAvoidTolls,
                ),

                const SizedBox(height: 6),

                ElevatedButton.icon(
                  onPressed: provider.canSearch
                      ? () {
                          setState(() {
                            _routeFitted = false;
                          });
                          provider.searchFuelStations(context, languageCode);
                        }
                      : null,
                  icon: const Icon(Icons.local_gas_station),
                  label: const Text(
                    'Search fuel stations',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required TextEditingController controller,
    required bool useCurrentLocation,
    required VoidCallback onToggleCurrentLocation,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              enabled: !useCurrentLocation,
              prefixIcon: Icon(
                useCurrentLocation ? Icons.my_location : Icons.place,
              ),
            ),
            onTap: useCurrentLocation
                ? null
                : () {
                    context.read<RoutePlannerProvider>().startNewSession();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SearchPlacePage(isStart: label == 'Start point'),
                      ),
                    );
                  },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onToggleCurrentLocation,
          icon: Icon(
            useCurrentLocation ? Icons.my_location : Icons.location_disabled,
          ),
        ),
      ],
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
