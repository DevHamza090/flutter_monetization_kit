import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/monetization_kit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedIntersScreen extends StatefulWidget {
  const RewardedIntersScreen({super.key});

  @override
  State<RewardedIntersScreen> createState() => _RewardedIntersScreenState();
}

class _RewardedIntersScreenState extends State<RewardedIntersScreen> {
  final String _adUnitId = AdUtils.testId(AdType.rewardedInterstitial);
  bool _isLoading = false;
  int _diamonds = 0;

  void _loadAndShowAd(String screenName) async {
    setState(() => _isLoading = true);

    await MonetizationKit.instance.rewardedInterstitial.loadAndShow(
      context: context,
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      callbacks: RewardedInterAdCallbacks(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            'Rewarded Inter Demo: User earned reward: ${reward.amount} ${reward.type}',
          );
          setState(() => _diamonds += reward.amount.toInt());
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Rewarded Inter Demo: Ad showed via LoadAndShow for $screenName');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Rewarded Inter Demo: Ad dismissed for $screenName');
          setState(() => _isLoading = false);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint(
            'Rewarded Inter Demo: Ad failed to show for $screenName. Error: ${error.message}',
          );
          setState(() => _isLoading = false);
        },
        onAdValidated: (reason) {
          debugPrint(
            'Rewarded Inter Demo: Ad blocked for $screenName. Reason: $reason',
          );
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ad blocked: $reason')));
        },
      ),
    );
  }

  void _showAdIfReady(String screenName) async {
    await MonetizationKit.instance.rewardedInterstitial.show(
      context: context,
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      loadingDialog: false,
      callbacks: RewardedInterAdCallbacks(
        onUserEarnedReward: (ad, reward) {
          setState(() => _diamonds += reward.amount.toInt());
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Rewarded Inter Demo: Ad showed from cache for $screenName');
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

    await MonetizationKit.instance.rewardedInterstitial.load(
      screenName: screenName,
      screenRemote: true,
      androidAdUnit: _adUnitId,
      iosAdUnit: _adUnitId,
      callbacks: RewardedInterAdCallbacks(
        onAdLoaded: (ad) {
          debugPrint(
            'Rewarded Inter Demo: Ad preloaded successfully for $screenName',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad preloaded for $screenName')),
            );
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'Rewarded Inter Demo: Ad preload failed for $screenName. Error: ${error.message}',
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
      appBar: AppBar(
        title: const Text('Rewarded Interstitial Ads Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Diamonds: $_diamonds',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Smart Preloading'),
            const Text(
              'Rewarded Interstitial ads provide a higher CPM and a smoother experience by combining interstitial and reward mechanics.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Epic Loot',
              subtitle: 'Preload and show for epic loot box',
              icon: Icons.auto_awesome,
              onPreload: () => _preloadAd('epic_loot'),
              onShowReady: () => _showAdIfReady('epic_loot'),
              onLoadAndShow: () => _loadAndShowAd('epic_loot'),
            ),
            _buildActionCard(
              title: 'Continue Game',
              subtitle: 'Preload and show to revive player',
              icon: Icons.favorite,
              onPreload: () => _preloadAd('revive'),
              onShowReady: () => _showAdIfReady('revive'),
              onLoadAndShow: () => _loadAndShowAd('revive'),
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
              'Use loadAndShow to handle both loading and showing with a single call. If an ad is ready, it skips the load and shows immediately.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadAndShowAd('load_and_show_demo'),
              icon: const Icon(Icons.flash_on),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                foregroundColor: Colors.blue,
              ),
              label: const Text('One-Tap: Load & Show'),
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
