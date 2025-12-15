// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get no_stations_found => 'Keine Tankstellen gefunden.';

  @override
  String get fuel_petrol => 'Benzin';

  @override
  String get fuel_diesel => 'Diesel';

  @override
  String get fuel_methane => 'Methan';

  @override
  String get fuel_lpg => 'Autogas';

  @override
  String get fuel_lcng => 'LCNG';

  @override
  String get fuel_lng => 'LNG';

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_fuel_types => 'Kraftstoffarten';

  @override
  String get settings_search_radius => 'Suchradius';

  @override
  String get settings_select_fuels => 'Welche Kraftstoffe?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get close => 'Schließen';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get sort_cheaper => 'Günstigste';

  @override
  String get sort_nearest => 'Nächste';

  @override
  String get sort_lastupdate => 'Letzte Aktualisierung';

  @override
  String get sort_best => 'Beste';

  @override
  String stations_found(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tankstellen in deiner Nähe gefunden.',
      one: '1 Tankstelle in deiner Nähe gefunden.',
    );
    return '$_temp0';
  }

  @override
  String last_update(Object date, Object time) {
    return '$date um $time';
  }

  @override
  String get section_map => 'Karte';

  @override
  String get section_stations_list => 'Tankstellen';

  @override
  String get start_navigation_question => 'Navigation starten?';
}
