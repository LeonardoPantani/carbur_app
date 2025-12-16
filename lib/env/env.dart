import 'package:envied/envied.dart';

part 'env.g.dart';

// compilare con: dart run build_runner build

@Envied(path: '.env')
abstract class Env {
  @EnviedField(obfuscate: true, varName: "GOOGLE_MAPS_SDK_API_KEY")
  static final String googleMapsSdkApiKey = _Env.googleMapsSdkApiKey;
}
