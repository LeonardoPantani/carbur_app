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
    return RefreshIndicator(
      onRefresh: () => _checkConnection(),
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
