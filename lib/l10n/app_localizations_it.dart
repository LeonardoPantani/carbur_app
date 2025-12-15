// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get no_stations_found => 'Nessun distributore trovato.';

  @override
  String get fuel_petrol => 'Benzina';

  @override
  String get fuel_diesel => 'Gasolio';

  @override
  String get fuel_methane => 'Metano';

  @override
  String get fuel_lpg => 'GPL';

  @override
  String get fuel_lcng => 'L-GNC';

  @override
  String get fuel_lng => 'GNL';

  @override
  String get settings_title => 'Impostazioni';

  @override
  String get settings_fuel_types => 'Tipi di carburante';

  @override
  String get settings_search_radius => 'Raggio di ricerca';

  @override
  String get settings_select_fuels => 'Quali carburanti?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get close => 'Chiudi';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annulla';

  @override
  String get sort_cheaper => 'Più economico';

  @override
  String get sort_nearest => 'Più vicino';

  @override
  String get sort_lastupdate => 'Ultimo aggiornamento';

  @override
  String get sort_best => 'Il migliore';

  @override
  String stations_found(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count distributori trovati intorno a te.',
      one: '1 distributore trovato intorno a te.',
    );
    return '$_temp0';
  }

  @override
  String last_update(Object date, Object time) {
    return '$date alle $time';
  }
}
