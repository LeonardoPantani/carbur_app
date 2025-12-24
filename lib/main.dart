import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/position_provider.dart';
import 'providers/route_planner_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/station_provider.dart';

import 'pages/home_page.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => RoutePlannerProvider(),
        ),
        ChangeNotifierProxyProvider2<
          LocationProvider,
          SettingsProvider,
          StationProvider
        >(
          create: (_) => StationProvider(),
          update: (_, pos, settings, stationProvider) {
            stationProvider!.updateDependencies(pos, settings);
            return stationProvider;
          },
        ),
      ],
      child: const CarburApp(),
    ),
  );
}

class CarburApp extends StatelessWidget {
  const CarburApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarburApp',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('it'),
        Locale('pl'),
        Locale('pt'),
      ],
      home: const HomePage(),
    );
  }
}
