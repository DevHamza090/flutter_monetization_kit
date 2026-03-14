import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedsScreen extends StatefulWidget {
  const RewardedsScreen({Key? key}) : super(key: key);

  @override
  State<RewardedsScreen> createState() => _RewardedsScreenState();
}

class _RewardedsScreenState extends State<RewardedsScreen> {
  final String _adUnitId = AdUtils.testId(AdType.rewarded);
  bool _isLoading = false;
  int _coins = 0;

  void _showAd(String screenName) async {
    setState(() => _isLoading = true);

    await RewardedAdManager.instance.show(
      context: context,
      screenName: screenName,
      screenRemote: true,
      adUnitId: _adUnitId,
      loadingDialog: true,
      reloadAfterShow: true,
      callbacks: RewardedAdCallbacks(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            'Rewarded Demo: User earned reward: ${reward.amount} ${reward.type}',
          );
          setState(() => _coins += reward.amount.toInt());
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Rewarded Demo: Ad showed for $screenName');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Rewarded Demo: Ad dismissed for $screenName');
          setState(() => _isLoading = false);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint(
            'Rewarded Demo: Ad failed to show for $screenName. Error: ${error.message}',
          );
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to show ad: ${error.message}')),
          );
        },
        onAdValidated: (reason) {
          debugPrint(
            'Rewarded Demo: Ad blocked for $screenName. Reason: $reason',
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

    await RewardedAdManager.instance.load(
      screenName: screenName,
      screenRemote: true,
      adUnitId: _adUnitId,
      callbacks: RewardedAdCallbacks(
        onAdLoaded: (ad) {
          debugPrint(
            'Rewarded Demo: Ad preloaded successfully for $screenName',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad preloaded for $screenName')),
            );
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'Rewarded Demo: Ad preload failed for $screenName. Error: ${error.message}',
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
        title: const Text('Rewarded Ads Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Coins: $_coins',
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
              'Rewarded ads support per-screen preloading and universal fallback, similar to interstitials.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Bonus Reward',
              subtitle: 'Preload and show for daily bonus',
              icon: Icons.card_giftcard,
              onPreload: () => _preloadAd('daily_bonus'),
              onShow: () => _showAd('daily_bonus'),
            ),
            _buildActionCard(
              title: 'Double XP',
              subtitle: 'Preload and show for XP boost',
              icon: Icons.trending_up,
              onPreload: () => _preloadAd('xp_boost'),
              onShow: () => _showAd('xp_boost'),
            ),
            _buildActionCard(
              title: 'Universal Ad',
              subtitle: 'Show ad without screen context',
              icon: Icons.public,
              onPreload: () => _preloadAd(null.toString()),
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
              leading: Icon(icon, color: Colors.green, size: 32),
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
