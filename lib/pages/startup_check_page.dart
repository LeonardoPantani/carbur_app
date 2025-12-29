import 'dart:io';

import 'package:flutter/material.dart';
import 'package:carbur_app/pages/home_page.dart';

import '../l10n/app_localizations.dart';

class StartupCheckPage extends StatefulWidget {
  const StartupCheckPage({super.key});

  @override
  State<StartupCheckPage> createState() => _StartupCheckPageState();
}

class _StartupCheckPageState extends State<StartupCheckPage> {
  // null = loading, true = connected, false = not connected
  bool? _hasConnection;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _hasConnection = null;
    });

    try {
      final result = await InternetAddress.lookup('carburanti.mise.gov.it');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _hasConnection = true;
        });
      } else {
        setState(() {
          _hasConnection = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _hasConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // checking connection
    if (_hasConnection == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // we are connected to the internet
    if (_hasConnection == true) {
      return const HomePage();
    }

    // we are not connected to the internet
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l.no_connection_title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l.no_connection_description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _checkConnection,
                icon: const Icon(Icons.refresh),
                label: Text(l.button_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
