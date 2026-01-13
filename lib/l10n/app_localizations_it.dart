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
  String get fuel_diesel => 'Diesel';

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
  String get button_close => 'Chiudi';

  @override
  String get button_ok => 'Ok';

  @override
  String get button_continue => 'Continua';

  @override
  String get button_cancel => 'Annulla';

  @override
  String get button_back => 'Indietro';

  @override
  String get button_opensettings => 'Apri impostazioni';

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
  String stations_favorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count distributori salvati',
      one: '1 distributore salvato',
    );
    return 'Hai $_temp0 nei preferiti.';
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

  @override
  String get button_retry => 'Riprova';

  @override
  String get error_title_no_connection => 'Connessione Internet assente';

  @override
  String get error_description_no_connection =>
      'È richiesta una connessione ad Internet funzionante per scaricare i dati aggiornati dei distributori.';

  @override
  String get error_description_no_connection_station_details =>
      'Non sei connesso ad Internet, ma puoi comunque navigare verso questo distributore.';

  @override
  String get favorites_empty => 'Non hai distributori tra i preferiti.';

  @override
  String get favorites_shownearbystations =>
      'Mostra distributori nelle vicinanze';

  @override
  String get favorites_showonlyfavorites => 'Mostra solo i preferiti.';

  @override
  String get favorites_add_to_favorites => 'Aggiungi ai preferiti.';

  @override
  String get favorites_remove_from_favorites => 'Rimuovi dai preferiti.';

  @override
  String get favorites_removed => 'Distributore rimosso dai preferiti.';

  @override
  String get favorites_added => 'Distributore aggiunto ai preferiti.';

  @override
  String get dialog_location_permission_title => 'Uso posizione';

  @override
  String get dialog_location_permission_description =>
      'CarburApp usa la tua posizione per mostrare i distributori vicini a te e calcolare le distanze.\n\nNon verrà condivisa con terze parti.\n\nSe non te la senti, puoi inserire un indirizzo manualmente.';

  @override
  String get button_add_manually => 'Inserisci posizione';

  @override
  String get saved_places => 'Luoghi salvati';

  @override
  String get enter_address_placeholder => 'Inserisci indirizzo';

  @override
  String get error_snackbar_location_permission_no =>
      'Oh oh, probabilmente hai premuto \"no\" per errore. Riprova. Se hai cambiato idea, puoi comunque inserire la posizione a mano.';

  @override
  String get error_snackbar_gps_turned_off =>
      'Il GPS è disattivato. Attivalo e continua.';

  @override
  String get error_dialog_title_location_permission_required =>
      'È richiesto il tuo intervento';

  @override
  String get error_dialog_description_location_permission_required =>
      'Hai negato l\'accesso alla posizione.\n\nPer usarla, devi abilitare il permesso manualmente nelle Impostazioni.';

  @override
  String get button_tooltip_remove_places_from_saved => 'Elimina luogo salvato';

  @override
  String get snackbar_location_permission_yes => 'Ottima scelta!';

  @override
  String get settings_category_general => 'Generali';

  @override
  String get settings_category_legal => 'Legale';

  @override
  String get startup_check_internet => 'Verifico la connessione Internet...';

  @override
  String get startup_check_config => 'Verifico la configurazione...';

  @override
  String get startup_check_resources => 'Ottengo le risorse...';

  @override
  String get startup_check_location => 'Ottengo la posizione...';

  @override
  String get startup_check_ready => 'Tutto pronto!';

  @override
  String get welcome_title => 'Ciao!';

  @override
  String get welcome_description =>
      'Per iniziare, seleziona i tipi di carburante che ti interessano.';
}
