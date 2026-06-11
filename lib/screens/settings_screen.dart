import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences? _prefs;
  bool _isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isLoadingPrefs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final userProvider = Provider.of<UserDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF1A1A2E), Color(0xFF0F3460)]
                    : const [Color(0xFFFDF6EC), Color(0xFFF3E7D8)],
              ),
            ),
          ),
          SafeArea(
            child: _isLoadingPrefs
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: [
                      // Section 1: Appearance
                      _buildSectionHeader("Appearance", textColor),
                      const SizedBox(height: 12),
                      _buildGlassCard(
                        isDark: isDark,
                        child: SwitchListTile(
                          title: Text(
                            "Dark Mode",
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
                          ),
                          subtitle: Text(
                            "Switch between dark and light themes",
                            style: TextStyle(color: subTextColor, fontSize: 12, fontFamily: 'Outfit'),
                          ),
                          value: themeProvider.themeMode == ThemeMode.dark,
                          activeThumbColor: const Color(0xFF38BDF8),
                          activeTrackColor: const Color(0xFF0284C7).withValues(alpha: 0.3),
                          onChanged: (val) {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Language
                      _buildSectionHeader("Content Language", textColor),
                      const SizedBox(height: 12),
                      _buildGlassCard(
                        isDark: isDark,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Choose preferred language for scripture & quizzes:",
                                style: TextStyle(color: subTextColor, fontSize: 12, fontFamily: 'Outfit'),
                              ),
                              const SizedBox(height: 12),
                              _buildLanguageOption(
                                label: "English Only",
                                mode: ContentLanguageMode.english,
                                currentMode: localeProvider.contentMode,
                                onTap: () => localeProvider.setContentMode(ContentLanguageMode.english),
                                isDark: isDark,
                                textColor: textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildLanguageOption(
                                label: "Telugu Only (తెలుగు)",
                                mode: ContentLanguageMode.telugu,
                                currentMode: localeProvider.contentMode,
                                onTap: () => localeProvider.setContentMode(ContentLanguageMode.telugu),
                                isDark: isDark,
                                textColor: textColor,
                              ),
                              const SizedBox(height: 8),
                              _buildLanguageOption(
                                label: "Bilingual (English + Telugu)",
                                mode: ContentLanguageMode.bilingual,
                                currentMode: localeProvider.contentMode,
                                onTap: () => localeProvider.setContentMode(ContentLanguageMode.bilingual),
                                isDark: isDark,
                                textColor: textColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Notifications
                      _buildSectionHeader("Notifications", textColor),
                      const SizedBox(height: 12),
                      _buildGlassCard(
                        isDark: isDark,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildNotificationRow(
                                title: "Daily Challenge Reminder",
                                subtitle: "Remind me every day at 8:00 AM IST",
                                prefKey: 'pref_notification_daily',
                                userProvider: userProvider,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildNotificationRow(
                                title: "Streak Alerts",
                                subtitle: "Warn me before losing my daily streak at 6:00 PM IST",
                                prefKey: 'pref_notification_streak',
                                userProvider: userProvider,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildNotificationRow(
                                title: "Weekly Challenge Alerts",
                                subtitle: "Notify me when the Weekly Challenge starts",
                                prefKey: 'pref_notification_weekly',
                                userProvider: userProvider,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildNotificationRow(
                                title: "Monthly Challenge Alerts",
                                subtitle: "Notify me when the Monthly Challenge starts",
                                prefKey: 'pref_notification_monthly',
                                userProvider: userProvider,
                                textColor: textColor,
                                subTextColor: subTextColor,
                              ),
                            ],
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

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFD4A574).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required ContentLanguageMode mode,
    required ContentLanguageMode currentMode,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
  }) {
    final isSelected = mode == currentMode;
    final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Outfit',
                fontSize: 14,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: accentColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationRow({
    required String title,
    required String subtitle,
    required String prefKey,
    required UserDataProvider userProvider,
    required Color textColor,
    required Color subTextColor,
  }) {
    final value = _prefs?.getBool(prefKey) ?? true;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: subTextColor, fontSize: 11, fontFamily: 'Outfit'),
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
          onChanged: (val) async {
            if (_prefs != null) {
              await _prefs!.setBool(prefKey, val);
              setState(() {});
              await NotificationService.scheduleNotifications(userProvider.streakDays);
            }
          },
        ),
      ],
    );
  }
}
