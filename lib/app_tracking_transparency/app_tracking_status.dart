enum AppTrackingStatus {
  authorized,
  denied,
  notDetermined,
  restricted,
  notSupported,
  unknown,
}

/// Extension to convert string from native iOS to enum
extension AppTrackingStatusExtension on String {
  AppTrackingStatus toAppTrackingStatus() {
    switch (this) {
      case 'authorized':
        return AppTrackingStatus.authorized;
      case 'denied':
        return AppTrackingStatus.denied;
      case 'notDetermined':
        return AppTrackingStatus.notDetermined;
      case 'restricted':
        return AppTrackingStatus.restricted;
      case 'notSupported':
        return AppTrackingStatus.notSupported;
      default:
        return AppTrackingStatus.unknown;
    }
  }
}
