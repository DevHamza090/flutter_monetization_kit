import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/monetization_kit.dart';

class InterstitialsScreen extends StatefulWidget {
  const InterstitialsScreen({Key? key}) : super(key: key);

  @override
  State<InterstitialsScreen> createState() => _InterstitialsScreenState();
}

class _InterstitialsScreenState extends State<InterstitialsScreen> {
  // Use professional test ID
  final String _adUnitId = AdUtils.testId(AdType.interstitial);

  bool _isLoading = false;

  void _loadAndShowAd(String screenName) async {
    setState(() => _isLoading = true);

    await MonetizationKit.instance.interstitial.loadAndShow(
      context: context,
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      loadingDialog: true,
      reloadAfterShow: true,
      callbacks: InterstitialAdCallbacks(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial Demo: Ad showed via LoadAndShow for $screenName');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial Demo: Ad dismissed for $screenName');
          setState(() => _isLoading = false);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint(
            'Interstitial Demo: Ad failed to show for $screenName. Error: ${error.message}',
          );
          setState(() => _isLoading = false);
        },
        onAdValidated: (reason) {
          debugPrint('Interstitial Demo: Ad blocked for $screenName. Reason: $reason');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ad blocked: $reason')));
        },
      ),
    );
  }

  void _showAdIfReady(String screenName) async {
    await MonetizationKit.instance.interstitial.show(
      context: context,
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      loadingDialog: false, // Don't show loading dialog for direct show
      callbacks: InterstitialAdCallbacks(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial Demo: Ad showed from cache for $screenName');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial Demo: Ad dismissed for $screenName');
        },
        onAdValidated: (reason) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ad not ready or blocked: $reason')),
          );
        },
      ),
    );
  }

  void _preloadAd(String screenName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preloading ad for $screenName...'),
        duration: const Duration(milliseconds: 500),
      ),
    );

    await MonetizationKit.instance.interstitial.load(
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      callbacks: InterstitialAdCallbacks(
        onAdLoaded: (ad) {
          debugPrint('Interstitial Demo: Ad preloaded successfully for $screenName');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Ad preloaded for $screenName')));
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'Interstitial Demo: Ad preload failed for $screenName. Error: ${error.message}',
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Ad preload failed: ${error.message}')));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interstitial Ads Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Smart Preloading'),
            const Text(
              'The manager supports preloading ads per screen and falling back to a universal ad unit if specific ones aren\'t ready.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Dashboard Ads',
              subtitle: 'Preload and show specifically for dashboard',
              icon: Icons.dashboard,
              onPreload: () => _preloadAd('dashboard'),
              onShowReady: () => _showAdIfReady('dashboard'),
              onLoadAndShow: () => _loadAndShowAd('dashboard'),
            ),
            _buildActionCard(
              title: 'Settings Ads',
              subtitle: 'Preload and show specifically for settings',
              icon: Icons.settings,
              onPreload: () => _preloadAd('settings'),
              onShowReady: () => _showAdIfReady('settings'),
              onLoadAndShow: () => _loadAndShowAd('settings'),
            ),
            _buildActionCard(
              title: 'Universal Ad',
              subtitle: 'Show ad without screen context',
              icon: Icons.public,
              onPreload: () => _preloadAd(null.toString()),
              onShowReady: () => _showAdIfReady(null.toString()),
              onLoadAndShow: () => _loadAndShowAd(null.toString()),
            ),
            const Divider(height: 40),
            _buildSectionHeader('Convenience Method'),
            const Text(
              'Use loadAndShow to handle both loading and showing with a single call. If the ad is already ready, it shows immediately.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadAndShowAd('load_and_show_demo'),
              icon: const Icon(Icons.flash_on),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                foregroundColor: Colors.orange,
              ),
              label: const Text('One-Tap: Load & Show'),
            ),
            const Divider(height: 40),
            _buildSectionHeader('Validation & Controls'),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Toggle Premium Status'),
              subtitle: Text('Current: ${AdsSettings.instance.isPremium ? "Premium" : "Free"}'),
              trailing: Switch(
                value: AdsSettings.instance.isPremium,
                onChanged: (val) {
                  setState(() => AdsSettings.instance.setPremium(val));
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _preloadAd('test_screen');
                _preloadAd('test_screen'); // Intentional duplicate
              },
              icon: const Icon(Icons.copy),
              label: const Text('Test Redundant Load Prevention'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Check debug console to see logs for "Already Loading" or "Ad already loaded" prevention.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPreload,
    required VoidCallback onShowReady,
    required VoidCallback onLoadAndShow,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: Colors.orange, size: 32),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitle),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onPreload,
                  icon: const Icon(Icons.download),
                  label: const Text('PRELOAD'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onShowReady,
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('SHOW'),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: onLoadAndShow,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('L&S'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
