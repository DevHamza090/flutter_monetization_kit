import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_monetization_kit_method_channel.dart';

abstract class FlutterMonetizationKitPlatform extends PlatformInterface {
  /// Constructs a FlutterMonetizationKitPlatform.
  FlutterMonetizationKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMonetizationKitPlatform _instance =
      MethodChannelFlutterMonetizationKit();

  /// The default instance of [FlutterMonetizationKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMonetizationKit].
  static FlutterMonetizationKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMonetizationKitPlatform] when
  /// they register themselves.
  static set instance(FlutterMonetizationKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
