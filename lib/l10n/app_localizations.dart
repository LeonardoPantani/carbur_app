import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
  ];

  /// Message shown when the search returns no fuel stations.
  ///
  /// In en, this message translates to:
  /// **'No stations found.'**
  String get no_stations_found;

  /// Fuel label: petrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get fuel_petrol;

  /// Fuel label: diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get fuel_diesel;

  /// Fuel label: methane.
  ///
  /// In en, this message translates to:
  /// **'Methane'**
  String get fuel_methane;

  /// Fuel label: liquefied petroleum gas (LPG).
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get fuel_lpg;

  /// Fuel label: LCNG (liquefied to compressed natural gas).
  ///
  /// In en, this message translates to:
  /// **'LCNG'**
  String get fuel_lcng;

  /// Fuel label: liquefied natural gas (LNG).
  ///
  /// In en, this message translates to:
  /// **'LNG'**
  String get fuel_lng;

  /// Title of the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// Label for the option to select preferred fuel types.
  ///
  /// In en, this message translates to:
  /// **'Fuel types'**
  String get settings_fuel_types;

  /// Label for the option to adjust the search radius.
  ///
  /// In en, this message translates to:
  /// **'Search radius'**
  String get settings_search_radius;

  /// Title of the dialog for selecting fuel types.
  ///
  /// In en, this message translates to:
  /// **'Which fuels?'**
  String get settings_select_fuels;

  /// Footer text showing the author's name.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by {name}'**
  String settings_footer_madeby(Object name);

  /// Button label to close a dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Confirmation button label.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Button label to cancel an operation.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Filter button to allows the user to choose the station with the cheapest price.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get sort_cheaper;

  /// Filter button to allows the user to choose the nearest station from them.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sort_nearest;

  /// Filter button to allow the user to choose the station with the most recent price update date.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get sort_lastupdate;

  /// Filter button to allow the user to choose the station with the best overall parameters.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get sort_best;

  /// Header before list of stations that tells how many stations have been found following user's preferences.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 station found around you.} other{{count} stations found around you.}}'**
  String stations_found(int count);

  /// Header before list of favorited stations that tells how many stations have been saved by the user as favorites.
  ///
  /// In en, this message translates to:
  /// **'You have {count, plural, one{1 station} other{{count} stations}} saved in your favorites.'**
  String stations_favorited(int count);

  /// Last update date and time for a fuel station.
  ///
  /// In en, this message translates to:
  /// **'Updated on {date} at {time}'**
  String last_update(Object date, Object time);

  /// String visible in the bottom bar selection menu.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get section_map;

  /// String visible in the bottom bar selection menu.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get section_stations_list;

  /// String visible in the bottom bar selection menu.
  ///
  /// In en, this message translates to:
  /// **'Route planner'**
  String get section_route_planner;

  /// Title of dialog that appears when clicking on a marker on the map.
  ///
  /// In en, this message translates to:
  /// **'Start navigation?'**
  String get start_navigation_question;

  /// Error screen title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// This appears as a description when an unknown error must be shown to the user.
  ///
  /// In en, this message translates to:
  /// **'Unknown error.'**
  String get error_description_unknown;

  /// This appears as a description when the API of the Ministry of Enterprises and Made in Italy is not working.
  ///
  /// In en, this message translates to:
  /// **'Ministry of Enterprises website is not working.'**
  String get error_description_api_ministry_notworking;

  /// This appears as a description when the API that calculates the driving routes between user's location and fuel station is not working.
  ///
  /// In en, this message translates to:
  /// **'Routes websites is not working.'**
  String get error_description_api_routes_notworking;

  /// Title of the section listing the available facilities at the fuel station.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities_title;

  /// Message shown when no facility information is available for the fuel station.
  ///
  /// In en, this message translates to:
  /// **'This fuel station does not provide information about its facilities.'**
  String get facilities_not_available;

  /// Service available at the fuel station: food and beverage facilities.
  ///
  /// In en, this message translates to:
  /// **'Food & beverages'**
  String get facility_food_and_beverage;

  /// Service available at the fuel station: car repair workshop.
  ///
  /// In en, this message translates to:
  /// **'Car workshop'**
  String get facility_car_workshop;

  /// Service available at the fuel station: parking for campers and trucks.
  ///
  /// In en, this message translates to:
  /// **'Camper / truck parking'**
  String get facility_camper_truck_parking;

  /// Service available at the fuel station: camper waste disposal area.
  ///
  /// In en, this message translates to:
  /// **'Camper waste disposal'**
  String get facility_camper_exhaust;

  /// Service available at the fuel station: dedicated area for children.
  ///
  /// In en, this message translates to:
  /// **'Kids area'**
  String get facility_kids_area;

  /// Service available at the fuel station: ATM (cash machine).
  ///
  /// In en, this message translates to:
  /// **'ATM'**
  String get facility_bancomat;

  /// Service available at the fuel station: facilities for people with disabilities.
  ///
  /// In en, this message translates to:
  /// **'Accessible services'**
  String get facility_handicapped_services;

  /// Service available at the fuel station: wireless internet access.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get facility_wifi;

  /// Service available at the fuel station: tire dealer or tire repair service.
  ///
  /// In en, this message translates to:
  /// **'Tire service'**
  String get facility_tire_dealer;

  /// Service available at the fuel station: car wash facility.
  ///
  /// In en, this message translates to:
  /// **'Car wash'**
  String get facility_car_wash;

  /// Service available at the fuel station: electric vehicle charging station.
  ///
  /// In en, this message translates to:
  /// **'Electric charging'**
  String get facility_electric_charging;

  /// Fallback label for an unknown or unsupported fuel station service.
  ///
  /// In en, this message translates to:
  /// **'Unknown service'**
  String get facility_unknown;

  /// Label for phone number.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Label for email address.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for website URL.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Title of the opening hours section.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get opening_hours_title;

  /// Note explaining that opening hours apply only to attended service.
  ///
  /// In en, this message translates to:
  /// **'These hours refer to the attended service. Self-service is always available.'**
  String get opening_hours_note;

  /// Message shown when opening hours are not available.
  ///
  /// In en, this message translates to:
  /// **'This fuel station does not provide information about its opening hours.'**
  String get opening_hours_not_available;

  /// Header of the weekday column in the opening hours table.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get weekday;

  /// Header of the morning opening hours column.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// Header of the afternoon opening hours column.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// Label indicating 24-hour opening.
  ///
  /// In en, this message translates to:
  /// **'Open 24h'**
  String get open_24h;

  /// Back button label.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Button label to start navigation to the station.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get start_navigation;

  /// Weekday: Monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekday_monday;

  /// Weekday: Tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekday_tuesday;

  /// Weekday: Wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekday_wednesday;

  /// Weekday: Thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekday_thursday;

  /// Weekday: Friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekday_friday;

  /// Weekday: Saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekday_saturday;

  /// Weekday: Sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekday_sunday;

  /// Dialog text showing the unique identifier of the fuel station.
  ///
  /// In en, this message translates to:
  /// **'Fuel station identifier: {id}'**
  String station_identifier(int id);

  /// Title of the fuel details page.
  ///
  /// In en, this message translates to:
  /// **'Fuel station details'**
  String get station_details_title;

  /// Title of the fuels list header in fuel station details page.
  ///
  /// In en, this message translates to:
  /// **'Fuel prices'**
  String get fuel_prices_title;

  /// Text showing if fuel prices are not found (strange).
  ///
  /// In en, this message translates to:
  /// **'Fuel prices not available.'**
  String get fuel_prices_not_available;

  /// Title of setting that selects which price should the markers on the map show if the user has selected multiple fuels.
  ///
  /// In en, this message translates to:
  /// **'Preferred fuel type'**
  String get settings_marker_fuel;

  /// Automatic choice of the price to show in the marker the map.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settings_marker_fuel_auto;

  /// Explaination on why the preferred fuel type setting is not available.
  ///
  /// In en, this message translates to:
  /// **'This setting is disabled when you select only a type of fuel.'**
  String get settings_marker_fuel_auto_disabledwhy;

  /// Other information header title (regarding a fuel station, like email, website or phone number).
  ///
  /// In en, this message translates to:
  /// **'Other information'**
  String get other_infos_title;

  /// Message shown when no other information is available for the fuel station.
  ///
  /// In en, this message translates to:
  /// **'This fuel station does not provide other info.'**
  String get other_infos_notavailable;

  /// Text that appears at the bottom of the search address page.
  ///
  /// In en, this message translates to:
  /// **'Autocomplete technology provided by Google'**
  String get autocomplete_compliance_google_text;

  /// Text of button that appears after closing the menu of selection of destination.
  ///
  /// In en, this message translates to:
  /// **'Edit route'**
  String get routeplanner_editroute_button;

  /// Label indicating the text area containing the start point address.
  ///
  /// In en, this message translates to:
  /// **'Start point'**
  String get routeplanner_start_label;

  /// Label indicating the text area containing the destination address.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get routeplanner_destination_label;

  /// Switch that enables or disables tolls routes.
  ///
  /// In en, this message translates to:
  /// **'Avoid tolls'**
  String get routeplanner_setting_avoidtolls;

  /// Reset button.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get routeplanner_reset_button;

  /// Search route button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get routeplanner_search_button;

  /// Placeholder for when the fuel stations list has not been populated yet.
  ///
  /// In en, this message translates to:
  /// **'Petrol stations along the route will be shown here.'**
  String get routeplanner_emptylist_placeholder_text;

  /// Descriptive text for avoid tolls button.
  ///
  /// In en, this message translates to:
  /// **'Exclude toll roads from route calculation.'**
  String get routeplanner_toll_switch_desc_text;

  /// Placeholder text in text area while entering text.
  ///
  /// In en, this message translates to:
  /// **'Enter start point'**
  String get routeplanner_enter_start_placeholder;

  /// Placeholder text in text area while entering text.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get routeplanner_enter_destination_placeholder;

  /// Inside text area of both start and destination points while current location is used.
  ///
  /// In en, this message translates to:
  /// **'Using current location'**
  String get routeplanner_usingcurrentlocation_text;

  /// Button try again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get button_retry;

  /// This title appears when the app could not be opened because Internet is not working. This only appears on the opening of the app, Internet connection is not checked any further.
  ///
  /// In en, this message translates to:
  /// **'No Internet connection'**
  String get error_title_no_connection;

  /// Description for no Internet connection page.
  ///
  /// In en, this message translates to:
  /// **'An active Internet connection is required to fetch the latest fuel station prices.'**
  String get error_description_no_connection;

  /// Description for the station details page when there is not Internet connection.
  ///
  /// In en, this message translates to:
  /// **'You are not connected to the Internet, but you can still navigate to this fuel station.'**
  String get error_description_no_connection_station_details;

  /// This text appears in the favorites list when empty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any fuel station yet.'**
  String get favorites_empty;

  /// This text appears as a tooltip when tapping and holding the star button in the stations list page.
  ///
  /// In en, this message translates to:
  /// **'Show nearby fuel stations'**
  String get favorites_shownearbystations;

  /// This text appears as a tooltip when tapping and holding the star button in the stations list page.
  ///
  /// In en, this message translates to:
  /// **'Show only favorites.'**
  String get favorites_showonlyfavorites;

  /// This text appears as a tooltip when tapping and holding the star button in the stations details page.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites.'**
  String get favorites_add_to_favorites;

  /// This text appears as a tooltip when tapping and holding the star button in the stations details page.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites.'**
  String get favorites_remove_from_favorites;

  /// This text appears in the snackbar informing the user that the fuel station has been removed from their favorites.
  ///
  /// In en, this message translates to:
  /// **'Fuel station removed from favorites.'**
  String get favorites_removed;

  /// This text appears in the snackbar informing the user that the fuel station has been added to their favorites.
  ///
  /// In en, this message translates to:
  /// **'Fuel station added to favorites.'**
  String get favorites_added;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
