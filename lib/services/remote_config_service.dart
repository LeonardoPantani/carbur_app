import 'dart:io';

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
  static const _kInterstitialMinInterval = 'interstitial_min_interval_minutes';

  // string values
  static const _kBottomBannerAdTabs = 'bottom_banner_tabs';
  static const _kAndroidBannerId = 'android_ad_banner_unitid';
  static const _kIosBannerId = 'ios_ad_banner_unitid';
  static const _kAndroidInterstitialId = 'android_ad_interstitial_unitid';
  static const _kIosInterstitialId = 'ios_ad_interstitial_unitid';

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
        _kInterstitialMinInterval: 0,
        _kShowListAd: false,
        _kListAdFrequency: 0,
        _kAndroidBannerId: 'ca-app-pub-3940256099942544/6300978111',
        _kIosBannerId: 'ca-app-pub-3940256099942544/2934735716',
        _kAndroidInterstitialId: 'ca-app-pub-3940256099942544/1033173712',
        _kIosInterstitialId: 'ca-app-pub-3940256099942544/4411468910',
      });
      await _remoteConfig.fetchAndActivate();
      logger.i('Remote Config fetched successfully');
    } catch (e) {
      logger.i('Errore nel fetch di Remote Config: $e');
    }
  }

  // api keys
  String get placesApiKey => _remoteConfig.getString(_kPlacesKey);
  String get routesApiKey => _remoteConfig.getString(_kRoutesKey);

  // bool
  bool get showBottomAd => _remoteConfig.getBool(_kShowBottomAd);
  bool get showInterstitialAd => _remoteConfig.getBool(_kShowInterstitialAd);
  bool get showListAd => _remoteConfig.getBool(_kShowListAd);

  // integer
  int get listAdFrequency => _remoteConfig.getInt(_kListAdFrequency);
  int get interstitialMinInterval => _remoteConfig.getInt(_kInterstitialMinInterval);

  // string
  String get bottomBannerAdTabs => _remoteConfig.getString(_kBottomBannerAdTabs);
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _remoteConfig.getString(_kAndroidBannerId);
    } else {
      return _remoteConfig.getString(_kIosBannerId);
    }
  }
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _remoteConfig.getString(_kAndroidInterstitialId);
    } else {
      return _remoteConfig.getString(_kIosInterstitialId);
    }
  }
}