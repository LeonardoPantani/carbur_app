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

  @override
  String get section_map => 'Mapa';

  @override
  String get section_stations_list => 'Postos de combustível';

  @override
  String get start_navigation_question => 'Iniciar navegação?';

  @override
  String get error => 'Erro';

  @override
  String get error_description_unknown => 'Erro desconhecido.';

  @override
  String get error_description_api_ministry_notworking =>
      'O site do Ministério das Empresas e do Made in Italy não está disponível.';

  @override
  String get error_description_api_routes_notworking =>
      'O serviço de cálculo de rotas não está disponível.';

  @override
  String get facilities_title => 'Serviços';

  @override
  String get facilities_not_available =>
      'Este posto de combustível não fornece informações sobre seus serviços.';

  @override
  String get facility_food_and_beverage => 'Alimentação e bebidas';

  @override
  String get facility_car_workshop => 'Oficina mecânica';

  @override
  String get facility_camper_truck_parking =>
      'Estacionamento para motorhomes / caminhões';

  @override
  String get facility_camper_exhaust => 'Descarte de resíduos de motorhome';

  @override
  String get facility_kids_area => 'Área infantil';

  @override
  String get facility_bancomat => 'Caixa eletrônico';

  @override
  String get facility_handicapped_services => 'Serviços acessíveis';

  @override
  String get facility_wifi => 'Wi-Fi';

  @override
  String get facility_tire_dealer => 'Serviço de pneus';

  @override
  String get facility_car_wash => 'Lavagem de veículos';

  @override
  String get facility_electric_charging => 'Carregamento elétrico';

  @override
  String get facility_unknown => 'Serviço desconhecido';

  @override
  String get phone => 'Telefone';

  @override
  String get email => 'E-mail';

  @override
  String get website => 'Site';

  @override
  String get opening_hours_title => 'Horário de funcionamento';

  @override
  String get opening_hours_note =>
      'Este horário refere-se ao atendimento com funcionário. O autoatendimento está sempre disponível.';

  @override
  String get opening_hours_not_available =>
      'Este posto de combustível não fornece informações sobre o horário de funcionamento.';

  @override
  String get weekday => 'Dia';

  @override
  String get morning => 'Manhã';

  @override
  String get afternoon => 'Tarde';

  @override
  String get open_24h => 'Aberto 24 h';

  @override
  String get back => 'Voltar';

  @override
  String get start_navigation => 'Iniciar navegação';

  @override
  String get weekday_monday => 'Segunda-feira';

  @override
  String get weekday_tuesday => 'Terça-feira';

  @override
  String get weekday_wednesday => 'Quarta-feira';

  @override
  String get weekday_thursday => 'Quinta-feira';

  @override
  String get weekday_friday => 'Sexta-feira';

  @override
  String get weekday_saturday => 'Sábado';

  @override
  String get weekday_sunday => 'Domingo';

  @override
  String station_identifier(int id) {
    return 'Identificador do posto de combustível: $id';
  }

  @override
  String get station_details_title => 'Detalhes do posto de combustível';

  @override
  String get fuel_prices_title => 'Preços dos combustíveis';

  @override
  String get fuel_prices_not_available => 'Preços indisponíveis.';

  @override
  String get settings_marker_fuel => 'Tipo de combustível preferido';

  @override
  String get settings_marker_fuel_auto => 'Automático';

  @override
  String get settings_marker_fuel_auto_disabledwhy =>
      'Esta configuração fica desativada quando apenas um tipo de combustível é selecionado.';
}
