import 'package:envied/envied.dart';

part 'env.g.dart';

// compilare con: dart run build_runner build

@Envied(path: '.env', useConstantCase: true)
abstract class Env {
  @EnviedField(obfuscate: true)
  static final String googleMapsSdkApiKey = _Env.googleMapsSdkApiKey;
}
