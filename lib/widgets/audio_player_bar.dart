import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart' as as_pkg;
import '../services/audio_service.dart';

class AudioPlayerBar extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final VoidCallback onSnapToVerse;

  const AudioPlayerBar({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.onSnapToVerse,
  });

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: widget.isVisible ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isVisible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !widget.isVisible,
          child: _buildBarContent(),
        ),
      ),
    );
  }

  Widget _buildBarContent() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF7BC64).withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Verse reference
                  Expanded(
                    child: StreamBuilder<as_pkg.MediaItem?>(
                      stream: AudioService.instance.mediaItem,
                      builder: (context, snapshot) {
                        final item = snapshot.data;
                        return Text(
                          item?.title ?? 'Bible',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Outfit',
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Snap to verse button
                  StreamBuilder<Map<String, int>>(
                    stream: AudioService.instance.onVerseChanged,
                    initialData: AudioService.instance.currentVerseInfo,
                    builder: (context, snapshot) {
                      return IconButton(
                        icon: const Icon(
                          Icons.my_location_rounded,
                          color: Color(0xFFF7BC64),
                          size: 18,
                        ),
                        onPressed: widget.onSnapToVerse,
                        tooltip: 'Snap to current verse',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        splashRadius: 16,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  // Play/Pause
                  StreamBuilder<as_pkg.PlaybackState>(
                    stream: AudioService.instance.playbackState,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      return GestureDetector(
                        onTap: () {
                          if (isPlaying) {
                            AudioService.instance.pause();
                          } else {
                            AudioService.instance.play();
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7BC64),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFF7BC64),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Progress text
                  StreamBuilder<Map<String, int>>(
                    stream: AudioService.instance.onVerseChanged,
                    initialData: AudioService.instance.currentVerseInfo,
                    builder: (context, snapshot) {
                      final info = snapshot.data;
                      final current = (info?['current'] ?? 0) + 1;
                      final total = info?['total'] ?? 0;
                      return Text(
                        '$current/$total',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontFamily: 'Outfit',
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Skip back
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => AudioService.instance.skipToPrevious(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashRadius: 18,
                  ),
                  const SizedBox(width: 2),
                  // Skip forward
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => AudioService.instance.skipToNext(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashRadius: 18,
                  ),
                  const SizedBox(width: 6),
                  // Speed pill
                  StreamBuilder<as_pkg.PlaybackState>(
                    stream: AudioService.instance.playbackState,
                    builder: (context, snapshot) {
                      final speed = snapshot.data?.speed ?? 1.0;
                      return InkWell(
                        onTap: () {
                          const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
                          int nextIdx = speeds.indexOf(speed) + 1;
                          if (nextIdx >= speeds.length) nextIdx = 0;
                          AudioService.instance.setSpeed(speeds[nextIdx]);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            '${speed}x',
                            style: const TextStyle(
                              color: Color(0xFFF7BC64),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  // Auto-advance toggle
                  IconButton(
                    icon: Icon(
                      Icons.repeat_rounded,
                      color: AudioService.instance.autoAdvance
                          ? const Color(0xFF4ADE80)
                          : Colors.white38,
                      size: 20,
                    ),
                    onPressed: () async {
                      final newval = !AudioService.instance.autoAdvance;
                      await AudioService.instance.setAutoAdvance(newval);
                      if (mounted) setState(() {});
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    splashRadius: 16,
                    tooltip: 'Auto-Advance Chapters',
                  ),
                  const SizedBox(width: 2),
                  // Stop/Close
                  IconButton(
                    icon: const Icon(
                      Icons.stop_rounded,
                      color: Color(0xFFF7BC64),
                      size: 22,
                    ),
                    onPressed: () {
                      AudioService.instance.stop();
                      widget.onClose();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    splashRadius: 16,
                    tooltip: 'Stop',
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
