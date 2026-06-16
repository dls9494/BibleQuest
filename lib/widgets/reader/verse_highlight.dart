import 'package:flutter/material.dart';
import '../../constants/theme.dart';

/// Verse highlight widget with premium UX polish
class VerseHighlight extends StatefulWidget {
  final String verseText;
  final bool isSelected;
  final VoidCallback onLongPress;

  const VerseHighlight({
    Key? key,
    required this.verseText,
    required this.isSelected,
    required this.onLongPress,
  }) : super(key: key);

  @override
  State<VerseHighlight> createState() => _VerseHighlightState();
}

class _VerseHighlightState extends State<VerseHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.kAnimFast,
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppTheme.kAnimCurve,
      ),
    );

    // Start animation if selected
    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant VerseHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          child: GestureDetector(
            onLongPress: widget.onLongPress,
            child: Stack(
              children: [
                // Verse text
                Text(
                  widget.verseText,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
                // Gold overlay (animated opacity)
                if (widget.isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(
                        alpha: AppTheme.verseHighlightGoldOverlayOpacity *
                            _opacityAnimation.value,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}