import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class MonetizationStoreScreen extends StatefulWidget {
  const MonetizationStoreScreen({super.key});

  @override
  State<MonetizationStoreScreen> createState() => _MonetizationStoreScreenState();
}

class ShopItem {
  final String id;
  final String title;
  final String subtitle;
  final int cost;
  final IconData icon;
  final Color color;
  final String category;

  ShopItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.cost,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class _MonetizationStoreScreenState extends State<MonetizationStoreScreen> {
  int userCoins = 0;

  final List<ShopItem> storeItems = [
    ShopItem(
      id: 'skin_cyber',
      title: 'Cyberpunk Snake Skin',
      subtitle: 'Neon glowing skin for Snake & AI Pathfinder',
      cost: 150,
      icon: Icons.palette,
      color: Colors.cyanAccent,
      category: 'Skins',
    ),
    ShopItem(
      id: 'extra_life',
      title: '3x Extra Respawns',
      subtitle: 'Instant revive in Tower Defender & Space Shooter',
      cost: 100,
      icon: Icons.favorite,
      color: Colors.redAccent,
      category: 'Power-Ups',
    ),
    ShopItem(
      id: 'power_shield',
      title: 'Invincibility Shield',
      subtitle: '10 second damage shield in arcade games',
      cost: 200,
      icon: Icons.shield,
      color: Colors.amberAccent,
      category: 'Power-Ups',
    ),
    ShopItem(
      id: 'no_ads',
      title: 'Ad-Free Pass',
      subtitle: 'Remove interstitial ads permanently',
      cost: 500,
      icon: Icons.block,
      color: Colors.purpleAccent,
      category: 'Subscriptions',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  void _loadWallet() {
    setState(() {
      userCoins = StorageService.getCoins();
    });
  }

  void _buyItem(ShopItem item) async {
    bool isPurchased = StorageService.isItemPurchased(item.id);
    if (isPurchased) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You already own ${item.title}!")),
      );
      return;
    }

    bool success = await StorageService.spendCoins(item.cost);
    if (success) {
      await StorageService.setItemPurchased(item.id);
      _loadWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Successfully purchased ${item.title}!"),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Insufficient coins! Earn coins by playing games or watching ads."),
        ),
      );
    }
  }

  void _watchAdForCoins() async {
    await StorageService.addCoins(50);
    _loadWallet();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text("Reward Granted! +50 Coins added to your wallet."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("In-App Store & Monetization",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Wallet Balance Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade900, Colors.deepPurple.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.purpleAccent, blurRadius: 12)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("VIRTUAL WALLET",
                          style: GoogleFonts.outfit(
                              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.yellowAccent, size: 28),
                          const SizedBox(width: 8),
                          Text("$userCoins COINS",
                              style: GoogleFonts.outfit(
                                  color: Colors.yellowAccent,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _watchAdForCoins,
                    icon: const Icon(Icons.play_circle_fill),
                    label: Text("FREE +50 COINS",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text("In-App Store Catalog",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // Store Items List
            ...storeItems.map((item) {
              bool owned = StorageService.isItemPurchased(item.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: item.color.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(item.subtitle,
                              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: owned ? Colors.grey : item.color,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => _buyItem(item),
                      child: Text(owned ? "OWNED" : "${item.cost} COINS",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            // Monetization & Revenue Strategy Breakdown (Assignment Requirement 5)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: Colors.cyanAccent),
                      const SizedBox(width: 8),
                      Text("Monetization & Revenue Model Plan",
                          style: GoogleFonts.outfit(
                              color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRevenueBullet("1. Microtransactions (IAP)",
                      "Virtual currency bundles (\$0.99 - \$4.99) for acquiring exclusive skins, avatars, and power-up boosters."),
                  _buildRevenueBullet("2. Rewarded Video Ads",
                      "Players voluntarily view 30s video ads to earn +50 coins or instant respawns upon game over."),
                  _buildRevenueBullet("3. Premium Ad-Free Pass",
                      "One-time \$1.99 purchase removes interstitial ads permanently for enhanced user retention."),
                  _buildRevenueBullet("4. Estimated LTV & eCPM",
                      "Target eCPM: \$15.00 for Rewarded Video, Projected ARPU: \$0.45 per monthly active user."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(desc, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
