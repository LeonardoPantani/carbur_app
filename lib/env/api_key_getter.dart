import 'dart:io' show Platform;
import 'env.dart';

class ApiKeyGetter {
  static String get maps {
    if (Platform.isAndroid) {
      return Env.googleMapsSdkAndroidApiKey;
    }
    if (Platform.isIOS) {
      return Env.googleMapsSdkIosApiKey;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get autoCompleteMaps {
    return Env.googlePlacesApiKey;
  }

  static String get routes {
    return Env.googleRoutesApiKey;
  }
}
