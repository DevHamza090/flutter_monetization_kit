import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_monetization_kit_platform_interface.dart';

/// An implementation of [FlutterMonetizationKitPlatform] that uses method channels.
class MethodChannelFlutterMonetizationKit extends FlutterMonetizationKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_monetization_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
