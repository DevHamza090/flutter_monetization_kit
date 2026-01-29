import Foundation
import AppTrackingTransparency
import AdSupport

public class ATTManager {

    /// Requests App Tracking Transparency authorization
    /// Returns the status as a String
    public static func requestAuthorization(completion: @escaping (String) -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion("authorized")
                    case .denied:
                        completion("denied")
                    case .notDetermined:
                        completion("notDetermined")
                    case .restricted:
                        completion("restricted")
                    @unknown default:
                        completion("unknown")
                    }
                }
            }
        } else {
            // ATT not required on iOS < 14
            completion("notSupported")
        }
    }
}
