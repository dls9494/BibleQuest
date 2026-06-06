import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import 'quiz_tab.dart';
import 'bible_screen.dart';
import 'leaderboard_screen.dart';
import 'challenges_screen.dart';
import 'prayer_wall_screen.dart';
import 'profile_screen.dart';
import '../widgets/miracle_box_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = const [
    BibleScreen(),
    QuizTab(),
    LeaderboardScreen(),
    ChallengesScreen(),
    PrayerWallScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final uid = await FirebaseService.getCurrentUserUid();
    if (uid == null && mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  bool _isMiracleBoxDialogOpen = false;

  void _showMiracleBoxDialog() {
    if (_isMiracleBoxDialogOpen) return;
    _isMiracleBoxDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MiracleBoxDialog(),
    ).then((_) {
      _isMiracleBoxDialogOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    if (userProvider.pendingMiracleBox) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMiracleBoxDialog();
      });
    }
    return Scaffold(
      extendBody: true, // Allows content to show behind the bottom nav bar
      body: IndexedStack(
        index: userProvider.tabIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(userProvider),
    );
  }

  Widget _buildBottomNav(UserDataProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFD4A574).withValues(alpha: 0.4),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.menu_book, "Bible", userProvider),
                  _buildNavItem(1, Icons.quiz, "Quiz", userProvider),
                  _buildNavItem(2, Icons.leaderboard, "Leaderboard", userProvider),
                  _buildNavItem(3, Icons.emoji_events, "Challenges", userProvider),
                  _buildNavItem(4, Icons.church, "Prayer", userProvider),
                  _buildNavItem(5, Icons.person, "Profile", userProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, UserDataProvider userProvider) {
    final isSelected = userProvider.tabIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final activeIndicatorColor = isDark
        ? const Color(0xFF0284C7).withValues(alpha: 0.2)
        : const Color(0xFF6C4AB6).withValues(alpha: 0.15);
    final activeShadowColor = isDark
        ? const Color(0xFF0284C7).withValues(alpha: 0.3)
        : const Color(0xFF6C4AB6).withValues(alpha: 0.2);
    final selectedColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6);
    final unselectedColor = isDark ? const Color(0xFF958E9D) : const Color(0xFF8D7B9D);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label Tab',
      child: GestureDetector(
        onTap: () {
          userProvider.setTabIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: activeIndicatorColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: activeShadowColor,
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
