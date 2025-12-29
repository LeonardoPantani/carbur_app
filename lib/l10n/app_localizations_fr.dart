// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get no_stations_found => 'Aucune station trouvée.';

  @override
  String get fuel_petrol => 'Essence';

  @override
  String get fuel_diesel => 'Diesel';

  @override
  String get fuel_methane => 'Méthane';

  @override
  String get fuel_lpg => 'GPL';

  @override
  String get fuel_lcng => 'LCNG';

  @override
  String get fuel_lng => 'GNL';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_fuel_types => 'Types de carburant';

  @override
  String get settings_search_radius => 'Rayon de recherche';

  @override
  String get settings_select_fuels => 'Quels carburants ?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get sort_cheaper => 'Moins cher';

  @override
  String get sort_nearest => 'La plus proche';

  @override
  String get sort_lastupdate => 'Dernière mise à jour';

  @override
  String get sort_best => 'Meilleure';

  @override
  String stations_found(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations-service trouvées près de vous.',
      one: '1 station-service trouvée près de vous.',
    );
    return '$_temp0';
  }

  @override
  String last_update(Object date, Object time) {
    return 'Mis à jour le $date à $time';
  }

  @override
  String get section_map => 'Carte';

  @override
  String get section_stations_list => 'Stations-service';

  @override
  String get section_route_planner => 'Planifier trajet';

  @override
  String get start_navigation_question => 'Démarrer la navigation ?';

  @override
  String get error => 'Erreur';

  @override
  String get error_description_unknown => 'Erreur inconnue.';

  @override
  String get error_description_api_ministry_notworking =>
      'Le site du Ministère des Entreprises et du Made in Italy est indisponible.';

  @override
  String get error_description_api_routes_notworking =>
      'Le service de calcul des itinéraires est indisponible.';

  @override
  String get facilities_title => 'Services';

  @override
  String get facilities_not_available =>
      'Cette station-service ne fournit pas d’informations sur ses services.';

  @override
  String get facility_food_and_beverage => 'Restauration et boissons';

  @override
  String get facility_car_workshop => 'Atelier automobile';

  @override
  String get facility_camper_truck_parking => 'Parking camping-cars / camions';

  @override
  String get facility_camper_exhaust => 'Vidange camping-car';

  @override
  String get facility_kids_area => 'Espace enfants';

  @override
  String get facility_bancomat => 'Distributeur automatique';

  @override
  String get facility_handicapped_services => 'Services accessibles';

  @override
  String get facility_wifi => 'Wi-Fi';

  @override
  String get facility_tire_dealer => 'Service de pneus';

  @override
  String get facility_car_wash => 'Station de lavage';

  @override
  String get facility_electric_charging => 'Recharge électrique';

  @override
  String get facility_unknown => 'Service inconnu';

  @override
  String get phone => 'Téléphone';

  @override
  String get email => 'E-mail';

  @override
  String get website => 'Site web';

  @override
  String get opening_hours_title => 'Horaires d’ouverture';

  @override
  String get opening_hours_note =>
      'Ces horaires concernent le service avec personnel. Le libre-service est toujours disponible.';

  @override
  String get opening_hours_not_available =>
      'Cette station-service ne fournit pas d’informations sur ses horaires d’ouverture.';

  @override
  String get weekday => 'Jour';

  @override
  String get morning => 'Matin';

  @override
  String get afternoon => 'Après-midi';

  @override
  String get open_24h => 'Ouvert 24h/24';

  @override
  String get back => 'Retour';

  @override
  String get start_navigation => 'Démarrer la navigation';

  @override
  String get weekday_monday => 'Lundi';

  @override
  String get weekday_tuesday => 'Mardi';

  @override
  String get weekday_wednesday => 'Mercredi';

  @override
  String get weekday_thursday => 'Jeudi';

  @override
  String get weekday_friday => 'Vendredi';

  @override
  String get weekday_saturday => 'Samedi';

  @override
  String get weekday_sunday => 'Dimanche';

  @override
  String station_identifier(int id) {
    return 'Identifiant de la station-service : $id';
  }

  @override
  String get station_details_title => 'Détails de la station-service';

  @override
  String get fuel_prices_title => 'Prix des carburants';

  @override
  String get fuel_prices_not_available => 'Prix non disponibles.';

  @override
  String get settings_marker_fuel => 'Type de carburant préféré';

  @override
  String get settings_marker_fuel_auto => 'Automatique';

  @override
  String get settings_marker_fuel_auto_disabledwhy =>
      'Ce paramètre est désactivé lorsque vous sélectionnez un seul type de carburant.';

  @override
  String get other_infos_title => 'Autres informations';

  @override
  String get other_infos_notavailable =>
      'Cette station-service ne fournit pas d\'autres informations.';

  @override
  String get autocomplete_compliance_google_text =>
      'Technologie de saisie semi-automatique fournie par Google';

  @override
  String get routeplanner_editroute_button => 'Modifier l\'itinéraire';

  @override
  String get routeplanner_start_label => 'Point de départ';

  @override
  String get routeplanner_destination_label => 'Destination';

  @override
  String get routeplanner_setting_avoidtolls => 'Éviter les péages';

  @override
  String get routeplanner_reset_button => 'Réinitialiser';

  @override
  String get routeplanner_search_button => 'Rechercher';

  @override
  String get routeplanner_emptylist_placeholder_text =>
      'Les stations-service le long de l\'itinéraire seront affichées ici.';

  @override
  String get routeplanner_toll_switch_desc_text =>
      'Exclure les routes à péage du calcul de l\'itinéraire.';

  @override
  String get routeplanner_enter_start_placeholder =>
      'Saisir le point de départ';

  @override
  String get routeplanner_enter_destination_placeholder =>
      'Saisir la destination';

  @override
  String get routeplanner_usingcurrentlocation_text =>
      'Utilisation de la position actuelle';

  @override
  String get button_retry => 'Réessayer';

  @override
  String get no_connection_title => 'Pas de connexion Internet';

  @override
  String get no_connection_description =>
      'Une connexion Internet active est nécessaire pour obtenir les dernières informations sur les stations-service.';
}
