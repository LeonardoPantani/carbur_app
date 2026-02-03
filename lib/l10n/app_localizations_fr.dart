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
  String get button_close => 'Fermer';

  @override
  String get button_ok => 'Ok';

  @override
  String get button_continue => 'Continuer';

  @override
  String get button_cancel => 'Annuler';

  @override
  String get button_back => 'Retour';

  @override
  String get button_opensettings => 'Ouvrir les paramètres';

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
  String stations_favorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations-service enregistrées',
      one: '1 station-service enregistrée',
    );
    return 'Vous avez $_temp0 dans vos favoris.';
  }

  @override
  String last_update(Object date) {
    return 'Prix mis à jour le $date';
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
      'Cette station-service ne fournit pas d\'informations sur ses services.';

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
  String get opening_hours_title => 'Horaires d\'ouverture';

  @override
  String get opening_hours_note =>
      'Ces horaires concernent le service avec personnel. Le libre-service est toujours disponible.';

  @override
  String get opening_hours_not_available =>
      'Cette station-service ne fournit pas d\'informations sur ses horaires d\'ouverture.';

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
  String get error_title_no_connection => 'Pas de connexion Internet';

  @override
  String get error_description_no_connection =>
      'Une connexion Internet active est nécessaire pour obtenir les dernières informations sur les stations-service.';

  @override
  String get error_description_no_connection_station_details =>
      'Vous n\'êtes pas connecté à Internet, mais vous pouvez toujours naviguer vers questa station-service.';

  @override
  String get favorites_empty =>
      'Vous n\'avez encore enregistré aucune station-service.';

  @override
  String get favorites_shownearbystations =>
      'Afficher les stations-service à proximité';

  @override
  String get favorites_showonlyfavorites => 'Afficher uniquement les favoris.';

  @override
  String get favorites_add_to_favorites => 'Ajouter aux favoris.';

  @override
  String get favorites_remove_from_favorites => 'Retirer des favoris.';

  @override
  String get favorites_removed => 'Station-service retirée des favoris.';

  @override
  String get favorites_added => 'Station-service ajoutée aux favoris.';

  @override
  String get dialog_location_permission_title =>
      'Utilisation de la localisation';

  @override
  String get dialog_location_permission_description =>
      'CarburApp utilise votre localisation pour afficher les stations-service proches et calculer les distances.\n\nElle ne sera pas partagée avec des tiers.\n\nSi vous le souhaitez, vous pouvez saisir une adresse manuellement.';

  @override
  String get button_add_manually => 'Saisir la localisation';

  @override
  String get saved_places => 'Lieux enregistrés';

  @override
  String get enter_address_placeholder => 'Saisir une adresse';

  @override
  String get error_snackbar_location_permission_no =>
      'Oups, vous avez probablement appuyé sur \"non\" par erreur. Réessayez. Si vous avez changé d’avis, vous pouvez toujours saisir la localisation manuellement.';

  @override
  String get error_snackbar_gps_turned_off =>
      'Le GPS est désactivé. Activez-le et continuez.';

  @override
  String get error_dialog_title_location_permission_required =>
      'Votre intervention est requise';

  @override
  String get error_dialog_description_location_permission_required =>
      'Vous avez refusé l’accès à la localisation.\n\nPour l’utiliser, vous devez activer l’autorisation manuellement dans les paramètres.';

  @override
  String get button_tooltip_remove_places_from_saved =>
      'Supprimer le lieu enregistré';

  @override
  String get snackbar_location_permission_yes => 'Bon choix !';

  @override
  String get settings_category_general => 'Général';

  @override
  String get settings_category_legal => 'Mentions légales';

  @override
  String get startup_check_internet =>
      'Vérification de la connexion Internet...';

  @override
  String get startup_check_config => 'Vérification de la configuration...';

  @override
  String get startup_check_resources => 'Récupération des ressources...';

  @override
  String get startup_check_location => 'Vérification de la localisation...';

  @override
  String get startup_check_ready => 'Tout est prêt !';

  @override
  String get welcome_title => 'Bienvenue !';

  @override
  String get welcome_description =>
      'Pour commencer, sélectionnez les types de carburant qui vous intéressent.';

  @override
  String get settings_contact_us => 'Contactez-nous';

  @override
  String get settings_contact_us_subtitle => 'Chaque retour est apprécié.';

  @override
  String get settings_filter_brands => 'Marques favorites';

  @override
  String settings_brands_selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marques sélectionnées',
      one: '1 marque sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get settings_brands_all_selected => 'Toutes les marques';

  @override
  String get settings_select_brands_dialog_title => 'Sélectionner des marques';

  @override
  String get search_brands_placeholder => 'Rechercher une marque...';

  @override
  String get settings_setting_unavailable => 'Option indisponible';

  @override
  String get settings_fuel_consumption_title => 'Consommation moyenne';

  @override
  String get settings_fuel_consumption_subtitle =>
      'Saisissez la consommation de votre véhicule';

  @override
  String get unit_km_per_liter => 'km/L';

  @override
  String get unit_liters_per_100km => 'L/100km';
}
