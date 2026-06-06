import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/live_event_screen.dart';

class LiveEventCard extends StatefulWidget {
  const LiveEventCard({super.key});

  @override
  State<LiveEventCard> createState() => _LiveEventCardState();
}

class _LiveEventCardState extends State<LiveEventCard> {
  Timer? _timer;
  bool _isLive = false;
  bool _visible = false;
  Duration _timeToStart = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateStatus() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // IST
    final isLive = now.hour == 20 && now.minute >= 0 && now.minute < 15;
    
    // Show card if time is between 7:45 PM and 8:30 PM IST (so 19:45 to 20:30)
    final minutesSinceMidnight = now.hour * 60 + now.minute;
    final startWindow = 19 * 60 + 45; // 7:45 PM
    final endWindow = 20 * 60 + 30;   // 8:30 PM
    final visible = minutesSinceMidnight >= startWindow && minutesSinceMidnight <= endWindow;

    DateTime targetTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (now.hour > 20 || (now.hour == 20 && now.minute >= 15)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }
    final difference = targetTime.difference(now);

    if (mounted) {
      setState(() {
        _isLive = isLive;
        _visible = visible;
        _timeToStart = difference;
      });
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF5D4037);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 12.0 : 0, sigmaY: isDark ? 12.0 : 0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.6), // Red border for live card
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.radio_button_checked_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isLive ? "🔴 LIVE NOW" : "🔴 Daily Live Quiz",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLive) ...[
                    Text(
                      "Tonight's event is active!",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "10 Questions, One Champion. Join now to compete in real time!",
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                        height: 1.4,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ] else ...[
                    Text(
                      "Starts in: ${_formatDuration(_timeToStart)}",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Daily live competitive event starts at 8:00 PM IST. Get ready!",
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                        height: 1.4,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LiveEventScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLive ? "Enter Live Event" : "View Event Schedule",
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
