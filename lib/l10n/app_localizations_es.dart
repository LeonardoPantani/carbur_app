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
  String get button_close => 'Cerrar';

  @override
  String get button_ok => 'Aceptar';

  @override
  String get button_continue => 'Continue';

  @override
  String get button_cancel => 'Cancel';

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
  String stations_favorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gasolineras',
      one: '1 gasolinera',
    );
    return 'Tienes $_temp0 guardada(s) en favoritos.';
  }

  @override
  String last_update(Object date, Object time) {
    return 'Actualizado el $date a las $time';
  }

  @override
  String get section_map => 'Mapa';

  @override
  String get section_stations_list => 'Gasolineras';

  @override
  String get section_route_planner => 'Planifica tu ruta';

  @override
  String get start_navigation_question => '¿Iniciar navegación?';

  @override
  String get error => 'Error';

  @override
  String get error_description_unknown => 'Error desconocido.';

  @override
  String get error_description_api_ministry_notworking =>
      'El sitio web del Ministerio de Empresas y Made in Italy no está disponible.';

  @override
  String get error_description_api_routes_notworking =>
      'El servicio de cálculo de rutas no está disponible.';

  @override
  String get facilities_title => 'Servicios';

  @override
  String get facilities_not_available =>
      'Esta estación de servicio no proporciona información sobre sus servicios.';

  @override
  String get facility_food_and_beverage => 'Comida y bebidas';

  @override
  String get facility_car_workshop => 'Taller mecánico';

  @override
  String get facility_camper_truck_parking =>
      'Aparcamiento para autocaravanas / camiones';

  @override
  String get facility_camper_exhaust => 'Vaciado de autocaravanas';

  @override
  String get facility_kids_area => 'Zona infantil';

  @override
  String get facility_bancomat => 'Cajero automático';

  @override
  String get facility_handicapped_services => 'Servicios accesibles';

  @override
  String get facility_wifi => 'Wi-Fi';

  @override
  String get facility_tire_dealer => 'Servicio de neumáticos';

  @override
  String get facility_car_wash => 'Lavado de coches';

  @override
  String get facility_electric_charging => 'Carga eléctrica';

  @override
  String get facility_unknown => 'Servicio desconocido';

  @override
  String get phone => 'Teléfono';

  @override
  String get email => 'Correo electrónico';

  @override
  String get website => 'Sitio web';

  @override
  String get opening_hours_title => 'Horario de apertura';

  @override
  String get opening_hours_note =>
      'Estos horarios se refieren al servicio atendido. El autoservicio está siempre disponible.';

  @override
  String get opening_hours_not_available =>
      'Esta estación de servicio no proporciona información sobre su horario de apertura.';

  @override
  String get weekday => 'Día';

  @override
  String get morning => 'Mañana';

  @override
  String get afternoon => 'Tarde';

  @override
  String get open_24h => 'Abierto 24 h';

  @override
  String get back => 'Atrás';

  @override
  String get start_navigation => 'Iniciar navegación';

  @override
  String get weekday_monday => 'Lunes';

  @override
  String get weekday_tuesday => 'Martes';

  @override
  String get weekday_wednesday => 'Miércoles';

  @override
  String get weekday_thursday => 'Jueves';

  @override
  String get weekday_friday => 'Viernes';

  @override
  String get weekday_saturday => 'Sábado';

  @override
  String get weekday_sunday => 'Domingo';

  @override
  String station_identifier(int id) {
    return 'Identificador de la estación de servicio: $id';
  }

  @override
  String get station_details_title => 'Detalles de la estación de servicio';

  @override
  String get fuel_prices_title => 'Precios de los combustibles';

  @override
  String get fuel_prices_not_available => 'Precios no disponibles.';

  @override
  String get settings_marker_fuel => 'Tipo de combustible preferido';

  @override
  String get settings_marker_fuel_auto => 'Automático';

  @override
  String get settings_marker_fuel_auto_disabledwhy =>
      'Esta configuración se desactiva cuando seleccionas solo un tipo de combustible.';

  @override
  String get other_infos_title => 'Otra información';

  @override
  String get other_infos_notavailable =>
      'Esta gasolinera no proporciona otra información.';

  @override
  String get autocomplete_compliance_google_text =>
      'Tecnología de autocompletado proporcionada por Google';

  @override
  String get routeplanner_editroute_button => 'Editar ruta';

  @override
  String get routeplanner_start_label => 'Punto de partida';

  @override
  String get routeplanner_destination_label => 'Destino';

  @override
  String get routeplanner_setting_avoidtolls => 'Evitar peajes';

  @override
  String get routeplanner_reset_button => 'Restablecer';

  @override
  String get routeplanner_search_button => 'Buscar';

  @override
  String get routeplanner_emptylist_placeholder_text =>
      'Las gasolineras a lo largo de la ruta se mostrarán aquí.';

  @override
  String get routeplanner_toll_switch_desc_text =>
      'Excluir carreteras de peaje del cálculo de la ruta.';

  @override
  String get routeplanner_enter_start_placeholder =>
      'Introducir punto de partida';

  @override
  String get routeplanner_enter_destination_placeholder => 'Introducir destino';

  @override
  String get routeplanner_usingcurrentlocation_text =>
      'Usando ubicación actual';

  @override
  String get button_retry => 'Reintentar';

  @override
  String get error_title_no_connection => 'Sin conexión a Internet';

  @override
  String get error_description_no_connection =>
      'Es necesaria una conexión a Internet para obtener la información más reciente sobre las gasolineras.';

  @override
  String get error_description_no_connection_station_details =>
      'No estás conectado a Internet, pero aún puoi navegar hacia esta gasolinera.';

  @override
  String get favorites_empty =>
      'Aún no has guardado ninguna estación de servicio.';

  @override
  String get favorites_shownearbystations =>
      'Mostrar estaciones de servicio cercanas';

  @override
  String get favorites_showonlyfavorites => 'Mostrar solo favoritos.';

  @override
  String get favorites_add_to_favorites => 'Añadir a favoritos.';

  @override
  String get favorites_remove_from_favorites => 'Eliminar de favoritos.';

  @override
  String get favorites_removed =>
      'Estación de servicio eliminada de favoritos.';

  @override
  String get favorites_added => 'Estación de servicio añadida a favoritos.';

  @override
  String get dialog_location_permission_title => 'Location usage';

  @override
  String get dialog_location_permission_description =>
      'CarburApp collects data about your location to show you the nearest fuel stations and calculate distances, even when the app is in use.\n\nYour location is not shared for advertising purposes.';

  @override
  String get button_add_manually => 'Add manually';
}
