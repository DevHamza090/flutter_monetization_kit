import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/monetization_kit.dart';

class AppOpensScreen extends StatefulWidget {
  const AppOpensScreen({Key? key}) : super(key: key);

  @override
  State<AppOpensScreen> createState() => _AppOpensScreenState();
}

class _AppOpensScreenState extends State<AppOpensScreen> {
  // Use professional test ID
  final String _adUnitId = AdUtils.testId(AdType.appOpen);
  bool _isLoading = false;

  void _loadAndShowAd(String? screenName, {Widget? customWidget}) async {
    setState(() => _isLoading = true);

    await MonetizationKit.instance.appOpen.loadAndShow(
      context: context,
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      loadingDialog: true,
      customLoadingWidget: customWidget,
      reloadAfterShow: true,
      callbacks: AppOpenAdCallbacks(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('App Open Demo: Ad showed via LoadAndShow for $screenName');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('App Open Demo: Ad dismissed for $screenName');
          setState(() => _isLoading = false);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint(
            'App Open Demo: Ad failed to show for $screenName. Error: ${error.message}',
          );
          setState(() => _isLoading = false);
        },
        onAdValidated: (reason) {
          debugPrint('App Open Demo: Ad blocked for $screenName. Reason: $reason');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ad blocked: $reason')));
        },
      ),
    );
  }

  void _showAdIfReady(String? screenName) async {
    await MonetizationKit.instance.appOpen.show(
      context: context,
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      loadingDialog: false,
      callbacks: AppOpenAdCallbacks(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('App Open Demo: Ad showed from cache for $screenName');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('App Open Demo: Ad dismissed for $screenName');
        },
        onAdValidated: (reason) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ad not ready or blocked: $reason')),
          );
        },
      ),
    );
  }

  void _preloadAd(String? screenName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preloading ad for $screenName...'),
        duration: const Duration(milliseconds: 500),
      ),
    );

    await MonetizationKit.instance.appOpen.load(
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      callbacks: AppOpenAdCallbacks(
        onAdLoaded: (ad) {
          debugPrint(AdUtils.logLoaded(AdType.appOpen, screenName));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad preloaded for $screenName')),
            );
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint(AdUtils.logFailed(AdType.appOpen, screenName, error.message));
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
      appBar: AppBar(title: const Text('App Open Ads Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Smart Preloading'),
            const Text(
              'App Open ads are typically shown on app start or backgrounding, but can also be triggered manually with LoadAndShow.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'On-Demand App Open',
              subtitle: 'Preload or LoadAndShow for specific flow',
              icon: Icons.open_in_new,
              onPreload: () => _preloadAd('on_demand'),
              onShowReady: () => _showAdIfReady('on_demand'),
              onLoadAndShow: () => _loadAndShowAd('on_demand'),
            ),
            _buildActionCard(
              title: 'Universal Ad',
              subtitle: 'Show ad without screen context',
              icon: Icons.public,
              onPreload: () => _preloadAd(null),
              onShowReady: () => _showAdIfReady(null),
              onLoadAndShow: () => _loadAndShowAd(null),
            ),
            const Divider(height: 40),
            _buildSectionHeader('Custom Loading UI'),
            const Text(
              'You can provide a fallback widget to show while the ad is loading.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadAndShowAd(
                'custom_ui',
                customWidget: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text(
                        'Preparing your experience...',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              icon: const Icon(Icons.palette),
              label: const Text('Load & Show with Custom UI'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                foregroundColor: Colors.orange,
              ),
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
                _preloadAd('test_screen');
              },
              icon: const Icon(Icons.copy),
              label: const Text('Test Redundant Load Prevention'),
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
              leading: Icon(icon, color: Colors.blue, size: 32),
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
