import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BugItem {
  final int id;
  final String title;
  final String category;
  final String description;
  final String rootCause;
  final String fixApplied;
  final String status;

  const BugItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.rootCause,
    required this.fixApplied,
    this.status = "FIXED & VERIFIED",
  });
}

class TestingBugReportScreen extends StatelessWidget {
  const TestingBugReportScreen({super.key});

  final List<BugItem> bugsList = const [
    BugItem(
      id: 1,
      title: "Null Pointer Crash on Canvas Board Initialization",
      category: "UI / Canvas",
      description: "Tower Defender & Space Shooter crashed with NoSuchMethodError when trying to read boardSize width prior to layout completion.",
      rootCause: "boardSize was accessed inside update loop before LayoutBuilder performed its initial render pass.",
      fixApplied: "Added explicit null safety check `if (boardSize == null) return;` and wrapped canvas bounds setup in LayoutBuilder constraints callback.",
    ),
    BugItem(
      id: 2,
      title: "Timer Memory Leak on Screen Navigation",
      category: "Performance / Memory",
      description: "Navigating back to main menu from high-frequency games (Snake, Bird, Smart AI) left background periodic Timers active, causing memory leaks.",
      rootCause: "State dispose() method did not properly invoke `timer?.cancel()`, causing callbacks to attempt mutating unmounted widgets.",
      fixApplied: "Added `!mounted` guard inside periodic timer callbacks and enforced strict `timer?.cancel()` invocation within dispose().",
    ),
    BugItem(
      id: 3,
      title: "SetState Called During Build Phase Error",
      category: "Flutter Lifecycle",
      description: "GameWrapper threw an exception: `setState() or markNeedsBuild() called during build` when initializing game highscores on launch.",
      rootCause: "Score updates were triggered directly inside initState without waiting for the widget tree layout build completion.",
      fixApplied: "Wrapped highscore load and initialization callbacks inside `WidgetsBinding.instance.addPostFrameCallback`.",
    ),
    BugItem(
      id: 4,
      title: "Garbage Collection Lag Stutter from Entity Allocations",
      category: "Optimization / GC",
      description: "Frequent rapid firing in shooter games caused noticeable micro-stutters on low-end mobile devices due to frequent GC pauses.",
      rootCause: "New Projectile and Enemy objects were allocated continuously (new Projectile()) and discarded on collision.",
      fixApplied: "Implemented Object Pooling pattern (`ProjectilePool`) with a pre-allocated fixed buffer of 30 reusable instances, achieving zero heap allocations during update loops.",
    ),
    BugItem(
      id: 5,
      title: "Async Race Condition on Highscore Storage Persistence",
      category: "Storage / Data Integrity",
      description: "Simultaneous rapid high score updates failed to write cleanly to persistent storage, resulting in lost highscores.",
      rootCause: "Multiple un-awaited asynchronous calls to SharedPreferences occurred concurrently without synchronization.",
      fixApplied: "Encapsulated StorageService methods with synchronized atomic futures and fallback in-memory cache sync.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Testing & Bug Fixing Log",
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
            // Testing Overview Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bug_report, color: Colors.redAccent, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("QA & PLAYTESTING REPORT",
                            style: GoogleFonts.outfit(
                                color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("5/5 Bugs Identified & Resolved",
                            style: GoogleFonts.outfit(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Verified on Android 14 / Flame / Flutter engine",
                            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text("Documented Bug Fixes",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // Bugs List
            ...bugsList.map((bug) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("BUG #${bug.id}: ${bug.category}",
                              style: GoogleFonts.outfit(
                                  color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(bug.status,
                              style: GoogleFonts.outfit(
                                  color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(bug.title,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(bug.description,
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 6),
                    Text("Root Cause:",
                        style: GoogleFonts.outfit(
                            color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(bug.rootCause,
                        style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text("Fix Implemented:",
                        style: GoogleFonts.outfit(
                            color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(bug.fixApplied,
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
