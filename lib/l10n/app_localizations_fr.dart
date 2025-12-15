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
    return '$date à $time';
  }

  @override
  String get section_map => 'Carte';

  @override
  String get section_stations_list => 'Stations-service';

  @override
  String get start_navigation_question => 'Démarrer la navigation ?';
}
