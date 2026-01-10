import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:carbur_app/pages/home_page.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/location_provider.dart';
import 'search_place_page.dart';

class StartupCheckPage extends StatefulWidget {
  const StartupCheckPage({super.key});

  @override
  State<StartupCheckPage> createState() => _StartupCheckPageState();
}

class _StartupCheckPageState extends State<StartupCheckPage> {
  // null = loading, true = connected, false = not connected
  bool? _hasConnection;
  bool _isCheckingLocation = false;

  @override
  void initState() {
    super.initState();
    _startChecks();
  }

  Future<void> _startChecks() async {
    // Internet check
    await _checkConnection();

    if (_hasConnection == true && mounted) {
      // handling location permission
      await _handleLocationPermission();
    }
  }

  Future<void> _checkConnection() async {
    if (!mounted) return;
    setState(() {
      _hasConnection = null;
    });
    try {
      final result = await InternetAddress.lookup('carburanti.mise.gov.it');
      if (mounted) {
        setState(() {
          _hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        });
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _hasConnection = false;
        });
      }
    }
  }

  Future<void> _handleLocationPermission() async {
    setState(() {
      _isCheckingLocation = true;
    });

    // do we have the permission already
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // we do not have the required permission
      if (mounted) {
        await _showLocationDisclosureDialog(context);
      }
    } else {
      // we already have the permission
      if (mounted) {
        await context.read<LocationProvider>().initializeLocation();
        _goToHome();
      }
    }
  }

  void _goToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  Future<void> _showLocationDisclosureDialog(BuildContext context) async {
    final l = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.location_on_outlined,
          size: 48,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(l.dialog_location_permission_title),
        content: Text(
          l.dialog_location_permission_description,
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            // add manually location
            onPressed: () {
              Navigator.pop(ctx);
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
            // authorize app to use location
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<LocationProvider>().initializeLocation();
              if (mounted) _goToHome();
            },
            child: Text(l.button_continue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // checking connection or location
    if (_hasConnection == null || _isCheckingLocation) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // we are connected to the internet
    if (_hasConnection == true) {
      return const HomePage();
    }

    // we are not connected to the internet
    return RefreshIndicator(
      onRefresh: () => _startChecks(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 96,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.error_title_no_connection,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
