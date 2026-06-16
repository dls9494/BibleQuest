import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/analytics_service.dart';

class AnalyticsDebugScreen extends StatefulWidget {
  const AnalyticsDebugScreen({super.key});

  @override
  State<AnalyticsDebugScreen> createState() => _AnalyticsDebugScreenState();
}

class _AnalyticsDebugScreenState extends State<AnalyticsDebugScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<AnalyticsEvent> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _refreshEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _refreshEvents();
    });
  }

  void _refreshEvents() {
    final allEvents = List<AnalyticsEvent>.from(AnalyticsService.debugEventLog.reversed);
    if (_searchQuery.isEmpty) {
      _filteredEvents = allEvents;
    } else {
      _filteredEvents = allEvents.where((event) {
        final matchesName = event.name.toLowerCase().contains(_searchQuery);
        final matchesParams = event.params.entries.any((entry) {
          final keyMatch = entry.key.toLowerCase().contains(_searchQuery);
          final valueMatch = entry.value?.toString().toLowerCase().contains(_searchQuery) ?? false;
          return keyMatch || valueMatch;
        });
        return matchesName || matchesParams;
      }).toList();
    }
  }

  void _clearLogs() {
    setState(() {
      AnalyticsService.debugEventLog.clear();
      _refreshEvents();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics event log cleared.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Analytics Event Log",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Clear Log",
            onPressed: _clearLogs,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh",
            onPressed: () {
              setState(() {
                _refreshEvents();
              });
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient matching settings
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Search Bar
                  _buildGlassCard(
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: textColor, fontFamily: 'Outfit'),
                        decoration: InputDecoration(
                          hintText: "Search events & parameters...",
                          hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.7)),
                          prefixIcon: Icon(Icons.search, color: subTextColor),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: subTextColor),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.analytics_outlined, size: 64, color: subTextColor.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty ? "No events recorded yet" : "No matching events found",
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 16,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredEvents.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final event = _filteredEvents[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildEventCard(event, isDark, textColor, subTextColor),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildEventCard(AnalyticsEvent event, bool isDark, Color textColor, Color subTextColor) {
    final timeStr = DateFormat('HH:mm:ss.SSS').format(event.timestamp);
    final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6);

    return _buildGlassCard(
      isDark: isDark,
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                event.name,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Logged at $timeStr",
            style: TextStyle(color: subTextColor, fontSize: 11, fontFamily: 'Outfit'),
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_down, color: subTextColor),
        childrenPadding: const EdgeInsets.all(12),
        expandedAlignment: Alignment.topLeft,
        children: [
          if (event.params.isEmpty)
            Text(
              "No parameters",
              style: TextStyle(color: subTextColor, fontStyle: FontStyle.italic, fontSize: 13, fontFamily: 'Outfit'),
            )
          else
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: event.params.entries.map((entry) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        "${entry.key}:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        entry.value?.toString() ?? 'null',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
