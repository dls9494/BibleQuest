import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../services/verse_of_the_day.dart';
import '../services/audio_service.dart';
import '../providers/locale_provider.dart';

class VerseOfTheDayCard extends StatefulWidget {
  final DailyVerse verse;
  final VoidCallback onDismiss;

  const VerseOfTheDayCard({
    super.key,
    required this.verse,
    required this.onDismiss,
  });

  @override
  State<VerseOfTheDayCard> createState() => _VerseOfTheDayCardState();
}

class _VerseOfTheDayCardState extends State<VerseOfTheDayCard> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AudioService.setHandlers(
      onStart: () {
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _isLoading = false;
          });
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _isLoading = false;
          });
        }
      },
      onError: () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await AudioService.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      
      final lp = Provider.of<LocaleProvider>(context, listen: false);
      final isTelugu = lp.contentMode == ContentLanguageMode.telugu || lp.contentMode == ContentLanguageMode.bilingual;
      final textToSpeak = isTelugu && widget.verse.verseTe.isNotEmpty ? widget.verse.verseTe : widget.verse.verseEn;
      final localeToSpeak = isTelugu && widget.verse.verseTe.isNotEmpty ? 'te-IN' : 'en-US';

      await AudioService.stop();
      await AudioService.speak(textToSpeak, language: localeToSpeak);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
        });
      }
    }
  }

  Color _getTopicColor(String topic) {
    switch (topic.toLowerCase()) {
      case 'love':
        return const Color(0xFFEC4899); // Pink
      case 'grace':
        return const Color(0xFF8B5CF6); // Violet
      case 'faith':
        return const Color(0xFF3B82F6); // Blue
      case 'trust':
        return const Color(0xFF10B981); // Emerald
      case 'hope':
        return const Color(0xFFF59E0B); // Amber
      case 'strength':
        return const Color(0xFFEF4444); // Red
      case 'courage':
        return const Color(0xFFF97316); // Orange
      case 'wisdom':
        return const Color(0xFF06B6D4); // Cyan
      case 'guidance':
        return const Color(0xFF14B8A6); // Teal
      case 'peace':
        return const Color(0xFF6366F1); // Indigo
      case 'rest':
        return const Color(0xFF84CC16); // Lime
      default:
        return const Color(0xFF38BDF8); // Sky blue
    }
  }

  void _copyToClipboard(BuildContext context) {
    final formattedText = '''
📖 Verse of the Day - Telugu Bible Quiz

"${widget.verse.verseEn}"
(${widget.verse.referenceEn})

"${widget.verse.verseTe}"
(${widget.verse.referenceTe})

Play Telugu Bible Quiz and learn more! 📱
''';

    final messenger = ScaffoldMessenger.of(context);
    Clipboard.setData(ClipboardData(text: formattedText)).then((_) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                'Verse copied to clipboard!',
                style: TextStyle(fontFamily: 'Outfit'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Future<void> _shareAsImage() async {
    setState(() {
      _isSharing = true;
    });

    // Wait for the UI to update and hide the buttons
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("Could not find card repaint boundary");

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) throw Exception("Failed to convert image to byte data");
      
      final pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/verse_of_the_day.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Verse of the Day / నేటి దైవ వాక్యం 📖\nPlay Telugu Bible Quiz and learn more! 📱',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Error sharing image: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final verse = widget.verse;
    final topicColor = _getTopicColor(verse.topic);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF5D4037);
    final referenceColor = isDark ? Colors.amber.shade200.withValues(alpha: 0.8) : const Color(0xFFB57C1E);
    final iconColor = isDark ? Colors.amber : const Color(0xFFB57C1E);
    final buttonTextColor = isDark ? Colors.white70 : const Color(0xFF5D4037);

    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: isDark ? 12.0 : 0, sigmaY: isDark ? 12.0 : 0),
            child: Container(
              decoration: BoxDecoration(
                // When sharing, force a beautiful gradient background!
                gradient: _isSharing
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1A1A2E), const Color(0xFF0F3460), const Color(0xFF16162B)]
                            : [const Color(0xFFFDF6EC), const Color(0xFFF5E6D3), const Color(0xFFEAD8C3)],
                      )
                    : null,
                color: _isSharing
                    ? null
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.amber.shade200.withValues(alpha: 0.5)
                      : const Color(0xFFD4A574).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 8.0, 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: iconColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Verse of the Day",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        // Open Bible Icon (shown in top right)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                        if (!_isSharing) ...[
                          const SizedBox(width: 4),
                          // Close / Dismiss button
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark ? Colors.white60 : const Color(0xFF8D7B9D),
                              size: 20,
                            ),
                            onPressed: widget.onDismiss,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 16,
                            tooltip: "Dismiss",
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD4A574).withValues(alpha: 0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),

                  // Verse Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Topic Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: topicColor.withValues(alpha: isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: topicColor.withValues(alpha: isDark ? 0.4 : 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                verse.topic.toUpperCase(),
                                style: TextStyle(
                                  color: topicColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Telugu Verse Text
                        Text(
                          verse.verseTe,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            height: 1.6,
                            fontFamily: 'NotoSerifTelugu',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Telugu Reference
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "(${verse.referenceTe})",
                            style: TextStyle(
                              color: referenceColor,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'NotoSerifTelugu',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // English Verse Text
                        Text(
                          verse.verseEn,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 15,
                            height: 1.5,
                            fontFamily: 'NotoSerif',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // English Reference
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "(${verse.referenceEn})",
                            style: TextStyle(
                              color: referenceColor,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'NotoSerif',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // App Branding (Visible during sharing or always)
                  if (_isSharing) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Divider(color: isDark ? Colors.white24 : const Color(0xFFD4A574).withValues(alpha: 0.3)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Telugu Bible Quiz",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.play_circle_fill_rounded, color: iconColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Play & Learn daily!",
                                style: TextStyle(
                                  color: referenceColor,
                                  fontSize: 11,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Actions footer
                  if (!_isSharing)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Copy Button
                              TextButton.icon(
                                onPressed: () => _copyToClipboard(context),
                                icon: Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: buttonTextColor,
                                ),
                                label: Text(
                                  "Copy",
                                  style: TextStyle(
                                    color: buttonTextColor,
                                    fontSize: 12,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // TTS Listen/Speak Button
                              Tooltip(
                                message: "Listen to verse",
                                child: TextButton.icon(
                                  onPressed: _toggleAudio,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.amber,
                                          ),
                                        )
                                      : Icon(
                                          _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                          size: 16,
                                          color: _isPlaying ? Colors.amber : buttonTextColor,
                                        ),
                                  label: Text(
                                    _isPlaying ? "Stop" : "Listen",
                                    style: TextStyle(
                                      color: _isPlaying ? Colors.amber : buttonTextColor,
                                      fontSize: 12,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Share Button
                          TextButton.icon(
                            onPressed: _shareAsImage,
                            icon: Icon(
                              Icons.share_rounded,
                              size: 16,
                              color: isDark ? Colors.amber : const Color(0xFF6C4AB6),
                            ),
                            label: Text(
                              "Share Image",
                              style: TextStyle(
                                color: isDark ? Colors.amber : const Color(0xFF6C4AB6),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: isDark ? Colors.amber.withValues(alpha: 0.1) : const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
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
