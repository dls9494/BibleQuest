import 'dart:math';
import 'package:flutter/material.dart';

class CurrentLevelNode extends StatefulWidget {
  final Widget child;
  const CurrentLevelNode({super.key, required this.child});

  @override
  State<CurrentLevelNode> createState() => _CurrentLevelNodeState();
}

class _CurrentLevelNodeState extends State<CurrentLevelNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withAlpha(180),
              blurRadius: 12,
              spreadRadius: 4,
            )
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class ProgressPathWidget extends StatefulWidget {
  final int currentLevel;
  final Function(int level)? onLevelTap;

  const ProgressPathWidget({
    super.key,
    required this.currentLevel,
    this.onLevelTap,
  });

  @override
  State<ProgressPathWidget> createState() => _ProgressPathWidgetState();
}

class _ProgressPathWidgetState extends State<ProgressPathWidget> {
  final ScrollController _scrollController = ScrollController();

  final double milestoneWidth = 54.0;
  final double dotWidth = 16.0;
  final double lineWidth = 30.0;

  final Map<int, String> milestones = {
    1: "Egypt",
    20: "Red Sea",
    40: "Mount Sinai",
    60: "Wilderness",
    80: "Jordan River",
    100: "Promised Land",
  };

  final Map<int, IconData> milestoneIcons = {
    1: Icons.account_balance,
    20: Icons.water,
    40: Icons.terrain,
    60: Icons.landscape,
    80: Icons.waves,
    100: Icons.park,
  };

  double _calculateOffset(int targetLevel) {
    double offset = 0.0;
    for (int lvl = 1; lvl < targetLevel; lvl++) {
      if (milestones.containsKey(lvl)) {
        offset += milestoneWidth;
      } else {
        offset += dotWidth;
      }
      offset += lineWidth;
    }
    return offset;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final screenWidth = MediaQuery.of(context).size.width;
        final target = _calculateOffset(widget.currentLevel) - (screenWidth / 2) + (milestoneWidth / 2);
        final clamped = target.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          clamped,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: 199, // 100 nodes + 99 lines alternating
        itemBuilder: (context, index) {
          final isNode = index % 2 == 0;
          final itemIndex = index ~/ 2;
          final level = itemIndex + 1;

          if (isNode) {
            final isMilestone = milestones.containsKey(level);
            final isCompleted = level < widget.currentLevel;
            final isCurrent = level == widget.currentLevel;
            final isLocked = level > widget.currentLevel;

            Widget childNode;
            if (isMilestone) {
              final label = milestones[level]!;
              final icon = milestoneIcons[level]!;
              childNode = _buildMilestoneNode(level, label, icon, isCompleted, isCurrent);
            } else {
              childNode = _buildDotNode(level, isCompleted, isCurrent);
            }

            return ProgressPathNode(
              level: level,
              isLocked: isLocked,
              onLevelTap: widget.onLevelTap,
              child: childNode,
            );
          } else {
            // Line between level L and L+1
            // index ~/ 2 is the level L-1 (L is level)
            final levelL = level;
            final isCompleted = levelL < widget.currentLevel;
            return _buildConnectingLine(isCompleted);
          }
        },
      ),
    );
  }

  Widget _buildMilestoneNode(int level, String label, IconData icon, bool isCompleted, bool isCurrent) {
    Widget nodeCircle = Container(
      width: milestoneWidth,
      height: milestoneWidth,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent 
            ? Colors.amber 
            : (isCompleted ? Colors.amber : Colors.grey.shade800),
        border: Border.all(
          color: isCurrent 
              ? Colors.white 
              : (isCompleted ? Colors.amber.shade200 : Colors.grey.shade600),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: isCompleted || isCurrent ? Colors.black : Colors.white60,
        size: 24,
      ),
    );

    if (isCurrent) {
      nodeCircle = CurrentLevelNode(child: nodeCircle);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        nodeCircle,
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'L$level',
          style: TextStyle(
            color: isCurrent || isCompleted ? Colors.amber.shade200 : Colors.white60,
            fontSize: 9,
            fontFamily: 'Outfit',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDotNode(int level, bool isCompleted, bool isCurrent) {
    Widget dotCircle = Container(
      width: dotWidth,
      height: dotWidth,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent 
            ? Colors.amber 
            : (isCompleted ? Colors.amber : Colors.grey.shade800),
        border: Border.all(
          color: isCurrent 
              ? Colors.white 
              : (isCompleted ? Colors.amber.shade200 : Colors.grey.shade600),
          width: 1.5,
        ),
      ),
    );

    if (isCurrent) {
      dotCircle = CurrentLevelNode(child: dotCircle);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: (milestoneWidth - dotWidth) / 2),
        dotCircle,
      ],
    );
  }

  Widget _buildConnectingLine(bool isCompleted) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: (milestoneWidth - 4) / 2),
        Container(
          width: lineWidth,
          height: 4,
          color: isCompleted ? Colors.amber : Colors.grey.shade700,
        ),
      ],
    );
  }
}

class FullJourneyMap extends StatefulWidget {
  final int currentLevel;
  final int selectedLevel;
  final ValueChanged<int> onLevelSelected;

  const FullJourneyMap({
    super.key,
    required this.currentLevel,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  State<FullJourneyMap> createState() => _FullJourneyMapState();
}

class _FullJourneyMapState extends State<FullJourneyMap> {
  final ScrollController _scrollController = ScrollController();

  final Map<int, String> milestones = {
    1: "Egypt",
    20: "Red Sea",
    40: "Mount Sinai",
    60: "Wilderness",
    80: "Jordan River",
    100: "Promised Land",
  };

  final Map<int, IconData> milestoneIcons = {
    1: Icons.account_balance,
    20: Icons.water,
    40: Icons.terrain,
    60: Icons.landscape,
    80: Icons.waves,
    100: Icons.park,
  };

  final double milestoneWidth = 54.0;
  final double dotWidth = 16.0;

  @override
  void initState() {
    super.initState();
    // Scroll to the user's current level after building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Estimate position: each level row is 90.0 pixels high.
        // We want to scroll to widget.currentLevel.
        // Levels go from 1 to 100 from bottom to top, or 100 to 1 from top to bottom.
        // Let's scroll based on the index: (100 - widget.currentLevel).
        double targetOffset = (100 - widget.currentLevel) * 90.0;
        final screenHeight = MediaQuery.of(context).size.height;
        // Center the level on the screen
        double centeredOffset = targetOffset - (screenHeight / 2) + 45.0;
        double clamped = centeredOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.jumpTo(clamped);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF38BDF8), size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Journey Map",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance back button
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              
              // Winding Map List
              Expanded(
                child: Stack(
                  children: [
                    // Vertical central road line (runs down the center of the list)
                    Center(
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    
                    // Levels list (100 to 1, winding)
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: 100,
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      itemBuilder: (context, index) {
                        final level = 100 - index;
                        final isMilestone = milestones.containsKey(level);
                        final isCompleted = level < widget.currentLevel;
                        final isCurrent = level == widget.currentLevel;
                        final isLocked = level > widget.currentLevel;
                        final isSelected = level == widget.selectedLevel;

                        // Winding horizontal offset using sine wave
                        final double offsetX = sin(level * 0.8) * 45.0;

                        Widget nodeCircle;
                        if (isMilestone) {
                          nodeCircle = Container(
                            width: milestoneWidth,
                            height: milestoneWidth,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? Colors.amber
                                  : (isCompleted ? Colors.amber.shade700 : Colors.grey.shade800),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF38BDF8) // Glowing Selected Border
                                    : (isCurrent ? Colors.white : (isCompleted ? Colors.amber.shade200 : Colors.grey.shade600)),
                                width: isSelected ? 4 : 2,
                              ),
                              boxShadow: isSelected || isCurrent
                                  ? [
                                      BoxShadow(
                                        color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.8) : Colors.amber.withValues(alpha: 0.8),
                                        blurRadius: 16,
                                        spreadRadius: 3,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              milestoneIcons[level]!,
                              color: isCompleted || isCurrent ? Colors.black : Colors.white60,
                              size: 26,
                            ),
                          );
                        } else {
                          nodeCircle = Container(
                            width: dotWidth,
                            height: dotWidth,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? Colors.amber
                                  : (isCompleted ? Colors.amber : Colors.grey.shade800),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF38BDF8) // Glowing Selected Border
                                    : (isCurrent ? Colors.white : (isCompleted ? Colors.amber.shade200 : Colors.grey.shade600)),
                                width: isSelected ? 3 : 1.5,
                              ),
                              boxShadow: isSelected || isCurrent
                                  ? [
                                      BoxShadow(
                                        color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.8) : Colors.amber.withValues(alpha: 0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          );
                        }

                        if (isCurrent) {
                          nodeCircle = CurrentLevelNode(child: nodeCircle);
                        }

                        // Reuse ProgressPathNode for tap, shake, tooltip and feedback
                        Widget clickableNode = ProgressPathNode(
                          level: level,
                          isLocked: isLocked,
                          onLevelTap: (lvl) {
                            widget.onLevelSelected(lvl);
                            Navigator.pop(context);
                          },
                          child: nodeCircle,
                        );

                        return SizedBox(
                          height: 90.0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Local horizontal line from center line to offset node
                              if (offsetX.abs() > 5)
                                Positioned(
                                  left: offsetX > 0 ? MediaQuery.of(context).size.width / 2 : null,
                                  right: offsetX < 0 ? MediaQuery.of(context).size.width / 2 : null,
                                  child: Container(
                                    width: offsetX.abs(),
                                    height: 3,
                                    color: isCompleted ? Colors.amber.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              
                              // The Node itself, offset horizontally
                              Transform.translate(
                                offset: Offset(offsetX, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (offsetX >= 0) ...[
                                      clickableNode,
                                      const SizedBox(width: 12),
                                      _buildLevelInfo(level, isMilestone, isLocked, isCurrent),
                                    ] else ...[
                                      _buildLevelInfo(level, isMilestone, isLocked, isCurrent),
                                      const SizedBox(width: 12),
                                      clickableNode,
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildLevelInfo(int level, bool isMilestone, bool isLocked, bool isCurrent) {
    String label = isMilestone ? milestones[level]! : "Level $level";
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? Colors.amber.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isLocked ? Colors.white38 : Colors.white,
              fontSize: isMilestone ? 12 : 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (isMilestone)
            Text(
              'Milestone L$level',
              style: TextStyle(
                color: isCurrent ? Colors.amber : Colors.white54,
                fontSize: 9,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            )
          else if (isLocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock, size: 10, color: Colors.white38),
                SizedBox(width: 2),
                Text(
                  'Locked',
                  style: TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'Outfit'),
                ),
              ],
            )
          else if (isCurrent)
            const Text(
              'Current',
              style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              textAlign: TextAlign.center,
            )
          else
            const Text(
              'Unlocked',
              style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontFamily: 'Outfit'),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class ProgressPathNode extends StatefulWidget {
  final int level;
  final Widget child;
  final bool isLocked;
  final Function(int level)? onLevelTap;

  const ProgressPathNode({
    super.key,
    required this.level,
    required this.child,
    required this.isLocked,
    required this.onLevelTap,
  });

  @override
  State<ProgressPathNode> createState() => _ProgressPathNodeState();
}

class _ProgressPathNodeState extends State<ProgressPathNode> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    Widget node = widget.child;
    if (widget.isLocked) {
      node = Tooltip(
        message: "Locked",
        child: node,
      );
    }

    return GestureDetector(
      onTap: () {
        if (!widget.isLocked) {
          widget.onLevelTap?.call(widget.level);
        } else {
          _shake();
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.clearSnackBars();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("Level ${widget.level} is locked. Complete level ${widget.level - 1} first."),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: MouseRegion(
        cursor: widget.isLocked ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final double t = _shakeController.value;
            final double offset = sin(t * 3 * pi) * 6.0 * (1.0 - t);
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: node,
        ),
      ),
    );
  }
}
