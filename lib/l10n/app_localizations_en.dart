// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get no_stations_found => 'No stations found.';

  @override
  String get fuel_petrol => 'Petrol';

  @override
  String get fuel_diesel => 'Diesel';

  @override
  String get fuel_methane => 'Methane';

  @override
  String get fuel_lpg => 'LPG';

  @override
  String get fuel_lcng => 'LCNG';

  @override
  String get fuel_lng => 'LNG';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_fuel_types => 'Fuel types';

  @override
  String get settings_search_radius => 'Search radius';

  @override
  String get settings_select_fuels => 'Which fuels?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get sort_cheaper => 'Cheapest';

  @override
  String get sort_nearest => 'Nearest';

  @override
  String get sort_lastupdate => 'Last Update';

  @override
  String get sort_best => 'Best';

  @override
  String last_update(Object date, Object time) {
    return '$date at $time';
  }
}
