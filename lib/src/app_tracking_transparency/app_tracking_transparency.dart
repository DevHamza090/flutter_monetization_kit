import 'package:flutter/services.dart';
import 'app_tracking_status.dart';

class AppTrackingTransparency {
  static const MethodChannel _channel = MethodChannel(
    'flutter_monitization_app_tracking',
  );

  /// Requests ATT authorization on iOS
  /// Returns a strongly typed [AppTrackingStatus]
  static Future<AppTrackingStatus> requestTrackingAuthorization() async {
    try {
      final String status = await _channel.invokeMethod(
        'requestTrackingAuthorization',
      );
      return status.toAppTrackingStatus();
    } on PlatformException {
      return AppTrackingStatus.unknown;
    }
  }
}
