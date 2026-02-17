import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';

class AppOpensScreen extends StatefulWidget {
  const AppOpensScreen({Key? key}) : super(key: key);

  @override
  State<AppOpensScreen> createState() => _AppOpensScreenState();
}

class _AppOpensScreenState extends State<AppOpensScreen> {
  // Use professional test ID
  final String _adUnitId = AdUtils.testId(AdType.appOpen);
  
  bool _isLoading = false;

  void _showAd(String? screenName) async {
    setState(() => _isLoading = true);
    
    await AppOpenManager.instance.show(
      context: context,
      screenName: screenName,
      screenRemote: true,
      adUnitId: _adUnitId,
      loadingDialog: true,
      reloadAfterShow: true,
      callbacks: AppOpenAdCallbacks(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('App Open Demo: Ad showed for $screenName');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('App Open Demo: Ad dismissed for $screenName');
          setState(() => _isLoading = false);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('App Open Demo: Ad failed to show for $screenName. Error: ${error.message}');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to show ad: ${error.message}')),
          );
        },
        onAdValidated: (reason) {
           debugPrint('App Open Demo: Ad blocked for $screenName. Reason: $reason');
           setState(() => _isLoading = false);
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ad blocked: $reason')),
          );
        }
      ),
    );
  }

  void _preloadAd(String? screenName) async {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preloading ad for $screenName...'), duration: const Duration(milliseconds: 500)),
    );
    
    await AppOpenManager.instance.load(
      screenName: screenName,
      screenRemote: true,
      adUnitId: _adUnitId,
      callbacks: AppOpenAdCallbacks(
        onAdLoaded: (ad) {
          debugPrint('App Open Demo: Ad preloaded successfully for $screenName');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad preloaded for $screenName')),
            );
          }
        },
        onAdFailedToLoad: (error) {
           debugPrint('App Open Demo: Ad preload failed for $screenName. Error: ${error.message}');
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ad preload failed: ${error.message}')),
            );
           }
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Open Ads Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Smart Preloading'),
            const Text(
              'App Open ads are typically shown on app start or backgrounding, but can also be triggered manually.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'On-Demand App Open',
              subtitle: 'Preload and show for a specific flow',
              icon: Icons.open_in_new,
              onPreload: () => _preloadAd('on_demand'),
              onShow: () => _showAd('on_demand'),
            ),
            _buildActionCard(
              title: 'Universal Ad',
              subtitle: 'Show ad without screen context',
              icon: Icons.public,
              onPreload: () => _preloadAd(null), // Generic load
              onShow: () => _showAd(null),
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
              leading: Icon(icon, color: Colors.blue, size: 32),
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
