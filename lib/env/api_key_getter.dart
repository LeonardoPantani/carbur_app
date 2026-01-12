import '../services/remote_config_service.dart';

class ApiKeyGetter {
  static String get places {
    return RemoteConfigService.instance.placesApiKey;
  }

  static String get routes {
    return RemoteConfigService.instance.routesApiKey;
  }
}