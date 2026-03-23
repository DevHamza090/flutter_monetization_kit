import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A professional Google Consent Manager that utilizes the User Messaging Platform
/// (UMP) SDK to handle app user consent requests, specifically for GDPR compliance.
class GoogleConsentManager {
  // Private constructor to enforce singleton pattern
  GoogleConsentManager._internal();

  /// The single instance of [GoogleConsentManager].
  static final GoogleConsentManager instance = GoogleConsentManager._internal();

  /// Requests user consent and shows the consent form if required.
  ///
  /// [testIdentifiers] can be provided to simulate specific geography for testing
  /// (e.g., simulating EEA location to test the consent flow).
  /// [onConsentGatheringCompleteListener] is called when the gathering process
  /// completes. If an error occurs, the error message is passed; otherwise, null.
  void gatherConsent({
    List<String>? testIdentifiers,
    required void Function(String? error) onConsentGatheringCompleteListener,
  }) {
    ConsentDebugSettings? debugSettings;

    // In debug mode, optionally simulate being in the EEA to test the consent flow.
    if (kDebugMode && testIdentifiers != null && testIdentifiers.isNotEmpty) {
      debugSettings = ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
        testIdentifiers: testIdentifiers,
      );
    }

    final params = ConsentRequestParameters(
      consentDebugSettings: debugSettings,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        // The consent information state was updated.
        // You are now ready to check if a form is available.
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadAndShowConsentFormIfRequired(onConsentGatheringCompleteListener);
        } else {
          // No form available, consent gathering complete.
          onConsentGatheringCompleteListener(null);
        }
      },
      (FormError error) {
        // Handle the error.
        onConsentGatheringCompleteListener(error.message);
      },
    );
  }

  /// Loads and displays the consent form if the current consent status is "required".
  void _loadAndShowConsentFormIfRequired(
    void Function(String? error) onConsentGatheringCompleteListener,
  ) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        final status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? formError) {
            if (formError != null) {
              // Failed to show the form.
              onConsentGatheringCompleteListener(formError.message);
            } else {
              // After the user makes a choice, check if they need to be shown the form again
              // or if consent gathering is fully complete.
              _loadAndShowConsentFormIfRequired(onConsentGatheringCompleteListener);
            }
          });
        } else {
          // Consent has been gathered or is not required.
          onConsentGatheringCompleteListener(null);
        }
      },
      (FormError formError) {
        // Failed to load the form.
        onConsentGatheringCompleteListener(formError.message);
      },
    );
  }

  /// Checks if the privacy options form is required.
  ///
  /// This is typically required for users in the EEA to comply with the GDPR.
  /// If true, a button should be presented to the user to modify their privacy choices.
  Future<bool> isPrivacyOptionsRequired() async {
    return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  /// Indicates whether the app is allowed to request ads based on the user's consent status.
  /// Return true if the user has provided consent or if consent is not required (e.g. outside EEA).
  Future<bool> canRequestAds() async {
    return await ConsentInformation.instance.canRequestAds();
  }

  /// Presents the privacy options form to the user.
  ///
  /// This allows users to change their previous consent choices at any time.
  /// The [onConsentFormDismissedListener] is invoked when the form is dismissed, passing
  /// an error message if an error occurred, or null on success.
  void showPrivacyOptionsForm(
    void Function(String? error) onConsentFormDismissedListener,
  ) {
    ConsentForm.showPrivacyOptionsForm((FormError? formError) {
      onConsentFormDismissedListener(formError?.message);
    });
  }
}
