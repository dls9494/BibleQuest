import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../constants/theme.dart';

/// Continue Reading card with premium UX design
class ContinueReadingCard extends StatelessWidget {
  final String bookName;
  final int chapter;
  final int verse;
  final DateTime lastOpened;

  const ContinueReadingCard({
    super.key,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.lastOpened,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String verseReference = '$bookName $chapter:$verse';
    final String relativeTime = timeago.format(lastOpened);

    return AnimatedContainer(
      duration: AppTheme.continueReadingTapAnimationDuration,
      curve: AppTheme.kAnimCurve,
      transform: Matrix4.identity(),
      child: GestureDetector(
        onTapDown: (_) {
          // Scale down effect on tap
        },
        onTapUp: (_) {
          // Scale up effect on release
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(
                AppTheme.continueReadingCardBorderRadius),
            border: Border.all(
              color: Colors.white.withValues(
                  alpha: AppTheme.continueReadingCardBorderOpacity),
              width: AppTheme.continueReadingCardBorderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                AppTheme.continueReadingCardBorderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Handle tap - navigation would be handled by parent
                  },
                  borderRadius: BorderRadius.circular(
                      AppTheme.continueReadingCardBorderRadius),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.continueReadingCardHorizontalPadding,
                      vertical: AppTheme.continueReadingCardVerticalPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Continue Reading label
                              Text(
                                'Continue Reading',
                                style: TextStyle(
                                  fontSize:
                                      AppTheme.continueReadingLabelFontSize,
                                  letterSpacing:
                                      AppTheme.continueReadingLabelLetterSpacing,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Verse reference (large focal text)
                              Text(
                                verseReference.toUpperCase(),
                                style: TextStyle(
                                  fontSize:
                                      AppTheme.continueReadingVerseFontSize,
                                  fontWeight:
                                      AppTheme.continueReadingVerseFontWeight,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Last opened timestamp
                              Text(
                                'Last opened $relativeTime',
                                style: TextStyle(
                                  fontSize:
                                      AppTheme.continueReadingTimestampFontSize,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Resume → button (right-aligned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppTheme.gold.withValues(alpha: 0.18),
                              width: 1,
                            ),
                            color: AppTheme.gold.withValues(alpha: 0.08),
                          ),
                          child: Text(
                            'Resume →',
                            style: TextStyle(
                              color: AppTheme.gold,
                              fontSize:
                                  AppTheme.continueReadingResumeFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}