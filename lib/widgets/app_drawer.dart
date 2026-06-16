import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  SharedPreferences? _prefs;
  bool _daily = true;
  bool _streak = true;
  bool _weekly = true;
  bool _monthly = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _daily = prefs.getBool('pref_notification_daily') ?? true;
        _streak = prefs.getBool('pref_notification_streak') ?? true;
        _weekly = prefs.getBool('pref_notification_weekly') ?? true;
        _monthly = prefs.getBool('pref_notification_monthly') ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoURL = context.select<UserDataProvider, String?>((p) => p.photoURL);
    final displayName = context.select<UserDataProvider, String>((p) => p.displayName);
    final username = context.select<UserDataProvider, String>((p) => p.username);
    final playerLevel = context.select<UserDataProvider, int>((p) => p.playerLevel);
    final streakDays = context.select<UserDataProvider, int>((p) => p.streakDays);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.92),
            border: Border(
              right: BorderSide(
                color: isDark ? Colors.white12 : const Color(0xFFD4A574).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drawer Header
              _buildHeader(photoURL, displayName, username, playerLevel, isDark, textColor, subTextColor),

              // Drawer Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // 1. Settings
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: "Settings",
                      onTap: () => _navigateTo(context, const SettingsScreen()),
                      textColor: textColor,
                    ),

                    // 2. Notifications (Expandable)
                    _buildNotificationsSection(textColor, subTextColor, streakDays),

                    // 3. Theme (Disabled Tile)
                    ListTile(
                      leading: Icon(Icons.palette_rounded, color: textColor.withValues(alpha: 0.4), size: 22),
                      title: Text(
                        "Theme (Coming soon)",
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      dense: true,
                    ),

                    // 4. Bookmarks
                    _buildMenuItem(
                      context,
                      icon: Icons.bookmark_rounded,
                      title: "Bookmarks",
                      onTap: () => _navigateTo(context, const BookmarksScreen()),
                      textColor: textColor,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Divider(color: Colors.white24, height: 1),
                    ),

                    // 5. Logout
                    _buildMenuItem(
                      context,
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        await FirebaseService.signOut();
                        navigator.pushNamedAndRemoveUntil('/auth', (route) => false);
                      },
                      textColor: const Color(0xFFFFB4AB),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(Color textColor, Color subTextColor, int streakDays) {
    if (_prefs == null) {
      return ListTile(
        leading: Icon(Icons.notifications_rounded, color: textColor.withValues(alpha: 0.8), size: 22),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
          ),
        ),
        dense: true,
      );
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(Icons.notifications_rounded, color: textColor.withValues(alpha: 0.8), size: 22),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
          ),
        ),
        iconColor: textColor,
        collapsedIconColor: textColor.withValues(alpha: 0.8),
        childrenPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        children: [
          _buildNotificationSwitchRow(
            "Daily Challenge",
            "Remind me every day at 8:00 AM IST",
            _daily,
            (val) async {
              await _prefs!.setBool('pref_notification_daily', val);
              setState(() {
                _daily = val;
              });
              await NotificationService.scheduleNotifications(streakDays);
            },
            textColor,
            subTextColor,
          ),
          const SizedBox(height: 12),
          _buildNotificationSwitchRow(
            "Streak Alerts",
            "Warn me before losing my daily streak at 6:00 PM IST",
            _streak,
            (val) async {
              await _prefs!.setBool('pref_notification_streak', val);
              setState(() {
                _streak = val;
              });
              await NotificationService.scheduleNotifications(streakDays);
            },
            textColor,
            subTextColor,
          ),
          const SizedBox(height: 12),
          _buildNotificationSwitchRow(
            "Weekly Challenge",
            "Notify me when the Weekly Challenge starts",
            _weekly,
            (val) async {
              await _prefs!.setBool('pref_notification_weekly', val);
              setState(() {
                _weekly = val;
              });
              await NotificationService.scheduleNotifications(streakDays);
            },
            textColor,
            subTextColor,
          ),
          const SizedBox(height: 12),
          _buildNotificationSwitchRow(
            "Monthly Challenge",
            "Notify me when the Monthly Challenge starts",
            _monthly,
            (val) async {
              await _prefs!.setBool('pref_notification_monthly', val);
              setState(() {
                _monthly = val;
              });
              await NotificationService.scheduleNotifications(streakDays);
            },
            textColor,
            subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    Color textColor,
    Color subTextColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: subTextColor, fontSize: 10, fontFamily: 'Outfit'),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFF38BDF8),
          activeTrackColor: const Color(0xFF0284C7).withValues(alpha: 0.3),
          inactiveThumbColor: const Color(0xFF6C4AB6),
          inactiveTrackColor: const Color(0xFF6C4AB6).withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildHeader(String? photoURL, String displayName, String username, int level, bool isDark, Color textColor, Color subTextColor) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFF6C4AB6).withValues(alpha: 0.08),
        border: const Border(bottom: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF0284C7),
            child: photoURL != null && photoURL.isNotEmpty
                ? ClipOval(child: _buildAvatarImage(photoURL, 64, displayName))
                : Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : "Player",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "@$username",
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontFamily: 'Outfit',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7BC64).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF7BC64).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    "Lvl $level",
                    style: const TextStyle(
                      color: Color(0xFFF7BC64),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String url, double size, String name) {
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64Str = url.split('base64,')[1];
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'P',
              style: TextStyle(color: Colors.white, fontSize: size * 0.32, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            ),
          ),
        );
      } catch (_) {}
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'P',
          style: TextStyle(color: Colors.white, fontSize: size * 0.32, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor.withValues(alpha: 0.8), size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Outfit',
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
      dense: true,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
