import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/game_model.dart';
import '../registry/game_registry.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'analytics_dashboard_screen.dart';
import 'monetization_store_screen.dart';
import 'testing_bug_report_screen.dart';
import 'deployment_showcase_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Game> allGames = GameRegistry.getGames();
  List<Game> filteredGames = [];
  String searchQuery = '';
  GameCategory? selectedCategory;
  GameMode selectedMode = GameMode.singlePlayer;
  late PageController _featuredController;

  @override
  void initState() {
    super.initState();
    _filterGames();
    _featuredController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  void _filterGames() {
    setState(() {
      filteredGames = allGames.where((game) {
        final matchesSearch = game.title.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCategory = selectedCategory == null || game.category == selectedCategory;
        final matchesMode = game.mode == selectedMode;
        return matchesSearch && matchesCategory && matchesMode;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          const Positioned.fill(child: BlockThemeBackground()),
          
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildAssignmentBar(),
              _buildModeSelector(),
              _buildFeaturedCarousel(),
              _buildSearchAndFilters(),
              _buildGamesGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          "Super Hub v3",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 0, offset: Offset(2, 2)),
              Shadow(color: AppTheme.accentArcade, blurRadius: 10, offset: Offset(0, 0)),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 10),
          child: Container(
            decoration: AppTheme.blocky(color: AppTheme.surface),
            child: IconButton(
              icon: const Icon(Icons.analytics, color: Colors.cyanAccent, size: 22),
              tooltip: "Analytics Dashboard",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 10),
          child: Container(
            decoration: AppTheme.blocky(color: AppTheme.surface),
            child: IconButton(
              icon: const Icon(Icons.store, color: Colors.yellowAccent, size: 22),
              tooltip: "In-App Store",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MonetizationStoreScreen()));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ASSIGNMENT-2 QUICK DASHBOARD",
                style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAssignmentChip(
                    "🤖 Smart AI FSM",
                    Colors.orangeAccent,
                    () {
                      final aiGame = allGames.firstWhere((g) => g.id == 'smart_ai');
                      Navigator.push(context, MaterialPageRoute(builder: aiGame.screenBuilder));
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildAssignmentChip(
                    "📊 Analytics",
                    Colors.cyanAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen())),
                  ),
                  const SizedBox(width: 8),
                  _buildAssignmentChip(
                    "💎 Store & Monetization",
                    Colors.amberAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonetizationStoreScreen())),
                  ),
                  const SizedBox(width: 8),
                  _buildAssignmentChip(
                    "🐛 Bug Report (5)",
                    Colors.redAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TestingBugReportScreen())),
                  ),
                  const SizedBox(width: 8),
                  _buildAssignmentChip(
                    "🚀 APK & Play Store",
                    Colors.greenAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeploymentShowcaseScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildModeSelector() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          decoration: AppTheme.blocky(color: Colors.black45),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMode = GameMode.singlePlayer;
                      _filterGames();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: selectedMode == GameMode.singlePlayer 
                        ? AppTheme.blocky(color: AppTheme.accentBrain) 
                        : BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text("1-PLAYER", style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, 
                      color: selectedMode == GameMode.singlePlayer ? Colors.white : Colors.white54,
                      shadows: selectedMode == GameMode.singlePlayer ? [const Shadow(color: Colors.black, offset: Offset(1,1))] : null
                    )),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMode = GameMode.multiPlayer;
                      _filterGames();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: selectedMode == GameMode.multiPlayer 
                        ? AppTheme.blocky(color: AppTheme.accentArcade) 
                        : BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text("2-PLAYER", style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, 
                      color: selectedMode == GameMode.multiPlayer ? Colors.white : Colors.white54,
                      shadows: selectedMode == GameMode.multiPlayer ? [const Shadow(color: Colors.black, offset: Offset(1,1))] : null
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    final featured = allGames.take(3).toList();
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Text("FEATURED GAMES", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 2)),
          ),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _featuredController,
              itemCount: featured.length,
              itemBuilder: (context, index) {
                final game = featured[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    decoration: AppTheme.blocky(color: game.themeColor.withValues(alpha: 0.4)).copyWith(
                      image: DecorationImage(
                        image: const NetworkImage('https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500&q=80'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(game.title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, shadows: [const Shadow(color: Colors.black, offset: Offset(2,2))])),
                              Text(game.description.length > 20 ? "${game.description.substring(0, 20)}..." : game.description, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70)),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: AppTheme.blocky(color: game.themeColor),
                            child: Text("PLAY NOW", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: AppTheme.blocky(color: AppTheme.surface),
              child: TextField(
                onChanged: (val) {
                  searchQuery = val;
                  _filterGames();
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search blocky games...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryChip(null, "All"),
                  ...GameCategory.values.map((cat) => _categoryChip(cat, _formatCategory(cat.name))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(GameCategory? category, String label) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = isSelected ? null : category;
            _filterGames();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: isSelected 
              ? AppTheme.blocky(color: AppTheme.accentPuzzle) 
              : AppTheme.blocky(color: AppTheme.surface.withValues(alpha: 0.5)),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.black : Colors.white60,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGamesGrid() {
    return AnimationLimiter(
      child: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= filteredGames.length) return null;
              final game = filteredGames[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 600),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _gameCard(game),
                  ),
                ),
              );
            },
            childCount: filteredGames.length,
          ),
        ),
      ),
    );
  }

  Widget _gameCard(Game game) {
    return GestureDetector(
      onTap: () {
        StorageService.incrementGamePlayed(game.id);
        Navigator.push(context, MaterialPageRoute(builder: game.screenBuilder));
      },
      child: Container(
        decoration: AppTheme.blocky(color: game.themeColor.withValues(alpha: 0.2)),
        child: Stack(
          children: [
            // Background subtle icon watermark
            Positioned(
              top: -10,
              right: -10,
              child: Icon(game.icon, color: Colors.white.withValues(alpha: 0.07), size: 100),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show custom logoBuilder if available, else AI image, else icon
                  if (game.logoBuilder != null)
                    game.logoBuilder!(context)
                  else if (game.imagePath != null)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: game.themeColor.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(game.imagePath!, fit: BoxFit.cover),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.blocky(color: game.themeColor),
                      child: Icon(game.icon, color: Colors.black87, size: 36),
                    ),
                  const SizedBox(height: 12),
                  Text(game.title, style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [const Shadow(color: Colors.black, offset: Offset(2,2))]
                  ), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(5)),
                    child: Text("High: ${StorageService.getHighScore(game.id)}", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class BlockThemeBackground extends StatelessWidget {
  const BlockThemeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark Base
        Container(color: AppTheme.background),
        // Grid pattern
        CustomPaint(
          painter: _GridPainter(),
          child: Container(),
        ),
        // A few floating blocky elements
        Positioned(
          top: 100,
          right: -50,
          child: Transform.rotate(
            angle: pi / 12,
            child: Container(
              width: 150,
              height: 150,
              decoration: AppTheme.blocky(color: AppTheme.accentBrain.withValues(alpha: 0.05)),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Transform.rotate(
            angle: -pi / 6,
            child: Container(
              width: 200,
              height: 200,
              decoration: AppTheme.blocky(color: AppTheme.accentArcade.withValues(alpha: 0.05)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 2;
    double step = 40; // Block size
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
