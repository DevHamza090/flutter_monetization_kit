import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';

class InterstitialsScreen extends StatefulWidget {
  const InterstitialsScreen({Key? key}) : super(key: key);

  @override
  State<InterstitialsScreen> createState() => _InterstitialsScreenState();
}

class _InterstitialsScreenState extends State<InterstitialsScreen> {
  // Use professional test ID
  final String _adUnitId = AdUtils.testId(AdType.interstitial);

  bool _isLoading = false;

  void _showAd(String screenName) async {
    setState(() => _isLoading = true);


    await EasyAds.instance.interstitial.loadNShow(
      context: context,
      screenName: screenName,
      screenRemote: true,
      adUnitId: _adUnitId,
      loadingDialog: true,
      reloadAfterShow: true,
      callbacks: InterstitialAdCallbacks(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial Demo: Ad showed for $screenName');
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to show ad: ${error.message}')),
          );
        },
        onAdValidated: (reason) {
          debugPrint(
            'Interstitial Demo: Ad blocked for $screenName. Reason: $reason',
          );
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ad blocked: $reason')));
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

    await EasyAds.instance.interstitial.load(
      screenName: screenName,
      screenRemote: true,
      adUnitId: _adUnitId,
      callbacks: InterstitialAdCallbacks(
        onAdLoaded: (ad) {
          debugPrint(
            'Interstitial Demo: Ad preloaded successfully for $screenName',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad preloaded for $screenName')),
            );
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'Interstitial Demo: Ad preload failed for $screenName. Error: ${error.message}',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad preload failed: ${error.message}')),
            );
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
              onShow: () => _showAd('dashboard'),
            ),
            _buildActionCard(
              title: 'Settings Ads',
              subtitle: 'Preload and show specifically for settings',
              icon: Icons.settings,
              onPreload: () => _preloadAd('settings'),
              onShow: () => _showAd('settings'),
            ),
            _buildActionCard(
              title: 'Universal Ad',
              subtitle: 'Show ad without screen context',
              icon: Icons.public,
              onPreload: () => _preloadAd(null.toString()), // Generic load
              onShow: () => _showAd(null.toString()),
            ),
            const Divider(height: 40),
            _buildSectionHeader('Validation & Controls'),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Toggle Premium Status'),
              subtitle: Text(
                'Current: ${AdsSettings.instance.isPremium ? "Premium" : "Free"}',
              ),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPreload,
    required VoidCallback onShow,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: Colors.orange, size: 32),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onShow,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('SHOW AD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
