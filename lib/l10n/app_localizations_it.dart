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
    return 'Aggiornato il $date alle $time';
  }

  @override
  String get section_map => 'Mappa';

  @override
  String get section_stations_list => 'Distributori';

  @override
  String get section_route_planner => 'Pianifica viaggio';

  @override
  String get start_navigation_question => 'Avviare navigazione?';

  @override
  String get error => 'Errore';

  @override
  String get error_description_unknown => 'Errore sconosciuto.';

  @override
  String get error_description_api_ministry_notworking =>
      'Il sito del Ministero delle Imprese e del Made in Italy non è disponibile.';

  @override
  String get error_description_api_routes_notworking =>
      'Il servizio di calcolo dei percorsi non è disponibile.';

  @override
  String get facilities_title => 'Servizi';

  @override
  String get facilities_not_available =>
      'Questo distributore non fornisce info sui servizi che offre.';

  @override
  String get facility_food_and_beverage => 'Cibo e bevande';

  @override
  String get facility_car_workshop => 'Officina';

  @override
  String get facility_camper_truck_parking => 'Parcheggio per camper e camion';

  @override
  String get facility_camper_exhaust => 'Scarico per camper';

  @override
  String get facility_kids_area => 'Area bambini';

  @override
  String get facility_bancomat => 'Bancomat';

  @override
  String get facility_handicapped_services => 'Servizi per disabili';

  @override
  String get facility_wifi => 'Wi-Fi';

  @override
  String get facility_tire_dealer => 'Gommista';

  @override
  String get facility_car_wash => 'Autolavaggio';

  @override
  String get facility_electric_charging => 'Colonnine elettriche di ricarica';

  @override
  String get facility_unknown => 'Servizio sconosciuto';

  @override
  String get phone => 'Telefono';

  @override
  String get email => 'Email';

  @override
  String get website => 'Sito web';

  @override
  String get opening_hours_title => 'Orari di apertura';

  @override
  String get opening_hours_note =>
      'Questi orari di apertura si riferiscono al servito. È sempre possibile fare rifornimento self-service.';

  @override
  String get opening_hours_not_available =>
      'Questo distributore non fornisce i propri orari di apertura.';

  @override
  String get weekday => 'Giorno';

  @override
  String get morning => 'Mattina';

  @override
  String get afternoon => 'Pomeriggio';

  @override
  String get open_24h => 'Aperto H24';

  @override
  String get back => 'Indietro';

  @override
  String get start_navigation => 'Avvia navigaz.';

  @override
  String get weekday_monday => 'Lunedì';

  @override
  String get weekday_tuesday => 'Martedì';

  @override
  String get weekday_wednesday => 'Mercoledì';

  @override
  String get weekday_thursday => 'Giovedì';

  @override
  String get weekday_friday => 'Venerdì';

  @override
  String get weekday_saturday => 'Sabato';

  @override
  String get weekday_sunday => 'Domenica';

  @override
  String station_identifier(int id) {
    return 'ID distributore: $id';
  }

  @override
  String get station_details_title => 'Dettagli distributore';

  @override
  String get fuel_prices_title => 'Prezzi carburante';

  @override
  String get fuel_prices_not_available =>
      'I prezzi dei carburanti non sono disponibili.';

  @override
  String get settings_marker_fuel => 'Carburante preferito';

  @override
  String get settings_marker_fuel_auto => 'Automatico';

  @override
  String get settings_marker_fuel_auto_disabledwhy =>
      'Questa impostazione è disabilitata se selezioni un solo tipo di carburante.';

  @override
  String get other_infos_title => 'Altre informazioni';

  @override
  String get other_infos_notavailable =>
      'Questa stazione di servizio non fornisce altre informazioni.';

  @override
  String get autocomplete_compliance_google_text =>
      'Completamento automatico fornito da Google';

  @override
  String get routeplanner_editroute_button => 'Modifica percorso';

  @override
  String get routeplanner_start_label => 'Partenza';

  @override
  String get routeplanner_destination_label => 'Destinazione';

  @override
  String get routeplanner_setting_avoidtolls => 'Evita pedaggi';

  @override
  String get routeplanner_reset_button => 'Ripristina';

  @override
  String get routeplanner_search_button => 'Cerca';

  @override
  String get routeplanner_emptylist_placeholder_text =>
      'Le stazioni di servizio lungo il percorso verranno mostrate qui.';

  @override
  String get routeplanner_toll_switch_desc_text =>
      'Escludi le strade a pedaggio dal calcolo del percorso.';

  @override
  String get routeplanner_enter_start_placeholder => 'Inserisci partenza';

  @override
  String get routeplanner_enter_destination_placeholder =>
      'Inserisci destinazione';

  @override
  String get routeplanner_usingcurrentlocation_text => 'Usando posizione';
}
