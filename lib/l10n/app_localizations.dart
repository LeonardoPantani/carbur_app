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

  /// Last update date and time for a fuel station.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
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
