import 'flutter_monetization_kit_platform_interface.dart';

class FlutterMonetizationKit {
  Future<String?> getPlatformVersion() {
    return FlutterMonetizationKitPlatform.instance.getPlatformVersion();
  }
}
