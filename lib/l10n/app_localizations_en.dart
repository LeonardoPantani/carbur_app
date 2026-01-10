// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get no_stations_found => 'No stations found.';

  @override
  String get fuel_petrol => 'Petrol';

  @override
  String get fuel_diesel => 'Diesel';

  @override
  String get fuel_methane => 'Methane';

  @override
  String get fuel_lpg => 'LPG';

  @override
  String get fuel_lcng => 'LCNG';

  @override
  String get fuel_lng => 'LNG';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_fuel_types => 'Fuel types';

  @override
  String get settings_search_radius => 'Search radius';

  @override
  String get settings_select_fuels => 'Which fuels?';

  @override
  String settings_footer_madeby(Object name) {
    return 'Made with ❤️ by $name';
  }

  @override
  String get button_close => 'button_close';

  @override
  String get button_ok => 'button_ok';

  @override
  String get button_continue => 'Continue';

  @override
  String get button_cancel => 'Cancel';

  @override
  String get sort_cheaper => 'Cheapest';

  @override
  String get sort_nearest => 'Nearest';

  @override
  String get sort_lastupdate => 'Last Update';

  @override
  String get sort_best => 'Best';

  @override
  String stations_found(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations found around you.',
      one: '1 station found around you.',
    );
    return '$_temp0';
  }

  @override
  String stations_favorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations',
      one: '1 station',
    );
    return 'You have $_temp0 saved in your favorites.';
  }

  @override
  String last_update(Object date, Object time) {
    return 'Updated on $date at $time';
  }

  @override
  String get section_map => 'Map';

  @override
  String get section_stations_list => 'Stations';

  @override
  String get section_route_planner => 'Route planner';

  @override
  String get start_navigation_question => 'Start navigation?';

  @override
  String get error => 'Error';

  @override
  String get error_description_unknown => 'Unknown error.';

  @override
  String get error_description_api_ministry_notworking =>
      'Ministry of Enterprises website is not working.';

  @override
  String get error_description_api_routes_notworking =>
      'Routes websites is not working.';

  @override
  String get facilities_title => 'Facilities';

  @override
  String get facilities_not_available =>
      'This fuel station does not provide information about its facilities.';

  @override
  String get facility_food_and_beverage => 'Food & beverages';

  @override
  String get facility_car_workshop => 'Car workshop';

  @override
  String get facility_camper_truck_parking => 'Camper / truck parking';

  @override
  String get facility_camper_exhaust => 'Camper waste disposal';

  @override
  String get facility_kids_area => 'Kids area';

  @override
  String get facility_bancomat => 'ATM';

  @override
  String get facility_handicapped_services => 'Accessible services';

  @override
  String get facility_wifi => 'Wi-Fi';

  @override
  String get facility_tire_dealer => 'Tire service';

  @override
  String get facility_car_wash => 'Car wash';

  @override
  String get facility_electric_charging => 'Electric charging';

  @override
  String get facility_unknown => 'Unknown service';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get opening_hours_title => 'Opening hours';

  @override
  String get opening_hours_note =>
      'These hours refer to the attended service. Self-service is always available.';

  @override
  String get opening_hours_not_available =>
      'This fuel station does not provide information about its opening hours.';

  @override
  String get weekday => 'Weekday';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get open_24h => 'Open 24h';

  @override
  String get back => 'Back';

  @override
  String get start_navigation => 'Navigate';

  @override
  String get weekday_monday => 'Monday';

  @override
  String get weekday_tuesday => 'Tuesday';

  @override
  String get weekday_wednesday => 'Wednesday';

  @override
  String get weekday_thursday => 'Thursday';

  @override
  String get weekday_friday => 'Friday';

  @override
  String get weekday_saturday => 'Saturday';

  @override
  String get weekday_sunday => 'Sunday';

  @override
  String station_identifier(int id) {
    return 'Fuel station identifier: $id';
  }

  @override
  String get station_details_title => 'Fuel station details';

  @override
  String get fuel_prices_title => 'Fuel prices';

  @override
  String get fuel_prices_not_available => 'Fuel prices not available.';

  @override
  String get settings_marker_fuel => 'Preferred fuel type';

  @override
  String get settings_marker_fuel_auto => 'Auto';

  @override
  String get settings_marker_fuel_auto_disabledwhy =>
      'This setting is disabled when you select only a type of fuel.';

  @override
  String get other_infos_title => 'Other information';

  @override
  String get other_infos_notavailable =>
      'This fuel station does not provide other info.';

  @override
  String get autocomplete_compliance_google_text =>
      'Autocomplete technology provided by Google';

  @override
  String get routeplanner_editroute_button => 'Edit route';

  @override
  String get routeplanner_start_label => 'Start point';

  @override
  String get routeplanner_destination_label => 'Destination';

  @override
  String get routeplanner_setting_avoidtolls => 'Avoid tolls';

  @override
  String get routeplanner_reset_button => 'Reset';

  @override
  String get routeplanner_search_button => 'Search';

  @override
  String get routeplanner_emptylist_placeholder_text =>
      'Petrol stations along the route will be shown here.';

  @override
  String get routeplanner_toll_switch_desc_text =>
      'Exclude toll roads from route calculation.';

  @override
  String get routeplanner_enter_start_placeholder => 'Enter start point';

  @override
  String get routeplanner_enter_destination_placeholder => 'Enter destination';

  @override
  String get routeplanner_usingcurrentlocation_text => 'Using current location';

  @override
  String get button_retry => 'Try again';

  @override
  String get error_title_no_connection => 'No Internet connection';

  @override
  String get error_description_no_connection =>
      'An active Internet connection is required to fetch the latest fuel station prices.';

  @override
  String get error_description_no_connection_station_details =>
      'You are not connected to the Internet, but you can still navigate to this fuel station.';

  @override
  String get favorites_empty => 'You haven\'t saved any fuel station yet.';

  @override
  String get favorites_shownearbystations => 'Show nearby fuel stations';

  @override
  String get favorites_showonlyfavorites => 'Show only favorites.';

  @override
  String get favorites_add_to_favorites => 'Add to favorites.';

  @override
  String get favorites_remove_from_favorites => 'Remove from favorites.';

  @override
  String get favorites_removed => 'Fuel station removed from favorites.';

  @override
  String get favorites_added => 'Fuel station added to favorites.';

  @override
  String get dialog_location_permission_title => 'Location usage';

  @override
  String get dialog_location_permission_description =>
      'CarburApp collects data about your location to show you the nearest fuel stations and calculate distances, even when the app is in use.\n\nYour location is not shared for advertising purposes.';

  @override
  String get button_add_manually => 'Add manually';
}
