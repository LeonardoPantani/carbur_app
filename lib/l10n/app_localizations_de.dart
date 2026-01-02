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
    return 'Aktualisiert am $date um $time';
  }

  @override
  String get section_map => 'Karte';

  @override
  String get section_stations_list => 'Tankstellen';

  @override
  String get section_route_planner => 'Routenplaner';

  @override
  String get start_navigation_question => 'Navigation starten?';

  @override
  String get error => 'Fehler';

  @override
  String get error_description_unknown => 'Unbekannter Fehler.';

  @override
  String get error_description_api_ministry_notworking =>
      'Die Website des Ministeriums für Unternehmen und Made in Italy ist nicht erreichbar.';

  @override
  String get error_description_api_routes_notworking =>
      'Der Routenberechnungsdienst ist nicht verfügbar.';

  @override
  String get facilities_title => 'Serviceleistungen';

  @override
  String get facilities_not_available =>
      'Diese Tankstelle stellt keine Informationen zu ihren Serviceleistungen bereit.';

  @override
  String get facility_food_and_beverage => 'Essen & Getränke';

  @override
  String get facility_car_workshop => 'Autowerkstatt';

  @override
  String get facility_camper_truck_parking => 'Wohnmobil- / Lkw-Parkplatz';

  @override
  String get facility_camper_exhaust => 'Wohnmobil-Entsorgung';

  @override
  String get facility_kids_area => 'Kinderbereich';

  @override
  String get facility_bancomat => 'Geldautomat';

  @override
  String get facility_handicapped_services => 'Barrierefreie Services';

  @override
  String get facility_wifi => 'WLAN';

  @override
  String get facility_tire_dealer => 'Reifenservice';

  @override
  String get facility_car_wash => 'Autowaschanlage';

  @override
  String get facility_electric_charging => 'Ladestation für Elektrofahrzeuge';

  @override
  String get facility_unknown => 'Unbekannter Service';

  @override
  String get phone => 'Telefon';

  @override
  String get email => 'E-Mail';

  @override
  String get website => 'Webseite';

  @override
  String get opening_hours_title => 'Öffnungszeiten';

  @override
  String get opening_hours_note =>
      'Diese Zeiten gelten für den bedienten Service. Selbstbedienung ist immer verfügbar.';

  @override
  String get opening_hours_not_available =>
      'Diese Tankstelle stellt keine Informationen zu den Öffnungszeiten bereit.';

  @override
  String get weekday => 'Tag';

  @override
  String get morning => 'Vormittag';

  @override
  String get afternoon => 'Nachmittag';

  @override
  String get open_24h => '24 Stunden geöffnet';

  @override
  String get back => 'Zurück';

  @override
  String get start_navigation => 'Navigation starten';

  @override
  String get weekday_monday => 'Montag';

  @override
  String get weekday_tuesday => 'Dienstag';

  @override
  String get weekday_wednesday => 'Mittwoch';

  @override
  String get weekday_thursday => 'Donnerstag';

  @override
  String get weekday_friday => 'Freitag';

  @override
  String get weekday_saturday => 'Samstag';

  @override
  String get weekday_sunday => 'Sonntag';

  @override
  String station_identifier(int id) {
    return 'Tankstellenkennung: $id';
  }

  @override
  String get station_details_title => 'Tankstellendetails';

  @override
  String get fuel_prices_title => 'Kraftstoffpreise';

  @override
  String get fuel_prices_not_available => 'Preise nicht verfügbar.';

  @override
  String get settings_marker_fuel => 'Bevorzugter Kraftstofftyp';

  @override
  String get settings_marker_fuel_auto => 'Automatisch';

  @override
  String get settings_marker_fuel_auto_disabledwhy =>
      'Diese Einstellung ist deaktiviert, wenn nur eine Kraftstoffart ausgewählt ist.';

  @override
  String get other_infos_title => 'Weitere Informationen';

  @override
  String get other_infos_notavailable =>
      'Diese Tankstelle bietet keine weiteren Informationen.';

  @override
  String get autocomplete_compliance_google_text =>
      'Autovervollständigungs-Technologie von Google';

  @override
  String get routeplanner_editroute_button => 'Route bearbeiten';

  @override
  String get routeplanner_start_label => 'Startpunkt';

  @override
  String get routeplanner_destination_label => 'Ziel';

  @override
  String get routeplanner_setting_avoidtolls => 'Mautstellen vermeiden';

  @override
  String get routeplanner_reset_button => 'Zurücksetzen';

  @override
  String get routeplanner_search_button => 'Suchen';

  @override
  String get routeplanner_emptylist_placeholder_text =>
      'Tankstellen entlang der Route werden hier angezeigt.';

  @override
  String get routeplanner_toll_switch_desc_text =>
      'Mautstraßen von der Routenberechnung ausschließen.';

  @override
  String get routeplanner_enter_start_placeholder => 'Startpunkt eingeben';

  @override
  String get routeplanner_enter_destination_placeholder => 'Ziel eingeben';

  @override
  String get routeplanner_usingcurrentlocation_text =>
      'Aktueller Standort wird verwendet';

  @override
  String get button_retry => 'Erneut versuchen';

  @override
  String get error_title_no_connection => 'Keine Internetverbindung';

  @override
  String get error_description_no_connection =>
      'Eine aktive Internetverbindung ist erforderlich, um die aktuellen Tankstellenpreise abzurufen.';

  @override
  String get error_description_no_connection_station_details =>
      'Du bist nicht mit dem Internet verbunden, aber du kannst trotzdem zu dieser Tankstelle navigieren.';
}
