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

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 1) : const Duration(hours: 24),
      ));

      await _remoteConfig.setDefaults({
        _kPlacesKey: '',
        _kRoutesKey: '',
      });
      await _remoteConfig.fetchAndActivate();
      logger.i('Remote Config fetched successfully');
    } catch (e) {
      logger.i('Errore nel fetch di Remote Config: $e');
    }
  }

  String get placesApiKey => _remoteConfig.getString(_kPlacesKey);
  String get routesApiKey => _remoteConfig.getString(_kRoutesKey);
}