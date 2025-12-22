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
  String get fuel_diesel => 'Diesel';

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

  @override
  String get facilities_title => 'Usługi';

  @override
  String get facilities_not_available =>
      'Ta stacja paliw nie udostępnia informacji o dostępnych usługach.';

  @override
  String get facility_food_and_beverage => 'Jedzenie i napoje';

  @override
  String get facility_car_workshop => 'Warsztat samochodowy';

  @override
  String get facility_camper_truck_parking =>
      'Parking dla kamperów / ciężarówek';

  @override
  String get facility_camper_exhaust => 'Zrzut nieczystości z kampera';

  @override
  String get facility_kids_area => 'Strefa dla dzieci';

  @override
  String get facility_bancomat => 'Bankomat';

  @override
  String get facility_handicapped_services =>
      'Udogodnienia dla osób z niepełnosprawnościami';

  @override
  String get facility_wifi => 'Wi-Fi';

  @override
  String get facility_tire_dealer => 'Serwis opon';

  @override
  String get facility_car_wash => 'Myjnia samochodowa';

  @override
  String get facility_electric_charging => 'Ładowanie elektryczne';

  @override
  String get facility_unknown => 'Nieznana usługa';

  @override
  String get phone => 'Telefon';

  @override
  String get email => 'E-mail';

  @override
  String get website => 'Strona internetowa';

  @override
  String get opening_hours_title => 'Godziny otwarcia';

  @override
  String get opening_hours_note =>
      'Te godziny dotyczą obsługi z personelem. Samoobsługa jest zawsze dostępna.';

  @override
  String get opening_hours_not_available =>
      'Ta stacja paliw nie udostępnia informacji o godzinach otwarcia.';

  @override
  String get weekday => 'Dzień';

  @override
  String get morning => 'Rano';

  @override
  String get afternoon => 'Popołudnie';

  @override
  String get open_24h => 'Otwarte 24 h';

  @override
  String get back => 'Wstecz';

  @override
  String get start_navigation => 'Rozpocznij nawigację';

  @override
  String get weekday_monday => 'Poniedziałek';

  @override
  String get weekday_tuesday => 'Wtorek';

  @override
  String get weekday_wednesday => 'Środa';

  @override
  String get weekday_thursday => 'Czwartek';

  @override
  String get weekday_friday => 'Piątek';

  @override
  String get weekday_saturday => 'Sobota';

  @override
  String get weekday_sunday => 'Niedziela';

  @override
  String station_identifier(int id) {
    return 'Identyfikator stacji paliw: $id';
  }

  @override
  String get station_details_title => 'Szczegóły stacji paliw';

  @override
  String get fuel_prices_title => 'Ceny paliw';

  @override
  String get fuel_prices_not_available => 'Ceny niedostępne.';

  @override
  String get settings_marker_fuel => 'Preferowany rodzaj paliwa';

  @override
  String get settings_marker_fuel_auto => 'Automatycznie';

  @override
  String get settings_marker_fuel_auto_disabledwhy =>
      'To ustawienie jest niedostępne, gdy wybrany jest tylko jeden rodzaj paliwa.';
}
