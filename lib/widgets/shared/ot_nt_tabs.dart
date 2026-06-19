import 'package:flutter/material.dart';
import '../../constants/theme.dart';

/// OT/NT tabs widget with premium UX design
class OtNtTabs extends StatefulWidget {
  final BibleSection activeSection;
  final ValueChanged<BibleSection> onTabChanged;

  const OtNtTabs({
    super.key,
    required this.activeSection,
    required this.onTabChanged,
  });

  @override
  State<OtNtTabs> createState() => _OtNtTabsState();
}

enum BibleSection { ot, nt }

class _OtNtTabsState extends State<OtNtTabs> {
  late BibleSection _activeSection;

  @override
  void initState() {
    super.initState();
    _activeSection = widget.activeSection;
  }

  @override
  void didUpdateWidget(covariant OtNtTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSection != oldWidget.activeSection) {
      setState(() {
        _activeSection = widget.activeSection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final inactiveTextColor =
        textColor.withValues(alpha: AppTheme.otntTabInactiveTextOpacity);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // OT Tab
          Expanded(
            child: AnimatedContainer(
              duration: AppTheme.otntTabAnimationDuration,
              curve: AppTheme.otntTabAnimationCurve,
              child: InkWell(
                onTap: () {
                  if (_activeSection != BibleSection.ot) {
                    setState(() {
                      _activeSection = BibleSection.ot;
                    });
                    widget.onTabChanged(BibleSection.ot);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    // Active state: 12% opacity gold background pill
                    color: (_activeSection == BibleSection.ot)
                        ? AppTheme.gold.withValues(
                            alpha: AppTheme.otntTabActiveBgOpacity)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        AppTheme.otntTabBorderRadius),
                  ),
                  child: Center(
                    child: Text(
                      'OT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (_activeSection == BibleSection.ot)
                            ? AppTheme.gold
                            : inactiveTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // NT Tab
          Expanded(
            child: AnimatedContainer(
              duration: AppTheme.otntTabAnimationDuration,
              curve: AppTheme.otntTabAnimationCurve,
              child: InkWell(
                onTap: () {
                  if (_activeSection != BibleSection.nt) {
                    setState(() {
                      _activeSection = BibleSection.nt;
                    });
                    widget.onTabChanged(BibleSection.nt);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    // Active state: 12% opacity gold background pill
                    color: (_activeSection == BibleSection.nt)
                        ? AppTheme.gold.withValues(
                            alpha: AppTheme.otntTabActiveBgOpacity)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        AppTheme.otntTabBorderRadius),
                  ),
                  child: Center(
                    child: Text(
                      'NT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (_activeSection == BibleSection.nt)
                            ? AppTheme.gold
                            : inactiveTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}