import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:carbur_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/fuel_type.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';
import '../services/brand_service.dart';
import '../services/remote_config_service.dart';
import 'search_place_page.dart';

class StartupCheckPage extends StatefulWidget {
  const StartupCheckPage({super.key});

  @override
  State<StartupCheckPage> createState() => _StartupCheckPageState();
}

class _StartupCheckPageState extends State<StartupCheckPage>
    with WidgetsBindingObserver {
  // State variables
  bool _isInitializing = true;
  bool _backgroundTasksSuccess = false;
  String _loadingMessage = "";
  bool _returningFromSettings = false;

  late Future<bool> _backgroundTasksFuture;

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocationProvider>();
    final l = AppLocalizations.of(context)!;

    final textToShow =
        _loadingMessage.isEmpty ? l.startup_check_internet : _loadingMessage;

    // 1 loading state
    if (_isInitializing || locProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                textToShow,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 2 error state
    if (!_backgroundTasksSuccess) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _restart(),
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 96,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.error_title_no_connection,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.error_description_no_connection,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _restart,
                          icon: const Icon(Icons.refresh),
                          label: Text(l.button_retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3 fallback
    return const Scaffold();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _backgroundTasksFuture = _runBackgroundTasks();
      _runUserInteractionFlow();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _returningFromSettings) {
      _returningFromSettings = false;
      _restart();
    }
  }

  Future<void> _restart() async {
    setState(() {
      _isInitializing = true;
      _backgroundTasksSuccess = false;
      _loadingMessage = "";
    });
    _backgroundTasksFuture = _runBackgroundTasks();
    _runUserInteractionFlow();
  }

  // --- THREAD 1: Background Tasks (Internet, Config, Assets) ---
  Future<bool> _runBackgroundTasks() async {
    final l = AppLocalizations.of(context)!;
    try {
      // 1. checking connection
      if (mounted) setState(() => _loadingMessage = l.startup_check_internet);
      final hasConnection = await _checkConnection();
      if (!hasConnection) return false;

      // 2. configuration (API keys)
      if (mounted) setState(() => _loadingMessage = l.startup_check_config);
      await RemoteConfigService.instance.initialize();

      // 3. downloading logos
      if (mounted) setState(() => _loadingMessage = l.startup_check_resources);
      await BrandService.instance.initialize();

      return true;
    } catch (e) {
      if (mounted) setState(() => _loadingMessage = "Error: $e");
      return false;
    }
  }

  Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('carburanti.mise.gov.it');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // --- THREAD 2: User Interaction (Tutorial, Location) ---
  Future<void> _runUserInteractionFlow() async {
    // 1. tutorial
    final prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('is_first_run') ?? true;
    if (isFirstRun && mounted) {
      await _showTutorialDialog(context);
      if (!mounted) return;
      await context.read<SettingsProvider>().completeTutorial();
    }

    // 2. location
    if (mounted) {
      final locProvider = context.read<LocationProvider>();     
      bool success = await locProvider.tryInitializeLocation();

      if (success && mounted) {
        _finalizeStartup();
      } else {
        if (mounted) await _showLocationDisclosureDialog(context);
      }
    }
  }

  // --- SYNC POINT ---
  Future<void> _finalizeStartup() async {
    final l = AppLocalizations.of(context)!;
    
    // waiting for background tasks to complete
    if (mounted) setState(() => _loadingMessage = l.startup_check_ready);
    
    final bgSuccess = await _backgroundTasksFuture;

    if (!mounted) return;

    if (bgSuccess) {
      // all good
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // background fail
      setState(() {
        _isInitializing = false;
        _backgroundTasksSuccess = false;
      });
    }
  }

  // --- Dialogs & Handlers ---
  Future<void> _showTutorialDialog(BuildContext context) async {
    final settingsProvider = context.read<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    List<FuelType> tempSelectedFuels = List.from(
      settingsProvider.selectedFuels,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text("${l.welcome_title} 👋"),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        l.welcome_description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ...settingsProvider.availableFuels.map((fuel) {
                        final isSelected = tempSelectedFuels.contains(fuel);
                        return CheckboxListTile(
                          title: Text(fuel.label(context)),
                          value: isSelected,
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val == true) {
                                tempSelectedFuels.add(fuel);
                              } else {
                                tempSelectedFuels.remove(fuel);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
                actions: [
                  FilledButton(
                    onPressed: tempSelectedFuels.isEmpty
                        ? null
                        : () {
                            settingsProvider.setSelectedFuels(
                              tempSelectedFuels,
                            );
                            Navigator.pop(ctx);
                          },
                    child: Text(l.button_continue),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // dialog continue button logic
  Future<void> _onAuthorizePressed(BuildContext dialogContext) async {
    final locProvider = context.read<LocationProvider>();
    Navigator.pop(dialogContext);
    
    final result = await locProvider.requestPermissionAndFetch();
    
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    switch (result) {
      case LocationResult.success:
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        final controller = messenger.showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: colorScheme.onPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.snackbar_location_permission_yes,
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        );

        await controller.closed;
        if (!mounted) return;
        _finalizeStartup(); // proceed to sync point instead of direct navigation
        break;

      case LocationResult.permanentlyDenied:
        _showOpenSettingsDialog();
        break;

      case LocationResult.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 8),
            content: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.onError),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.error_snackbar_location_permission_no,
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ),
              ],
            ),
          ),
        );
        _showLocationDisclosureDialog(context);
        break;

      case LocationResult.serviceDisabled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 10),
            content: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.onError),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.error_snackbar_gps_turned_off,
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ),
              ],
            ),
          ),
        );
        _showLocationDisclosureDialog(context);
        break;

      case LocationResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 10),
            content: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.onError),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.error_description_unknown,
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ),
              ],
            ),
          ),
        );
        _showLocationDisclosureDialog(context);
        break;
    }
  }

  void _showOpenSettingsDialog() {
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(ctx).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showLocationDisclosureDialog(context);
          });
        },
        child: AlertDialog(
          title: Text(l.error_dialog_title_location_permission_required),
          content: Text(
            l.error_dialog_description_location_permission_required,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showLocationDisclosureDialog(context);
              },
              child: Text(l.button_back),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _returningFromSettings = true;
                Geolocator.openAppSettings();
              },
              child: Text(l.button_opensettings),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLocationDisclosureDialog(BuildContext context) async {
    final l = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: Icon(
            Icons.location_on_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(l.dialog_location_permission_title),
          content: Text(l.dialog_location_permission_description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // manual mode
                context.read<LocationProvider>().startSearchSession();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SearchPlacePage(mode: SearchMode.manualLocation),
                  ),
                );
              },
              child: Text(l.button_add_manually),
            ),
            FilledButton(
              onPressed: () => _onAuthorizePressed(ctx),
              child: Text(l.button_continue),
            ),
          ],
        ),
      ),
    );
  }
}