import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/position_provider.dart';
import '../providers/route_planner_provider.dart';
import 'search_place_page.dart';

class PlanRoutePage extends StatefulWidget {
  const PlanRoutePage({super.key});

  @override
  State<PlanRoutePage> createState() => _PlanRoutePageState();
}

class _PlanRoutePageState extends State<PlanRoutePage> {
  GoogleMapController? _mapController;
  final MapType _mapType = MapType.normal;

  static const LatLng _userLocation = LatLng(43.7167, 10.4017);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final pos = context.watch<LocationProvider>();

    if (_mapController != null && pos.latitude != null) {
      final latLng = LatLng(pos.latitude!, pos.longitude!);

      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutePlannerProvider>();

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

                if (provider.startSuggestions.isNotEmpty)
                  _buildSuggestions(
                    provider.startSuggestions,
                    provider.selectStartPlace,
                  ),

                const SizedBox(height: 12),

                _buildLocationField(
                  label: 'Destination',
                  controller: provider.destinationController,
                  useCurrentLocation: provider.useCurrentLocationAsDestination,
                  onToggleCurrentLocation:
                      provider.toggleDestinationCurrentLocation,
                ),

                if (provider.destinationSuggestions.isNotEmpty)
                  _buildSuggestions(
                    provider.destinationSuggestions,
                    provider.selectDestinationPlace,
                  ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: provider.canSearch
                      ? provider.searchFuelStations
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

  Widget _buildSuggestions(
    List<PlaceSuggestion> suggestions,
    ValueChanged<PlaceSuggestion> onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final s = suggestions[index];
          return ListTile(title: Text(s.description), onTap: () => onTap(s));
        },
      ),
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
