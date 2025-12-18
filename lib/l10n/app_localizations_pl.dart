// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get no_stations_found => 'Nie znaleziono stacji.';

  @override
  String get fuel_petrol => 'Benzyna';

  @override
  String get fuel_diesel => 'Olej napędowy';

  @override
  String get fuel_methane => 'Metan';

  @override
  String get fuel_lpg => 'LPG';

  @override
  String get fuel_lcng => 'LCNG';

  @override
  String get fuel_lng => 'LNG';

  @override
  String get settings_title => 'Ustawienia';

  @override
  String get settings_fuel_types => 'Rodzaje paliwa';

  @override
  String get settings_search_radius => 'Promień wyszukiwania';

  @override
  String get settings_select_fuels => 'Jakie paliwa?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get close => 'Zamknij';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anuluj';

  @override
  String get sort_cheaper => 'Najtańsza';

  @override
  String get sort_nearest => 'Najbliższa';

  @override
  String get sort_lastupdate => 'Ostatnia aktualizacja';

  @override
  String get sort_best => 'Najlepsza';

  @override
  String stations_found(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znaleziono $count stacje paliw w pobliżu.',
      one: 'Znaleziono 1 stację paliw w pobliżu.',
    );
    return '$_temp0';
  }

  @override
  String last_update(Object date, Object time) {
    return '$date o $time';
  }

  @override
  String get section_map => 'Mapa';

  @override
  String get section_stations_list => 'Stacje paliw';

  @override
  String get start_navigation_question => 'Rozpocząć nawigację?';

  @override
  String get error => 'Błąd';

  @override
  String get error_description_unknown => 'Nieznany błąd.';

  @override
  String get error_description_api_ministry_notworking =>
      'Strona Ministerstwa Przedsiębiorstw i Made in Italy jest niedostępna.';

  @override
  String get error_description_api_routes_notworking =>
      'Usługa obliczania tras jest niedostępna.';
}
