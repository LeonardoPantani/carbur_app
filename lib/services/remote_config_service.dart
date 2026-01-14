import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  static RemoteConfigService get instance => _instance;

  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // api keys
  static const _kPlacesKey = 'google_places_key';
  static const _kRoutesKey = 'google_routes_key';

  // boolean values
  static const _kShowBottomAd = 'show_bottom_banner';
  static const _kShowInterstitialAd = 'show_interstitial_details_close_ad';
  static const _kShowListAd = 'show_list_ad';

  // integer values
  static const _kListAdFrequency = 'list_ad_frequency';

  // string values
  static const _kBottomBannerAdTabs = 'bottom_banner_tabs';

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 1) : const Duration(hours: 24),
      ));

      await _remoteConfig.setDefaults({
        _kPlacesKey: '',
        _kRoutesKey: '',
        _kShowBottomAd: false,
        _kBottomBannerAdTabs: "0,2",
        _kShowInterstitialAd: false,
        _kShowListAd: false,
        _kListAdFrequency: 0,
      });
      await _remoteConfig.fetchAndActivate();
      logger.i('Remote Config fetched successfully');
    } catch (e) {
      logger.i('Errore nel fetch di Remote Config: $e');
    }
  }

  String get placesApiKey => _remoteConfig.getString(_kPlacesKey);
  String get routesApiKey => _remoteConfig.getString(_kRoutesKey);
  bool get showBottomAd => _remoteConfig.getBool(_kShowBottomAd);
  String get bottomBannerAdTabs => _remoteConfig.getString(_kBottomBannerAdTabs);
  bool get showInterstitialAd => _remoteConfig.getBool(_kShowInterstitialAd);
  bool get showListAd => _remoteConfig.getBool(_kShowListAd);
  int get listAdFrequency => _remoteConfig.getInt(_kListAdFrequency);
}