import 'package:carbur_app/pages/plan_route_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../pages/settings_page.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../providers/map_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/station_provider.dart';
import '../services/remote_config_service.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/stations_list_widget.dart';
import 'widgets/stations_map_widget.dart';
import 'widgets/stations_sort_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;

  bool get _showSortMenu => _currentIndex == 1;

  bool get _shouldShowBanner {
    if (!RemoteConfigService.instance.showBottomAd) return false;

    final allowedString =
        RemoteConfigService.instance.bottomBannerAdTabs; // "1,2"
    return allowedString.contains(_currentIndex.toString());
  }

  void _onNavSelected(int index) {
    setState(() => _currentIndex = index);

    // tracking page usage
    String pageName;
    switch (index) {
      case 0:
        pageName = "Mappa";
        break;
      case 1:
        pageName = "Lista";
        break;
      case 2:
        pageName = "Viaggia";
        break;
      default:
        pageName = "Sconosciuto";
    }
    FirebaseAnalytics.instance.logScreenView(
      screenName: pageName,
      screenClass: 'HomePageTab',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _initData() async {
    final loc = context.read<LocationProvider>();
    final settings = context.read<SettingsProvider>();
    final stations = context.read<StationProvider>();

    if (loc.latitude == null || loc.longitude == null) {
      await loc.tryInitializeLocation();
    }

    if (loc.latitude != null && loc.longitude != null && mounted) {
      stations.loadStations(
        lat: loc.latitude!,
        lng: loc.longitude!,
        radiusKm: settings.radiusKm,
        fuels: settings.selectedFuels,
        brands: settings.selectedBrands,
        sort: settings.sort,
      );
    }

    // tracking settings
    final analytics = FirebaseAnalytics.instance;

    // 1 radius
    await analytics.setUserProperty(
      name: 'user_radius_km',
      value: settings.radiusKm.toString(),
    );

    // 2 favorite fuels
    await analytics.setUserProperty(
      name: 'user_fuel_types',
      value: settings.selectedFuels.map((f) => f.name).join(","),
    );

    // 3 preferred order
    await analytics.setUserProperty(
      name: 'user_sort_preference',
      value: settings.sort.toString(),
    );
  }

  void _openSettings() async {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Impostazioni',
      screenClass: 'SettingsPage',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    if (mounted) {
      _initData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // check orientation
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "CarburApp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _buildActions(context),
      ),
      // drawer only in landscape
      drawer: isLandscape ? _buildDrawer(context) : null,
      body: SafeArea(
        right: !isLandscape,
        left: !isLandscape,
        bottom: true,
        top: true,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  StationsMap(),
                  StationsList(),
                  ChangeNotifierProvider(
                    create: (_) => MapProvider(),
                    child: const PlanRoutePage(),
                  ),
                ],
              ),
            ),

            if (_shouldShowBanner) const Center(child: AdBannerWidget()),
          ],
        ),
      ),
      // bottom bar only in portrait
      bottomNavigationBar: isLandscape ? null : _buildBottomBar(context),
    );
  }

  // drawer widget for landscape mode
  Widget _buildDrawer(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.local_gas_station,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                const Text(
                  'CarburApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: Text(l.section_map),
            selected: _currentIndex == 0,
            onTap: () {
              _onNavSelected(0);
              Navigator.pop(context); // close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text(l.section_stations_list),
            selected: _currentIndex == 1,
            onTap: () {
              _onNavSelected(1);
              Navigator.pop(context); // close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions),
            title: Text(l.section_route_planner),
            selected: _currentIndex == 2,
            onTap: () {
              _onNavSelected(2);
              Navigator.pop(context); // close drawer
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFilterActive = favoritesProvider.showFavoritesOnly;
    final l = AppLocalizations.of(context)!;

    return [
      if (_showSortMenu) ...[
        IconButton(
          icon: Icon(
            isFilterActive ? Icons.star : Icons.star_outline,
            color: isFilterActive ? Colors.amber : null,
          ),
          tooltip: isFilterActive
              ? l.favorites_shownearbystations
              : l.favorites_showonlyfavorites,
          onPressed: () => favoritesProvider.toggleFilter(),
        ),
        StationsSortWidget(showNearestOption: !isFilterActive),
      ],
      IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
    ];
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onNavSelected,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: AppLocalizations.of(context)!.section_map,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_gas_station),
          label: AppLocalizations.of(context)!.section_stations_list,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.directions),
          label: AppLocalizations.of(context)!.section_route_planner,
        ),
      ],
    );
  }
}
