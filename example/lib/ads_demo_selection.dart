import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit_example/app_opens.dart';
import 'package:flutter_monetization_kit_example/rewarded_inters.dart';
import 'package:flutter_monetization_kit_example/rewardeds.dart';

import 'banners.dart';
import 'interstitials.dart';

class AdsDemoSelection extends StatelessWidget {
  const AdsDemoSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Monetization Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAdButton(
            context,
            title: 'Banner Ads',
            icon: Icons.ad_units,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BannersScreen()),
            ),
          ),
          _buildAdButton(
            context,
            title: 'Interstitial Ads',
            icon: Icons.fullscreen,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InterstitialsScreen()),
            ),
          ),
          _buildAdButton(
            context,
            title: 'Native Ads',
            icon: Icons.article,
            color: Colors.green,
            onTap: () {
              // TODO: Implement Native Demo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Native Demo coming soon')),
              );
            },
          ),
          _buildAdButton(
            context,
            title: 'Rewarded Ads',
            icon: Icons.video_library,
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RewardedsScreen()),
            ),
          ),
          _buildAdButton(
            context,
            title: 'Rewarded Interstitial',
            icon: Icons.video_stable,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RewardedIntersScreen()),
            ),
          ),
          _buildAdButton(
            context,
            title: 'App Open Ads',
            icon: Icons.launch,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppOpensScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
