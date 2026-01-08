import 'package:envied/envied.dart';

part 'env.g.dart';

// compilare con: dart run build_runner build

@Envied(path: '.env', useConstantCase: true)
abstract class Env {
  @EnviedField(obfuscate: true, varName: "GOOGLE_MAPS_SDK_ANDROID_API_KEY")
  static final String googleMapsSdkAndroidApiKey = _Env.googleMapsSdkAndroidApiKey;

  @EnviedField(obfuscate: true, varName: "GOOGLE_MAPS_SDK_IOS_API_KEY")
  static final String googleMapsSdkIosApiKey = _Env.googleMapsSdkIosApiKey;

  @EnviedField(obfuscate: true, varName: "GOOGLE_PLACES_API_KEY")
  static final String googlePlacesApiKey = _Env.googlePlacesApiKey;

  @EnviedField(obfuscate: true, varName: "GOOGLE_ROUTES_API_KEY")
  static final String googleRoutesApiKey = _Env.googleRoutesApiKey;
}
