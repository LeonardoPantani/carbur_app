// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get no_stations_found => 'No se han encontrado estaciones.';

  @override
  String get fuel_petrol => 'Gasolina';

  @override
  String get fuel_diesel => 'Diésel';

  @override
  String get fuel_methane => 'Metano';

  @override
  String get fuel_lpg => 'GLP';

  @override
  String get fuel_lcng => 'LCNG';

  @override
  String get fuel_lng => 'GNL';

  @override
  String get settings_title => 'Ajustes';

  @override
  String get settings_fuel_types => 'Tipos de combustible';

  @override
  String get settings_search_radius => 'Radio de búsqueda';

  @override
  String get settings_select_fuels => '¿Qué combustibles?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get sort_cheaper => 'Más barato';

  @override
  String get sort_nearest => 'Más cercana';

  @override
  String get sort_lastupdate => 'Última actualización';

  @override
  String get sort_best => 'Mejor';

  @override
  String stations_found(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estaciones encontradas cerca de ti.',
      one: '1 estación encontrada cerca de ti.',
    );
    return '$_temp0';
  }

  @override
  String last_update(Object date, Object time) {
    return '$date a las $time';
  }

  @override
  String get section_map => 'Mapa';

  @override
  String get section_stations_list => 'Gasolineras';

  @override
  String get start_navigation_question => '¿Iniciar navegación?';
}
