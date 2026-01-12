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
import '../services/remote_config_service.dart';
import 'search_place_page.dart';

class StartupCheckPage extends StatefulWidget {
  const StartupCheckPage({super.key});

  @override
  State<StartupCheckPage> createState() => _StartupCheckPageState();
}

class _StartupCheckPageState extends State<StartupCheckPage>
    with WidgetsBindingObserver {
  // null = loading, true = connected, false = not connected
  bool? _hasConnection;
  bool _returningFromSettings = false;
  String _loadingMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startChecks();
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
      if (mounted) {
        setState(() => _hasConnection = null);
      }
      _startChecks();
    }
  }

  Future<void> _startChecks() async {
    final l = AppLocalizations.of(context)!;

    try {
      // checking internet connection
      if (mounted) {
        setState(() {
          _loadingMessage = l.startup_check_internet;
        });
      }
      await _checkConnection();

      // executing tutorial to obtain fuel type
      final prefs = await SharedPreferences.getInstance();
      bool isFirstRun = prefs.getBool('is_first_run') ?? true;
      if (isFirstRun && mounted) {
        await _showTutorialDialog(context);
        if (!mounted) return;
        await context.read<SettingsProvider>().completeTutorial();
      }

      // obtaining API keys
      if (mounted) {
        setState(() {
          _loadingMessage = l.startup_check_config;
        });
      }
      await RemoteConfigService.instance.initialize();

      if (_hasConnection == true && mounted) {
        final locProvider = context.read<LocationProvider>();

        // trying to obtain location
        if (mounted) {
          setState(() {
            _loadingMessage = l.startup_check_location;
          });
        }
        bool success = await locProvider.tryInitializeLocation();

        if (success && mounted) {
          setState(() {
            _loadingMessage = l.startup_check_ready;
          });
          _goToHome();
        } else {
          if (mounted) {
            await _showLocationDisclosureDialog(context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingMessage = "Error: $e";
        });
      }
    }
  }

  Future<void> _checkConnection() async {
    if (!mounted) return;
    try {
      final result = await InternetAddress.lookup('carburanti.mise.gov.it');
      if (mounted) {
        setState(() {
          _hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        });
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() => _hasConnection = false);
      }
    }
  }

  Future<void> _showTutorialDialog(BuildContext context) async {
    final settingsProvider = context.read<SettingsProvider>();
    List<FuelType> tempSelectedFuels = List.from(settingsProvider.selectedFuels);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text("${l.welcome_title} 👋"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.welcome_description,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ...FuelType.values.map((fuel) {
                        final isSelected = tempSelectedFuels.contains(fuel);
                        return CheckboxListTile(
                          title: Text(
                            fuel.label(context),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          value: isSelected,
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val == true) {
                                tempSelectedFuels.add(fuel);
                              } else {
                                if (tempSelectedFuels.length > 1) {
                                  tempSelectedFuels.remove(fuel);
                                }
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
                    onPressed: () {
                      settingsProvider.setSelectedFuels(tempSelectedFuels);
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

  void _goToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
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
        _goToHome();
        break;

      case LocationResult.permanentlyDenied:
        _showOpenSettingsDialog();
        break;

      case LocationResult
          .denied: // user clicks on "Continue" and then says "Don't allow" => fuck it
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
          // re-open previous dialog
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

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocationProvider>();

    final l = AppLocalizations.of(context)!;
    final textToShow = _loadingMessage.isEmpty
        ? AppLocalizations.of(context)!.startup_check_internet
        : _loadingMessage;

    if (_hasConnection == null || locProvider.isLoading) {
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

    if (_hasConnection == false) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _startChecks(),
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
                          onPressed: _startChecks,
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

    // should never arrive here
    return const Scaffold();
  }
}
