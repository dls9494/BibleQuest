import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/theme.dart';

/// Reader bottom toolbar with premium UX design
class ReaderBottomToolbar extends StatelessWidget {
  final String bookName;
  final int currentChapter;
  final int totalChapters;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;
  final VoidCallback onSearchPressed;
  final VoidCallback onJumpToPressed;

  const ReaderBottomToolbar({
    super.key,
    required this.bookName,
    required this.currentChapter,
    required this.totalChapters,
    required this.onPreviousChapter,
    required this.onNextChapter,
    required this.onSearchPressed,
    required this.onJumpToPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = Colors.white.withValues(alpha: 0.75);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: AppTheme.toolbarHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.toolbarCornerRadius),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.toolbarBlurSigmaX,
            sigmaY: AppTheme.toolbarBlurSigmaY,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: AppTheme.toolbarBackgroundOpacity),
              border: Border(
                top: BorderSide(
                  width: AppTheme.toolbarBorderWidth,
                  color: Colors.white.withValues(alpha: AppTheme.toolbarBorderOpacity),
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.toolbarVerticalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Chapter navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous chapter
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 28),
                      color: (currentChapter <= 1)
                          ? textColor.withValues(alpha: 0.3)
                          : AppTheme.gold,
                      tooltip: 'Previous Chapter',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: (currentChapter <= 1) ? null : onPreviousChapter,
                    ),
                    // Chapter label (centered)
                    Expanded(
                      child: Center(
                        child: Text(
                          '$bookName $currentChapter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: (currentChapter >= 1 && currentChapter <= totalChapters)
                                ? AppTheme.gold
                                : textColor,
                            letterSpacing: 0.5,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ),
                    // Next chapter
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 28),
                      color: (currentChapter >= totalChapters)
                          ? textColor.withValues(alpha: 0.3)
                          : AppTheme.gold,
                      tooltip: 'Next Chapter',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: (currentChapter >= totalChapters) ? null : onNextChapter,
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.toolbarRowGap),
                // Bottom row: Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Search button
                    TextButton.icon(
                      onPressed: onSearchPressed,
                      icon: const Icon(Icons.search, size: 22),
                      label: const Text('Search'),
                      style: TextButton.styleFrom(
                        foregroundColor: inactiveColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Jump To button
                    TextButton.icon(
                      onPressed: onJumpToPressed,
                      icon: const Icon(Icons.arrow_downward, size: 22),
                      label: const Text('Jump To'),
                      style: TextButton.styleFrom(
                        foregroundColor: inactiveColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}