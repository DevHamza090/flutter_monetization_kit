import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_monetization_kit/flutter_monetization_kit.dart';
import 'package:flutter_monetization_kit/flutter_monetization_kit_platform_interface.dart';
import 'package:flutter_monetization_kit/flutter_monetization_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMonetizationKitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterMonetizationKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterMonetizationKitPlatform initialPlatform = FlutterMonetizationKitPlatform.instance;

  test('$MethodChannelFlutterMonetizationKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMonetizationKit>());
  });

  test('getPlatformVersion', () async {
    FlutterMonetizationKit flutterMonetizationKitPlugin = FlutterMonetizationKit();
    MockFlutterMonetizationKitPlatform fakePlatform = MockFlutterMonetizationKitPlatform();
    FlutterMonetizationKitPlatform.instance = fakePlatform;

    expect(await flutterMonetizationKitPlugin.getPlatformVersion(), '42');
  });
}
