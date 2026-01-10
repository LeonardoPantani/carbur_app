import 'package:carbur_app/extensions/navigation_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/map_provider.dart';
import '../providers/plan_route_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/logger.dart';
import '../utils/map_utils.dart';
import 'search_place_page.dart';
import 'widgets/common_map.dart';
import 'widgets/station_list_tile.dart';

class PlanRoutePage extends StatefulWidget {
  const PlanRoutePage({super.key});

  @override
  State<PlanRoutePage> createState() => _PlanRoutePageState();
}

class _PlanRoutePageState extends State<PlanRoutePage> {
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool _routeFitted = false;
  bool _isMenuExpanded = true;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  static const LatLng _userLocation = LatLng(43.7167, 10.4017);

  void _triggerRebuild(BuildContext context) {
    final routeProvider = context.read<PlanRouteProvider>();
    final mapProvider = context.read<MapProvider>();
    final settings = context.read<SettingsProvider>();

    if (routeProvider.stationsOnRoute.isNotEmpty) {
      mapProvider.rebuildMarkers(
        stations: routeProvider.stationsOnRoute,
        settings: settings,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
        onStationTap: (s) => context.openStationDetails(s),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeProvider = context.watch<PlanRouteProvider>();
    final mapProvider = context.read<MapProvider>();

    bool justFittedRoute = false;

    // zooming map to fit new route
    if (_mapController != null &&
        routeProvider.routePolylinePoints.isNotEmpty &&
        !_routeFitted) {
      logger.i("Indicazioni modificate. Cambio dello zoom.");
      final bounds = computeBounds(routeProvider.routePolylinePoints);
      _mapController!.moveCamera(CameraUpdate.newLatLngBounds(bounds, 48)).then(
        (_) async {
          final newZoom = await _mapController!.getZoomLevel();
          mapProvider.updateZoom(newZoom);
          if (mounted) {
            _triggerRebuild(context);
          }
        },
      );
      _routeFitted = true;
      justFittedRoute = true;
    }

    // trigger that regenerates markers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (justFittedRoute) return;
      logger.i("[Plan Route] Le dipendenze sono cambiate. Aggiornamento marker richiesto.");
      _triggerRebuild(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<PlanRouteProvider>();
    final mapProvider = context.watch<MapProvider>();
    final String languageCode = Localizations.localeOf(context).languageCode;

    // detecting if we are in landscape or not
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CommonMap(
              initialPosition: _userLocation,
              markers: mapProvider.markers,
              polylines: routeProvider.routePolylinePoints.isEmpty
                  ? {}
                  : {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: routeProvider.routePolylinePoints,
                        width: 5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    },
              onMapCreated: (controller) => _mapController = controller,
              onCameraMove: (position) {
                if (mapProvider.updateZoom(position.zoom)) {
                  logger.i(
                    "Lo zoom della mappa è cambiato molto. Aggiornamento marker richiesto.",
                  );
                  _triggerRebuild(context);
                }
              },
              showMyLocation: true,
            ),
          ),

          // search menu on top
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 12 + (isLandscape ? MediaQuery.of(context).padding.left : 0),
            // in landscape: fixed width at 50%, portrait: right padding
            right: isLandscape ? null : 12,
            width: isLandscape ? (size.width / 2) - 12 : null,
            child: _isMenuExpanded
                ? _buildExpandedCard(
                    routeProvider,
                    mapProvider,
                    languageCode,
                    isLandscape,
                  )
                : _buildCollapsedButton(),
          ),

          _buildDraggableSheet(routeProvider),
        ],
      ),
    );
  }

  Widget _buildCollapsedButton() {
    return Center(
      child: Align(
        alignment: MediaQuery.of(context).orientation == Orientation.landscape
            ? Alignment.topLeft
            : Alignment.center,
        child: ActionChip(
          avatar: const Icon(Icons.edit_location_alt, size: 18),
          label: Text(
            AppLocalizations.of(context)!.routeplanner_editroute_button,
          ),
          onPressed: () {
            setState(() {
              _isMenuExpanded = true;
              if (_sheetController.isAttached) {
                _sheetController.jumpTo(0.05);
              }
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCard(
    PlanRouteProvider routeProvider,
    MapProvider mapProvider,
    String languageCode,
    bool isLandscape,
  ) {
    final height = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;

    // ensures card doesn't overflow screen
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height - padding.top - 50),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // column 1: Input (Start, Swap, Destination)
                      Expanded(
                        flex: 5,
                        child: _buildInputsSection(routeProvider),
                      ),
                      const SizedBox(width: 16),
                      // column 2: actions (Tolls, Reset, Cancel, Search)
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            _buildTollSwitch(routeProvider),
                            const SizedBox(height: 16),
                            _buildActionButtons(
                              routeProvider,
                              mapProvider,
                              languageCode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                // portrait layout (vertical)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInputsSection(routeProvider),
                      const SizedBox(height: 12),
                      _buildTollSwitch(routeProvider),
                      const SizedBox(height: 12),
                      _buildActionButtons(
                        routeProvider,
                        mapProvider,
                        languageCode,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTollSwitch(PlanRouteProvider routeProvider) {
    AppLocalizations l = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            l.routeplanner_setting_avoidtolls,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          height: 30,
          child: Switch(
            value: routeProvider.avoidTolls,
            onChanged: (val) => routeProvider.setAvoidTolls(val),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildInputsSection(PlanRouteProvider routeProvider) {
    AppLocalizations l = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLocationField(
          label: l.routeplanner_start_label,
          controller: routeProvider.startController,
          useCurrentLocation: routeProvider.useCurrentLocationAsStart,
          onToggleCurrentLocation: routeProvider.toggleStartCurrentLocation,
        ),
        // reduce height for swap button
        SizedBox(
          height: 30,
          child: IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.swap_vert),
            onPressed: routeProvider.swapStartAndDestination,
          ),
        ),
        _buildLocationField(
          label: l.routeplanner_destination_label,
          controller: routeProvider.destinationController,
          useCurrentLocation: routeProvider.useCurrentLocationAsDestination,
          onToggleCurrentLocation:
              routeProvider.toggleDestinationCurrentLocation,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    PlanRouteProvider routeProvider,
    MapProvider mapProvider,
    String languageCode,
  ) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildResetButton(routeProvider, mapProvider)),
              const SizedBox(width: 8),
              Expanded(child: _buildCancelButton()),
            ],
          ),
          const SizedBox(height: 4),
          _buildSearchButton(routeProvider, languageCode),
        ],
      );
    }

    // single row (portrait layout)
    return Row(
      children: [
        _buildResetButton(routeProvider, mapProvider),
        const Spacer(),
        _buildCancelButton(),
        const SizedBox(width: 8),
        _buildSearchButton(routeProvider, languageCode),
      ],
    );
  }

  Widget _buildResetButton(
    PlanRouteProvider routeProvider,
    MapProvider mapProvider,
  ) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: () {
        routeProvider.clear();
        mapProvider.clearMarkers();
        setState(() {
          _routeFitted = false;
          if (_sheetController.isAttached) {
            _sheetController.jumpTo(0.05);
          }
        });
      },
      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
      label: Text(
        AppLocalizations.of(context)!.routeplanner_reset_button,
        style: TextStyle(color: Colors.red, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: () => setState(() => _isMenuExpanded = false),
      child: Text(
        AppLocalizations.of(context)!.button_cancel,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildSearchButton(
    PlanRouteProvider routeProvider,
    String languageCode,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: routeProvider.canSearch
          ? () async {
              setState(() {
                _isMenuExpanded = false;
                _routeFitted = false;
              });
              await routeProvider.searchFuelStations(context, languageCode);

              if (_sheetController.isAttached &&
                  routeProvider.stationsOnRoute.isNotEmpty) {
                _sheetController.jumpTo(0.20);
              }
            }
          : null,
      icon: const Icon(Icons.search, size: 20),
      label: Text(
        AppLocalizations.of(context)!.routeplanner_search_button,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDraggableSheet(PlanRouteProvider provider) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.05,
      minChildSize: 0.05,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        final bool isEmpty = provider.stationsOnRoute.isEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: ListView.builder(
            physics: _isMenuExpanded
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount: isEmpty ? 2 : provider.stationsOnRoute.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHandle(context);

              if (isEmpty) {
                return _buildEmptyState(context);
              }

              final station = provider.stationsOnRoute[index - 1];
              return StationTile(station: station, showDistance: false);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(
              context,
            )!.routeplanner_emptylist_placeholder_text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            style: const TextStyle(fontSize: 13), // smaller font
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              isDense: true, // makes text field compact
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              enabled: !useCurrentLocation,
              prefixIcon: Icon(
                useCurrentLocation ? Icons.my_location : Icons.place,
                size: 18,
              ),
            ),
            onTap: useCurrentLocation
                ? null
                : () {
                    context.read<PlanRouteProvider>().startNewSession();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchPlacePage(
                          isStart:
                              label ==
                              AppLocalizations.of(
                                context,
                              )!.routeplanner_start_label,
                        ),
                      ),
                    );
                  },
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onToggleCurrentLocation,
          icon: Icon(
            useCurrentLocation ? Icons.my_location : Icons.location_disabled,
            size: 20,
          ),
        ),
      ],
    );
  }
}
