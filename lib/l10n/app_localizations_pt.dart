// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get no_stations_found => 'Nenhum posto encontrado.';

  @override
  String get fuel_petrol => 'Gasolina';

  @override
  String get fuel_diesel => 'Diesel';

  @override
  String get fuel_methane => 'Metano';

  @override
  String get fuel_lpg => 'GLP';

  @override
  String get fuel_lcng => 'LCNG';

  @override
  String get fuel_lng => 'GNL';

  @override
  String get settings_title => 'Configurações';

  @override
  String get settings_fuel_types => 'Tipos de combustível';

  @override
  String get settings_search_radius => 'Raio de busca';

  @override
  String get settings_select_fuels => 'Quais combustíveis?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get close => 'Fechar';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get sort_cheaper => 'Mais barato';

  @override
  String get sort_nearest => 'Mais próximo';

  @override
  String get sort_lastupdate => 'Última atualização';

  @override
  String get sort_best => 'Melhor';

  @override
  String stations_found(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count postos de combustível encontrados perto de você.',
      one: '1 posto de combustível encontrado perto de você.',
    );
    return '$_temp0';
  }

  @override
  String last_update(Object date, Object time) {
    return '$date às $time';
  }
}
