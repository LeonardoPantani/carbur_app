import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import 'env.dart';

class ApiKeyGetter {
  static String get maps {
    if (kIsWeb) {
      return Env.googleMapsJsApiKey;
    }
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
